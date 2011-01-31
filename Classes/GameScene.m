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
- (void)backBtnTapped;

@end


@implementation GameScene
@synthesize displayedWord = displayedWord_;
@synthesize pickedLetters = pickedLetters_;
@synthesize word = word_;

+(id) scene {
	CCScene *scene = [CCScene node];
	GameScene *layer = [GameScene node];
	[scene addChild: layer];
	return scene;
}


-(id) init {
	if( (self=[super init] )) {
		srand ( time(NULL) );
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
		
		[self startGame];
	}
	return self;
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
	
	[self updateDisplay];
}

- (void)endGame:(BOOL)successfully {
	if (successfully) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Awesome!" 
														message:[NSString stringWithFormat:@"You're right, the word is %@", word_]
													   delegate:self 
											  cancelButtonTitle:@"Try another" 
											  otherButtonTitles:@"I'm done", nil];
		alert.tag = 1;
		[alert show];
		[alert release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too bad!" 
														message:[NSString stringWithFormat:@"You didn't make it, the word was %@", word_]
													   delegate:self 
											  cancelButtonTitle:@"Try another" 
											  otherButtonTitles:@"I'm done", nil];
		alert.tag = 2;
		[alert show];
		[alert release];
	}

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
	[self removeChildByTag:30 cleanup:YES];
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
	
	[wordLabel_ removeFromParentAndCleanup:YES];
	wordLabel_ = [CCLabelTTF labelWithString:displayedWord_ fontName:@"Chalkduster.ttf" fontSize:24];
	wordLabel_.color = ccc3(187,54,54);
	wordLabel_.position = ccp(winSize.width/2, 230);
	wordLabel_.anchorPoint = ccp(0.5, 0.5);
	[self addChild:wordLabel_];
}

#pragma mark -
#pragma mark Menu

- (void)keyboardButtonTapped:(CCMenuItem *)key {
	NSString *keyboard = [keyboardLines_ objectAtIndex:key.tag/10];
	NSRange range = NSMakeRange(key.tag % 10, 1);
	
	if ([pickedLetters_ rangeOfString:[keyboard substringWithRange:range]].location != NSNotFound) {
		return;
	}
	
	if ([word_ rangeOfString:[keyboard substringWithRange:range]].location == NSNotFound) {
		wrongLetters_++;
		if (wrongLetters_ == 7) {
			[self endGame:NO];
		}
	}

	if ([displayedWord_ rangeOfString:@"_"].location == NSNotFound) {
		[self endGame:YES];
	}
	
	[pickedLetters_ appendString:[keyboard substringWithRange:range]];
	[self updateDisplay];
	
}

- (void)backBtnTapped {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:.7 
																					 scene:[MenuScene scene]
																				 backwards:YES]];
}
#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	self.word = nil;
	self.displayedWord = nil;
	[super dealloc];
}

@end
