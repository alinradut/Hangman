//
//  GameScene.h
//  Hangman
//
//  Created by Clawoo on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCLayer <UIAlertViewDelegate> {
	NSArray *keyboardLines_;
	NSMutableString *pickedLetters_;
	NSString *word_;
	NSMutableString *displayedWord_;
	NSInteger wrongLetters_;
	CCLabelTTF *wordLabel_;
	
	int correctKeysPressed_;
	int correctKeysPressedThisGame_;
	int gamesWonInARow_;
	NSMutableArray *achievements_;
	int score_;
	CCLabelBMFont *scoreLabel_;
    CCLayer *achievementLayer_;
    
    NSString *scoreGuid_;
    NSString *playerName_;
    NSMutableDictionary *scoreDict_;
}

+ (id)scene;
- (CCMenuItem *)itemForAtRow:(NSInteger)row column:(NSInteger)column;

@property (nonatomic, retain) NSMutableString *displayedWord;
@property (nonatomic, retain) NSMutableString *pickedLetters;
@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) NSString *scoreGuid;
@property (nonatomic, retain) NSString *playerName;

@end
