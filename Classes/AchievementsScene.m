//
//  AchievementsScene.m
//  Hangman
//
//  Created by Clawoo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AchievementsScene.h"


@implementation AchievementsScene

+(id) scene {
	CCScene *scene = [CCScene node];
	AchievementsScene *layer = [AchievementsScene node];
	[scene addChild: layer];
	return scene;
}

@end
