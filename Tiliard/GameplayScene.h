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


enum {
	kButtonDefault = 0,
	kButtonPause,
	kButtonUndo,
	kButtonRanks,
	//kButtonScore
};

enum {
	kActionDefault = 0,
	kActionTap,
	kActionSwipe,
	kActionSet,
	kActionShot,
	kActionRotation,
	kActionAiming,
	kActionUndo,
	kActionRanks,
	//kActionHideAiming
};

enum {
	kAlertTableRecord = 0
};

enum {
	kInfoTypeHint = 0,
	kInfoTypeDetail,
	kInfoTypeError
};


@interface Gameplay : Base {
	
	UIViewController *_viewController;

	/* Buttons */
	
	BOOL _ignore;
	
	NSInteger _button;
	
	BOOL _shake;
	
	NSInteger _action;
	
	BOOL _doubleTap;
	
	CGPoint _tapPoint;
	
	/* Cue tile */
	
	BOOL _cueTileIsSet;
	
	BOOL _cueShotSelection;
	
	Tile *_cueTile;
	
	PositionOnTable _cueTilePosition;
	
	/* Update */
	
	BOOL _movementOnTable;
	
	BOOL _skipMovement;
	
	BOOL _pottingOnTable;
	
	BOOL _calculateMovement;
	
	/* Undo */
	
	BOOL _deadlock;
	
	BOOL _undoPossible;
	
	NSMutableArray *_undoLayouts;
	
	TableStats _undoStats[kMaximumSolutionShots];
	
	/* Aiming Assistent */
	
	//Tile *_aimerTile;
	
	PositionOnTable _aimerPosition;
	
	Direction _aimerDirection;
	
	/* Game Center */
	
	NSInteger _tilesForCentury;
	
	float _tilesForWillieM;
	
	/* Others */
	
	BOOL _improvedResult;
	
	BOOL _tableRecord;
	
	NSMutableArray *_solution;
	
	NSInteger _hint;
	
	NSInteger _detail;
}

#pragma mark -
#pragma mark Scene Creator

+(id) scene;

#pragma mark -
#pragma mark Menu System

-(void) showMenu;

#pragma mark -
#pragma mark Info Message

-(void) showInfoMessage: (NSString *) message type: (NSInteger) type position: (CGPoint) position duration: (float) duration;

-(void) showInfoMessage: (NSString *) message type: (NSInteger) type position: (CGPoint) position duration: (float) duration selector: (SEL) selector;

-(void) hideInfoMessage;

//-(void) hideInfoMessage: (SEL) selector;

#pragma mark -
#pragma mark Hints

-(void) showHint;

-(void) hideHint;

#pragma mark -
#pragma mark Table Info

-(void) showEndOfGame;

-(void) showRanks: (BOOL) show;

#pragma mark -
#pragma mark Tile Handling

-(void) rackUpTiles: (NSArray *) layout;

-(void) clearTiles;

-(BOOL) canTileBePlayed: (Tile *) tile;

-(Tile *) findClosestPlayableTile: (CGPoint) location;

#pragma mark -
#pragma mark Cue Tile Handling

-(BOOL) canBeACueTile: (Tile *) tile;

-(void) clearCueTile;

-(void) startMovementFromCueTile: (Tile *) tile;

-(void) playCueTile;

#pragma mark -
#pragma mark Undo

-(void) prepareUndo;

#pragma mark -
#pragma mark Update

-(void) updateRankShots: (BOOL) ranks;

-(void) updateScore;

@end
