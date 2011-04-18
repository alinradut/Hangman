//
//  GameScene.m
//  Hangman
//
//  Created by Clawoo on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"

@interface GameScene (Private)

- (void)updateDisplay;
- (void)startGame;
- (void)endGame:(BOOL)successfully;
- (void)saveGameProgress;
- (void)backBtnTapped;

@end


@implementation GameScene
@synthesize displayedWord = displayedWord_;
@synthesize pickedLetters = pickedLetters_;
@synthesize word = word_;
@synthesize scoreGuid = scoreGuid_;
@synthesize playerName = playerName_;

+(id) scene {
	CCScene *scene = [CCScene node];
	GameScene *layer = [GameScene node];
	[scene addChild: layer];
	return scene;
}


-(id) init {
	if( (self=[super init] )) {
		srand ( time(NULL) );
        scoreDict_ = [[NSMutableDictionary alloc] init];
        achievements_ = [[NSMutableArray alloc] init];
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"background-clean.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		
		CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn-back.png"]
															 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn-back.png"] 
																	 target:self 
																   selector:@selector(backBtnTapped)];
		backButton.anchorPoint = ccp(0, 1);
		CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
		menu.position = ccp(10, winSize.height - 17);
		[self addChild:menu];
		
		CCMenu *keyboard = [CCMenu menuWithItems:nil];
		keyboard.position = ccp(0, 0);
		keyboard.anchorPoint = ccp(0.5, 0);
		[self addChild:keyboard];
		
		keyboardLines_ = [[NSArray alloc] initWithObjects:@"QWERTYUIOP", @"ASDFGHJKL", @"ZXCVBNM", nil];
		
		for (int row=0; row < [keyboardLines_ count]; row++) {
			for (int col = 0; col<[[keyboardLines_ objectAtIndex:row] length]; col++) {
				[keyboard addChild:[self itemForAtRow:row column:col]];
			}
		}
		
		// noose frame
		CCSprite *nooseFrame = [CCSprite spriteWithSpriteFrameName:@"noose-frame.png"];
		nooseFrame.position = ccp(53.0, 333);
		[self addChild:nooseFrame];
		
		scoreLabel_ = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Chalkduster.ttf" fontSize:18];
		scoreLabel_.color = ccc3(187,54,54);
		scoreLabel_.position = ccp(winSize.width/2, winSize.height - 17);
		scoreLabel_.anchorPoint = ccp(0.5, 1);
		[self addChild:scoreLabel_];
		
		[self startGame];
	}
	return self;
}

- (void)achievementUnlocked:(NSString *)achievement {
	[achievements_ addObject:achievement];

    // lazy load the achievements layer
    if (!achievementLayer_) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // instantiate the layer
        achievementLayer_ = [[CCLayer alloc] init];
        achievementLayer_.anchorPoint = ccp(0,0);
        achievementLayer_.position = ccp(winSize.width/2, winSize.height - 60);

        // create the achievement badge sprite
        CCSprite *badge = [CCSprite spriteWithSpriteFrameName:@"btn-achievement.png"];
        badge.tag = 1;
        [achievementLayer_ addChild:badge];
        
        // create the achievement label
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"" fontName:@"Chalkduster.ttf" fontSize:18];
		label.color = ccc3(187,54,54);
        label.tag = 2;
		[achievementLayer_ addChild:label];
        
        [self addChild:achievementLayer_];
        [achievementLayer_ release];
    }

    // make the achievement layer really really small
    achievementLayer_.scale = 0.01;
    
    // update the achievement text
    [(CCLabelTTF *)[achievementLayer_ getChildByTag:2] setString:achievement];
    
    achievementLayer_.visible = YES;
    
    // compute the size of the text
    CGSize size = [achievement sizeWithFont:[UIFont fontWithName:@"Chalkduster" size:18]];
    
    // move the achievements badge to the left
    [achievementLayer_ getChildByTag:1].position = ccp(-size.width/2 - 12, 0);
    
    // animate the achievements layer and give it a bouncy feeling
    [achievementLayer_ runAction:[CCSequence actions:
                                 // scale from 0.01 to 1.60
                                 [CCScaleTo actionWithDuration:.2 scale:1.6],
                                 // scale from 1.60 to 0.80
                                 [CCScaleTo actionWithDuration:.1 scale:0.8],
                                 // scale from 0.80 to 1.00
                                 [CCScaleTo actionWithDuration:.1 scale:1],nil]];
}

