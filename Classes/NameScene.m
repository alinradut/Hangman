//
//  NameScene.m
//  Hangman
//
//  Created by Clawoo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NameScene.h"
#import "MenuScene.h"
#import "GameScene.h"

@interface NameScene ()
- (void)updateName;
@end


@implementation NameScene

+(id) scene {
	CCScene *scene = [CCScene node];
	NameScene *layer = [NameScene node];
	[scene addChild: layer];
	return scene;
}

-(id) init {
	if( (self=[super init] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"background-clean.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		
		CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"txt-enter-name.png"];
		title.position = ccp(winSize.width/2, winSize.height - 17);
		title.anchorPoint = ccp(0.5, 1);
		[self addChild:title];
		
		CCSprite *textPlaceholder = [CCSprite spriteWithSpriteFrameName:@"name-placeholder.png"];
		textPlaceholder.position = ccp(winSize.width/2, 305);
		[self addChild:textPlaceholder];
		
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
		
		CCMenuItemImage *doneButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn-done.png"] 
															 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn-done.png"] 
																	 target:self 
																   selector:@selector(doneBtnTapped)];
		doneButton.position = ccp(winSize.width/2,260);
		[keyboard addChild:doneButton];
		
		keyboardLines_ = [[NSArray alloc] initWithObjects:@"QWERTYUIOP", @"ASDFGHJKL", @"ZXCVBNM<", nil];
		
		for (int row=0; row < [keyboardLines_ count]; row++) {
			for (int col = 0; col<[[keyboardLines_ objectAtIndex:row] length]; col++) {
				[keyboard addChild:[self itemForAtRow:row column:col]];
			}
		}
		
		name_ = [[NSMutableString alloc] init];
		
		if ([[NSUserDefaults standardUserDefaults] valueForKey:@"lastPlayerName"]) {
			[name_ setString:[[NSUserDefaults standardUserDefaults] valueForKey:@"lastPlayerName"]];
			[self updateName];
		}
	}
	return self;
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

#pragma mark -
#pragma mark Menu

- (void)updateName {
	[nameLabel_ removeFromParentAndCleanup:YES];
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	nameLabel_ = [CCLabelTTF labelWithString:name_ fontName:@"Chalkduster.ttf" fontSize:24];
	nameLabel_.position = ccp(winSize.width/2, 320);
	nameLabel_.color = ccc3(187,54,54);
	[self addChild:nameLabel_];
}

- (void)keyboardButtonTapped:(CCMenuItem *)key {
	NSString *keyboard = [keyboardLines_ objectAtIndex:key.tag/10];
	
	if ([keyboard characterAtIndex:key.tag % 10] == '<') {
		if ([name_ length]) {
			[name_ deleteCharactersInRange:NSMakeRange(name_.length - 1, 1)];
		}
	}
	else {
		[name_ appendFormat:@"%c", [keyboard characterAtIndex:key.tag % 10]];
	}

	[self updateName];
}

- (void)backBtnTapped {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:.7 
																					 scene:[MenuScene scene]
																				 backwards:YES]];
}
- (void)doneBtnTapped {
	if (![name_ length]) {
		return;
	}
	[[NSUserDefaults standardUserDefaults] setValue:name_ forKey:@"lastPlayerName"];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:.7 
																					 scene:[GameScene scene]
																				 backwards:NO]];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[keyboardLines_ release];
	[name_ release];
	[super dealloc];
}


@end
