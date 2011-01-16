//
//  NameScene.m
//  Hangman
//
//  Created by Clawoo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NameScene.h"
#import "MenuScene.h"

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
	}
	return self;
}

#pragma mark -
#pragma mark Menu
- (void)playBtnTapped {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:.7 
																					 scene:[NameScene scene]]];
}

- (void)backBtnTapped {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:.7 
																					 scene:[MenuScene scene]
																				 backwards:YES]];
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[nameLabel_ removeFromParentAndCleanup:YES];
	[super dealloc];
}


@end
