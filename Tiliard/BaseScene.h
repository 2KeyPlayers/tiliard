//
//  BaseScene.h
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/26/10.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "Tile.h"
#import "Game.h"

#define kTableWidth 15
#define kTableHeight 8

#define kTablePosition ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 64 : 32)

#define kMenuFadeDuration 0.4f


typedef enum _Tags {
	// used as tags and z-index
	kBackground = 0,
	kBorderLeft,
	kBorderRight,
	kPlayground,
	kInfo,
	kTable,
	kButton,
	kMenu,
	kGlow,
	//kPromo,
	// these are only used as tags
	kUpperNotation,
	kLowerNotation,
	kLeftNotation,
	kRightNotation,
	kTimeoutButton, //kPauseButton,
	kUndoButton,
	kRanksButton,
	kRank1,
	kRank2,
	kRank3,
	kScoreLabel,
	kScore,
	kUpperTable,
	kLowerTable,
	kTableFill,
    kTableShadow,
	kTiliard,
	kPaused,
	kRank,
	kAward1,
	kAward2,
	kAimer,
	// Menu
	kMenu2kp,
	kMenuPr,
	kMenuTile,
	kMenuPlus,
	kMenuCreditsLabel,
	kMenuMainLabel,
	kMenuOptionsLabel,
	kMenuCloudLabel,
	kMenuTilehallsLabel,
	kMenuTablesLabel,
	kMenuTimeOutLabel,
	kMenuTableClearedLabel,
	kMenuButtonPlay,
	kMenuButtonCredits,
	kMenuButtonOptions,
	kMenuButtonEditor,
	kMenuButtonGameCenter,
	kMenuButtonBack,
	kMenuTheMakers,
	kMenuButtonClothColor,
	kMenuButtonMusic,
	kMenuButtonSound,
	kMenuButtonLanguage,
	kMenuButtonResetProgress,
	kMenuButtonMore,
	kMenuButtonShare,
	kMenuButtonGiftRate,
	kMenuButtonTileSet,
	kMenuButtonTilehall1,
	kMenuButtonTilehall2,
	kMenuButtonTilehall3,
	kMenuButtonTilehall4,
	kMenuButtonTilehall5,
	kMenuButtonTilehallComingSoon,
	kMenuButtonTable1,
	kMenuButtonTable2,
	kMenuButtonTable3,
	kMenuButtonTable4,
	kMenuButtonTable5,
	kMenuButtonTable6,
	kMenuButtonTable7,
	kMenuButtonTable8,
	kMenuButtonTable9,
	kMenuButtonTable10,
	kMenuButtonQuit,
	kMenuButtonDetails,
	kMenuButtonPauseDetails,
	kMenuButtonPrevious,
	kMenuButtonSkipOrNext,
	kMenuButtonRestart,
	kMenuButtonRetry,
	kMenuButtonTweet,
	kMenuButtonContinue,
	kMenuButtonPromo,
	kMenuButtonPromoPager,
	kMenuButtonAppStore,
	kMenuButtonMail,
	kMenuButtonTwitter,
	kMenuButtonFacebook,
	// Rank shots
	kRankShot = 100,
	// Info
	kInfoSprite = 200, // must be last
	kInfoIcon,
	kInfoLabel
} Tags;

enum {
	kGlowDisabled,
	kGlowMenu,
	kGlowGame
};


@interface Base : CCLayerColor {
	
	CCSpriteBatchNode *_spriteBatch;
	
	CCAction *_glow;
	
	/* Table */
	
	NSMutableArray *_table;
	
	NSMutableArray *_playableTiles;
	
	/* Menu */
	
	CCMenu *_menu;
	
	/* Screen Capture */
	
	BOOL _recording;
	
	NSInteger _recordingFrameNum;
	
	int _framebufferWidth;
	
	int _framebufferHeight;
	
	/* Update */
	
	BOOL _ready;
	
	ccTime _updateTime;
	
	NSInteger _glowType;
	
	ccTime _timeBetweenGlows;
}

//@property (nonatomic, assign) BOOL recording;

-(void) ready;

#pragma mark -
#pragma mark Loading

-(void) showActivityIndicator;

-(void) hideActivityIndicator;

-(void) loading: (NSString *) selectorString;

#pragma mark -
#pragma mark Content Builders

-(void) addBackground;

-(void) addPlayground;

-(void) addMenu;

-(void) setTableColor;

#pragma mark -
#pragma mark Table Movement

-(void) openTable: (SEL) selector;

-(void) closeTable: (SEL) selector;

-(void) closeTableAndLoad: (NSString *) selectorString;

-(void) openTableHalf: (SEL) selector;

-(void) closeTableHalf: (SEL) selector;

-(void) closeTableHalfAndLoad: (NSString *) selectorString;

-(void) openTableHalfly: (SEL) selector;

-(void) closeTableHalfly: (SEL) selector;

#pragma mark -
#pragma mark Helpers

-(void) hideMenu;

-(void) showMenu;

#pragma mark -
#pragma mark Converters

-(NSString *) convertFileName: (NSString *) name extension: (NSString *) extension;

-(CGPoint) convertPoint: (CGPoint) point;

-(CGPoint) convertPoint: (CGPoint) point offset: (CGPoint) offset;

-(CGPoint) convertPoint: (CGPoint) point iPadOffset: (CGPoint) iPadOffset iPhone5Offset: (CGPoint) iPhone5Offset;

-(float) convertFontSize: (float) fontSize;

-(PositionOnTable) convertLocationToTablePosition: (CGPoint) location;

-(PositionOnTable) convertLocationToMovingTablePosition: (CGPoint) location;

-(NSString *) convertPositionOnTableIntoNotations: (PositionOnTable) positionOnTable;

#pragma mark -
#pragma mark Playable Tiles

-(void) addPlayableTile: (Tile *) tile;

-(void) replacePlayableTile: (Tile *) tile withTile: (Tile *) newTile;

-(void) removePlayableTile: (Tile *) tile;

-(void) removeAllPlayableTiles;

-(void) sortPlayableTiles;

-(BOOL) existsPlayableTileWithNumber: (NSInteger) number;

-(void) showTiles;

-(void) hideTiles;

#pragma mark -
#pragma mark Tile Movement

-(Tile *) getTileOnPosition: (PositionOnTable) positionOnTable;

-(BOOL) moveTile: (Tile *) tile;

//-(PositionOnTable) moveTileAndReturnPositionOnTable: (Tile *) tile;

-(Direction) directionForPosition: (PositionOnTable) currentPositionOnTable direction: (Direction) currentDirection;

-(void) handleReboundsForTile: (Tile *) tile;

-(BOOL) handleCollisionsForTile: (Tile *) tile;

#pragma mark -
#pragma mark Glow

-(void) hideGlow;

-(void) setMenuGlow;

-(void) setGameGlow;

-(CGPoint) getGlowPosition;

#pragma mark -
#pragma mark Screen Recording

//-(void) record: (ccTime) dt;

#pragma mark -
#pragma mark Update

-(void) update: (ccTime) dt;

@end


@interface MenuItemSprite : CCMenuItemSprite {

	NSString *_frameName;
	
	BOOL _isSelectionColorSet;
	
	ccColor3B _selectionColor;
}

+(id) itemWithSpriteFrameName: (NSString *) frameName target: (id) target selector: (SEL) selector;

-(id) initWithSpriteFrameName: (NSString *) frameName target: (id) target selector: (SEL) selector;

-(void) setSelectionColor: (ccColor3B) color;

-(void) refreshSprite;

@end
