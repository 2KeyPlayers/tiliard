//
//  GameScene.h
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/26/10.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#import "Tile.h"
#import "Game.h"
#import "BaseScene.h"


@interface Ending : Base {

	BOOL _theEnd;
}

#pragma mark -
#pragma mark Scene Creator

+(id) scene;

#pragma mark -
#pragma mark Info Message

-(void) showInfoMessage: (NSString *) message position: (CGPoint) position duration: (float) duration;

-(void) showInfoMessage: (NSString *) message position: (CGPoint) position duration: (float) duration selector: (SEL) selector;

-(void) hideInfoMessage;

@end