- (void)updateCorrectKeysPressed {
    correctKeysPressed_++;
    correctKeysPressedThisGame_++;
    score_ += 10 + (correctKeysPressedThisGame_ - 1) * 3;
    
    
    if (correctKeysPressed_ && correctKeysPressed_ % 10 == 0) {
        // player receives a bonus based on correct consecutive keys pressed for all games
        NSInteger bonus = score_ * ((float)correctKeysPressed_/200);
        score_ += bonus;
        
        NSString *achievement = [NSString stringWithFormat:@"%d keys in a row! (+%d)", correctKeysPressed_, bonus];
        [self achievementUnlocked:achievement];
    }
    [scoreLabel_ setString:[NSString stringWithFormat:@"Score: %d", score_]];
    [self saveGameProgress];
}

- (void)updateIncorrectKeysPressed {
	correctKeysPressed_ = 0;
	correctKeysPressedThisGame_ = 0;
}

- (void)updateGamesWon {
	gamesWonInARow_++;
	
    if (gamesWonInARow_ && (gamesWonInARow_ % 10 == 0 || gamesWonInARow_ == 5)) {
        // player receives a bonus based on consecutive games won
        NSInteger bonus = score_* ((float)gamesWonInARow_ / 100);
        score_ += bonus;

        NSString *achievement = [NSString stringWithFormat:@"%d games in a row! (+%d)", gamesWonInARow_, bonus];
		[self achievementUnlocked:achievement];
    }
    
    [scoreLabel_ setString:[NSString stringWithFormat:@"Score: %d", score_]];
    [self saveGameProgress];
}

- (void)updateGamesLost {
	gamesWonInARow_ = 0;
    
    // player loses 25% of points
    score_ = score * .75;
}

- (NSString *)randomWord {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"plist"];
	NSArray *words = [NSArray arrayWithContentsOfFile:path];
	return [[[words objectAtIndex:rand()%[words count]] retain] autorelease];
}

- (void)startGame {
	self.word = [[self randomWord] uppercaseString];
	self.displayedWord = [NSMutableString stringWithCapacity:[word_ length] * 2];
	self.pickedLetters = [NSMutableString string];
	wrongLetters_ = 0;
	correctKeysPressedThisGame_ = 0;
	NSLog(@"Word is: %@", word_);
	
	while ([self getChildByTag:31]) {
		[self removeChildByTag:31 cleanup:YES];
	}
	while ([self getChildByTag:32]) {
		[self removeChildByTag:32 cleanup:YES];
	}
	
	[self updateDisplay];
}

- (void)endGame:(BOOL)successfully {
	if (successfully) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Awesome!" 
														message:[NSString stringWithFormat:@"You're right, the word is %@", word_]
													   delegate:self 
											  cancelButtonTitle:@"Try another"  
                                              otherButtonTitles:nil];
		alert.tag = 1;
		[alert show];
		[alert release];
        [self updateGamesWon];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too bad!" 
														message:[NSString stringWithFormat:@"You didn't make it, the word was %@", word_]
													   delegate:self 
											  cancelButtonTitle:@"Try another" 
											  otherButtonTitles:nil];
		alert.tag = 2;
		[alert show];
		[alert release];
        [self updateGamesLost];
	}
	
}

- (void)saveGameProgress {
    [scoreDict_ setObject:scoreGuid_ forKey:@"guid"];
    [scoreDict_ setObject:playerName_ forKey:@"name"];
    [scoreDict_ setObject:achievements_ forKey:@"achievements"];
    [scoreDict_ setObject:[NSNumber numberWithInt:score_] forKey:@"score"];
    
    NSMutableArray *scores = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"scores"]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid = %@", scoreGuid_];
    NSArray *result = [scores filteredArrayUsingPredicate:predicate];
    if ([result count]) {
        [scores removeObjectsInArray:result];
    }
    [scores addObject:scoreDict_];
    NSLog(@"Saving scores: %@", scores);
    [[NSUserDefaults standardUserDefaults] setObject:scores forKey:@"scores"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex) {
		[self backBtnTapped];
	}
	else {
		[self startGame];
	}
}

