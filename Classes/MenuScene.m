//
//  MenuScene.m
//  Hangman
//
//  Created by Clawoo on 1/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuScene.h"
#import "NameScene.h"
#import "AchievementsScene.h"
#import "AboutScene.h"

@implementation MenuScene

+(id) scene {
	CCScene *scene = [CCScene node];
	MenuScene *layer = [MenuScene node];
	[scene addChild: layer];
	return scene;
}

-(id) init {
	if( (self=[super init] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"background-dirty-1.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		
		CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"logo.png"];
		logo.position = ccp(winSize.width/2, winSize.height);
		logo.anchorPoint = ccp(0.5, 1);
		[self addChild:logo];
		
		CCMenuItemSprite *playItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn-play-off.png"] 
															 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn-play-on.png"]
																	 target:self 
																   selector:@selector(playBtnTapped)];
		playItem.position = ccp(0, 0);
		CCMenuItemSprite *achievementsItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn-achievements-off.png"] 
																	 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn-achievements-on.png"]
																			 target:self 
																		   selector:@selector(achievementsBtnTapped)];
		achievementsItem.position = ccp(0, -45);
		
		CCMenuItemSprite *aboutItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn-about-off.png"] 
															  selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn-about-on.png"]
																	  target:self 
																	selector:@selector(aboutBtnTapped)];
		aboutItem.position = ccp(0, -100);

		CCMenu *menu = [CCMenu menuWithItems:playItem, achievementsItem, aboutItem, nil];

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

- (void)achievementsBtnTapped {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:.7 
																					 scene:[AchievementsScene scene]]];
}

- (void)aboutBtnTapped {
	[[CCDirector sharedDirector] replaceScene:[AboutScene scene]];
	
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc {
	[super dealloc];
}
@end
