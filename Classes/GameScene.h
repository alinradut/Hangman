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
}

+ (id)scene;
- (CCMenuItem *)itemForAtRow:(NSInteger)row column:(NSInteger)column;

@property (nonatomic, retain) NSMutableString *displayedWord;
@property (nonatomic, retain) NSMutableString *pickedLetters;
@property (nonatomic, retain) NSString *word;


@end