- (CCMenuItem *)itemForAtRow:(NSInteger)row column:(NSInteger)column {
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	static float rowHeight = 43.0;
	static float buttonWidth = 31.0;
	
	NSString *keyboard = [keyboardLines_ objectAtIndex:row];
	float rowOffset = (winSize.width - buttonWidth * ([keyboard length]-1))/2;
	
	NSRange range = NSMakeRange(column, 1);
	CCLabelBMFont *label = [CCLabelTTF labelWithString:[keyboard substringWithRange:range] fontName:@"Chalkduster.ttf" fontSize:24];
	label.color = ccc3(187,54,54);
	label.position = ccp(rowOffset + buttonWidth * column, 93.0 + (2 - row) * rowHeight);
	label.anchorPoint = ccp(0.5, 0.5);
	[self addChild:label];
	
	NSString *buttonName = [NSString stringWithFormat:@"keyboard-%d.png", rand()%5 + 1];
	CCMenuItemImage *menuItem =[CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:buttonName] 
													  selectedSprite:[CCSprite spriteWithSpriteFrameName:buttonName]
															  target:self
															selector:@selector(keyboardButtonTapped:)];
	menuItem.position = ccp(rowOffset + buttonWidth * column, 93.0 + (2 - row) * rowHeight);
	menuItem.anchorPoint = ccp(0.5, 0.5);
	menuItem.tag = row * 10 + column;
	return menuItem;
}

- (void)updateDisplay {
	if ([self getChildByTag:30]) {
		[self removeChildByTag:30 cleanup:YES];
	}
	if (wrongLetters_) {
		CCSprite *character = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"hangman%d.png", wrongLetters_]];
		character.tag = 30;
		character.anchorPoint = ccp(0.5, 0);
		character.position = ccp(86.0, 294.0);
		[self addChild:character];
	}
	
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	NSRange range;
	NSMutableArray *characters = [NSMutableArray arrayWithCapacity:0];
	for (int i=0; i<[word_ length]; i++) {
		range = NSMakeRange(i, 1);
		if ([pickedLetters_ length]
			&& [pickedLetters_ rangeOfString:[word_ substringWithRange:range]].location != NSNotFound) {
			[characters addObject:[word_ substringWithRange:range]];
		}
		else {
			[characters addObject:@"_"];
		}
	}
	[displayedWord_ setString:[characters componentsJoinedByString:@" "]];
	
	if (!wordLabel_) {
		wordLabel_ = [CCLabelTTF labelWithString:displayedWord_ fontName:@"Chalkduster.ttf" fontSize:24];
		wordLabel_.color = ccc3(187,54,54);
		wordLabel_.position = ccp(winSize.width/2, 230);
		wordLabel_.anchorPoint = ccp(0.5, 0.5);
		[self addChild:wordLabel_];
	}
	[wordLabel_ setString:displayedWord_];
}


#pragma mark -
#pragma mark Menu

- (void)keyboardButtonTapped:(CCMenuItem *)key {
	NSString *keyboard = [keyboardLines_ objectAtIndex:key.tag/10];
	NSRange range = NSMakeRange(key.tag % 10, 1);
	
	if ([pickedLetters_ rangeOfString:[keyboard substringWithRange:range]].location != NSNotFound) {
		return;
	}
    achievementLayer_.visible = NO;

	if ([word_ rangeOfString:[keyboard substringWithRange:range]].location == NSNotFound) {
		wrongLetters_++;
		[self updateIncorrectKeysPressed];
		CCSprite *incorrect = [CCSprite spriteWithSpriteFrameName:@"incorrect.png"];
		incorrect.position = key.position;
		incorrect.tag = 31;
		[self addChild:incorrect];
		if (wrongLetters_ == 7) {
			[self endGame:NO];
		}
	}
	else {
		CCSprite *correct = [CCSprite spriteWithSpriteFrameName:@"correct.png"];
		correct.position = key.position;
		correct.tag = 32;
		[self addChild:correct];
		[self updateCorrectKeysPressed];
	}
	
	[pickedLetters_ appendString:[keyboard substringWithRange:range]];

	[self updateDisplay];
	
	if ([displayedWord_ rangeOfString:@"_"].location == NSNotFound) {
		[self endGame:YES];
	}
}

- (void)backBtnTapped {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:.7 
																					 scene:[MenuScene scene]
																				 backwards:YES]];
}
#pragma mark -
#pragma mark Memory management

- (void) dealloc {
    [scoreDict_ release];
    [achievements_ release];

	self.word = nil;
	self.displayedWord = nil;
    
    self.scoreGuid = nil;
    self.playerName = nil;
	[super dealloc];
}

@end
