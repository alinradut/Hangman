//
//  AboutScene.m
//  Hangman
//
//  Created by Clawoo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutScene.h"
#import "MenuScene.h"

@implementation AboutScene

+(id) scene {
	CCScene *scene = [CCScene node];
	AboutScene *layer = [AboutScene node];
	[scene addChild: layer];
	return scene;
}

-(id) init {
	if( (self=[super init] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"background-dirty-2.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		
		CCLabelTTF *title = [CCLabelTTF labelWithString:@"About" fontName:@"Chalkduster.ttf" fontSize:28];
		title.position = ccp(winSize.width/2, winSize.height - 13);
		title.anchorPoint = ccp(0.5, 1);
        title.color = ccc3(187,54,54);
		[self addChild:title];
        
        textView_ = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, 320, 270)];
        textView_.editable = NO;
        textView_.backgroundColor = [UIColor clearColor];
        textView_.dataDetectorTypes = UIDataDetectorTypeAll;
        textView_.textColor = [UIColor colorWithRed:187.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1];
        textView_.opaque = NO;
        textView_.font = [UIFont fontWithName:@"Chalkduster" size:16];
        textView_.text = @"Built using Cocos2d.\n\nThe code is open source and can be downloaded from https://github.com/clawoo/Hangman.\n\nBuilt by Alin Radut (tehclw@gmail.com).";
        
        [[[CCDirector sharedDirector] openGLView] addSubview:textView_]; 
        [textView_ release];
      
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

- (void)backBtnTapped {
    [textView_ removeFromSuperview]; 
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:.7 
																					 scene:[MenuScene scene]
																				 backwards:YES]];
}  

@end
