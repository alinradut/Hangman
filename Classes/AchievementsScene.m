//
//  AchievementsScene.m
//  Hangman
//
//  Created by Clawoo on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AchievementsScene.h"
#import "MenuScene.h"

NSInteger compareScores(NSDictionary *score1, NSDictionary *score2, void *context) {
    return [[score2 valueForKey:@"score"] compare:[score1 valueForKey:@"score"]];
}

@implementation AchievementsScene

+(id) scene {
	CCScene *scene = [CCScene node];
	AchievementsScene *layer = [AchievementsScene node];
	[scene addChild: layer];
	return scene;
}


-(id) init {
	if( (self=[super init] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile:@"background-dirty-2.png"];
		background.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:background];
		
		CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"txt-achievements.png"];
		title.position = ccp(winSize.width/2 + 10, winSize.height - 17);
		title.anchorPoint = ccp(0.5, 1);
		[self addChild:title];
        
        CCSprite *table = [CCSprite spriteWithSpriteFrameName:@"highscores-table.png"];
        table.position = ccp(winSize.width/2, winSize.height/2 - 33);
        [self addChild:table];
        
        CCSprite *name = [CCSprite spriteWithSpriteFrameName:@"txt-name.png"];
        name.position = ccp(winSize.width/2 - 90, winSize.height - 75);
        [self addChild:name];
        
        CCSprite *score = [CCSprite spriteWithSpriteFrameName:@"txt-score.png"];
        score.position = ccp(winSize.width/2 + 75, winSize.height - 75);
        [self addChild:score];
		
		CCMenuItemImage *backButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn-back.png"]
															 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn-back.png"] 
																	 target:self 
																   selector:@selector(backBtnTapped)];
		backButton.anchorPoint = ccp(0, 1);
		CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
		menu.position = ccp(10, winSize.height - 17);
		[self addChild:menu];   
        
        NSArray *scores = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"scores"]];
        scores_ = [[scores sortedArrayUsingFunction:compareScores context:NULL] retain];
        
        CCMenu *achievementsMenu = [CCMenu menuWithItems:nil];
        achievementsMenu.position = ccp(175, winSize.height - 110);
        
        NSInteger row = 0;
        for (NSDictionary *score in scores_) {
            if (row == 13) {
                break;
            }
            NSLog(@"%@ %@", [score objectForKey:@"score"], [score objectForKey:@"name"]);
            
            NSString *string = [NSString stringWithFormat:@"%@",[score valueForKey:@"name"]];
            CCLabelTTF *player = [CCLabelTTF labelWithString:string fontName:@"Chalkduster.ttf" fontSize:18];
            player.position = ccp(75, winSize.height - 110 - row * 30);
            player.color = ccc3(187,54,54);
            [self addChild:player];

            string = [NSString stringWithFormat:@"%@",[score valueForKey:@"score"]];
            CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:string fontName:@"Chalkduster.ttf" fontSize:18];
            scoreLabel.position = ccp(240, winSize.height - 110 - row * 30);
            scoreLabel.color = ccc3(187,54,54);
            [self addChild:scoreLabel];
            
            NSArray *achievements = [NSArray arrayWithArray:[score objectForKey:@"achievements"]];
            if ([achievements count]) {
                CCMenuItem *menuItem = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:@"btn-achievement.png"]
                                                              selectedSprite:[CCSprite spriteWithSpriteFrameName:@"btn-achievement.png"]
                                                                      target:self 
                                                                    selector:@selector(achievementBtnTapped:)];
                menuItem.tag = row;
                [achievementsMenu addChild:menuItem];
            }
            
            row++;
        }
        [self addChild:achievementsMenu];
	}
	return self;
}

- (void)achievementBtnTapped:(CCMenuItem *)sender {
    
    NSDictionary *dict = [scores_ objectAtIndex:sender.tag];
    NSArray *achievements = [NSArray arrayWithArray:[dict objectForKey:@"achievements"]];
    NSString *message = [achievements componentsJoinedByString:@"\n"];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Achievements" 
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:@"Close" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert autorelease];
}

- (void)backBtnTapped {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:.7 
																					 scene:[MenuScene scene]
																				 backwards:YES]];
}                                              

- (void)dealloc {
    [scores_ release];
    [super dealloc];
}

@end
