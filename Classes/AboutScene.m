//
//  AboutScene.m
//  Hangman
//
//  Created by Clawoo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutScene.h"


@implementation AboutScene

+(id) scene {
	CCScene *scene = [CCScene node];
	AboutScene *layer = [AboutScene node];
	[scene addChild: layer];
	return scene;
}

@end
