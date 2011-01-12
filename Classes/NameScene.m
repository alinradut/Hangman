//
//  NameScene.m
//  Hangman
//
//  Created by Clawoo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NameScene.h"


@implementation NameScene

+(id) scene {
	CCScene *scene = [CCScene node];
	NameScene *layer = [NameScene node];
	[scene addChild: layer];
	return scene;
}

@end
