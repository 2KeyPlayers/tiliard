//
//  MenuScene.h
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/01/11.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "BaseScene.h"
#import <StoreKit/StoreKit.h>

#define kShowTileInterval 2.0f


enum {
	kAlertEditor = 0,
	kAlertGameCenter,
	kAlertResetProgress,
	kAlertResetProgressOnCloud,
	kAlertLanguageChange,
	kAlertTileSet
};


@interface MainMenu : Base <SKStoreProductViewControllerDelegate> {

	BOOL _languageChanged;
	
	BOOL _tileSetAlert;
	
	NSInteger _more;
	
	NSInteger _tileNumber;
	
	char _tileSet;
	
	PositionOnTable _tilePosition;
	
	Direction _tileDirection;
	
	/* Update */
	
	BOOL _updateTable;
	
	ccTime _showTileInterval;
	
	CCAction *_showTile;
}

#pragma mark -
#pragma mark Scene Creator

+(id) scene;

#pragma mark -
#pragma mark Helpers

-(void) slideMenu: (NSInteger) direction;

-(void) back;

@end
