//
//  Tile.h
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/26/10.
//  Copyright 2010-2011 by 2 Key Players. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CCSprite.h"
//#import "TileAnimation.h"

//#define kTileSize ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 64 : 32)
#define kTileSize 32

#define kCueTile 16

#define kDefaultMoveDuration 0.3
//#define kDefaultPotDuration 0.3


typedef struct _PositionOnTable {
	NSInteger x;
	NSInteger y;
} PositionOnTable;

typedef struct _Direction {
	NSInteger x;
	NSInteger y;
} Direction;

typedef enum _TileSet {
	kTileSetTraining = 'A',
	kTileSetPower = 'B',
	kTileSetDirection = 'C',
	kTileSetSpin = 'D',
	kTileSetColor = 'E',
	kTileSetMAX
} TileSet;

typedef enum _TileType {
	kTileTypeNormal = 0,
	kTileTypeAddable,
	kTileTypeSubtractable,
	kTileTypeEqualable,
	kTileTypeSignable,
	/*kTileTypeHeartable,
	kTileTypeSwapable,
	kTileTypeRandomable,
	kTileTypeDestructable,
	kTileTypeShrinking,*/
	kTileTypeMAX
} TileType;

typedef enum _TileState {
	kTileStateStanding,
	kTileStateShouldMove,
	kTileStateMoving,
	kTileStateOneMoveOnly,
	kTileStatePotted
} TileState;

typedef enum _Shot {
	kShotStraight,
	kShotForwardRotation,
	kShotBackwardRotation,
	kShotSideRotation
} Shot;

typedef enum _PowerUp {
	kPowerUpNone = 0,
	kPowerUpMoveUp = 10,
	kPowerUpMoveUpRight,
	kPowerUpMoveRight,
	kPowerUpMoveDownRight,
	kPowerUpMoveDown,
	kPowerUpMoveDownLeft,
	kPowerUpMoveLeft,
	kPowerUpMoveUpLeft,
	kPowerUpStop = 20,
	kPowerUpGhost,
	kPowerUpPlus = 50,
	kPowerUpMinus,
	kPowerUpEquals,
	kPowerUpSign,
	kPowerUpRestart = 60,
	kPowerUpHeart = 70,
	kPowerUpSwap,
	kPowerUpPortal,
	/*kPowerUpRandom,*/
	kPowerLight,
	kPowerInvisibility,
	/*kPowerUpBomb,*/
} PowerUp;

typedef enum _TileColor {
	kTileColorBlack = 0,
	kTileColorYellow,
	kTileColorBlue,
	kTileColorRed,
	kTileColorPurple,
	kTileColorOrange,
	kTileColorGreen,
	kTileColorBrown,
	kTileColorMAX
} TileColor;


@interface Tile : NSObject {
	
	BOOL _hole;
	
	NSInteger _type;
	
	NSInteger _powerUp;
	
	NSInteger _number;
	
	NSInteger _color;
	
	PositionOnTable _positionOnTable;
	
	CCSprite *_sprite;
	
	CCSprite *_backgroundSprite;
	
	/* Movement */
	
	NSInteger _state;
	
	CGPoint _startPosition;
	
	CGPoint _endPosition;
	
	CGPoint _distance;
	
	ccTime _dt;
	
	NSInteger _movesLeft;
	
	Direction _direction;
	
	/* Deadlock detection */
	
	NSInteger _collisionWithNumber;
	
	NSInteger _collisionsCount;
	
	/* Idle animation */
	
	ccTime _inactiveTime;
	
	//TileAnimation *_animation;
}

@property (nonatomic, readonly) NSInteger number;
@property (nonatomic, readonly) NSInteger type;
@property (nonatomic, readonly) NSInteger powerUp;
@property (nonatomic, readonly) NSInteger color;
@property (nonatomic, readonly) PositionOnTable positionOnTable;

@property (nonatomic, readonly) CCSprite *sprite;
@property (nonatomic, readonly) CCSprite *backgroundSprite;

@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSInteger movesLeft;
@property (nonatomic, assign) Direction direction;

@property (nonatomic, readonly) NSInteger collisionWithNumber;
@property (nonatomic, readonly) NSInteger collisionsCount;

@property (nonatomic, readonly) ccTime inactiveTime;
//@property (nonatomic, readonly) TileAnimation *animation;

#pragma mark -
#pragma mark Initializers

+(id) tileWithNumber: (NSInteger) number onPosition: (PositionOnTable) positionOnTable;

-(id) initWithNumber: (NSInteger) number onPosition: (PositionOnTable) positionOnTable;

#pragma mark -
#pragma mark Attribute Modifiers

+(void) setTrainingMode: (BOOL) trainingMode;

+(void) setTileSet: (char) tileSet;

+(void) setMoveDuration: (float) duration;

-(BOOL) setNumber: (NSInteger) number;

-(void) setSpritePosition: (PositionOnTable) positionOnTable;

-(void) setVisible: (BOOL) visible;

-(void) changeShot: (Shot) shot;

-(void) makeTransparent;

-(void) makeSemiTransparent;

-(void) makeSolid;

-(void) inCollisionWith: (Tile *) tile;

-(void) resetCollision;

#pragma mark -
#pragma mark Copy And Clear

-(void) copyTile: (Tile *) tile;

-(void) copyTileAndPrepareMovement: (Tile *) tile;

-(void) copyTileAndPrepareMovementFromDirection: (Tile *) tile;

-(void) clearTile;

-(void) clearTileAndPrepareMovement;

#pragma mark -
#pragma mark State Checkers

-(BOOL) isPlayable;

-(BOOL) isCue;

-(BOOL) isHole;

-(BOOL) isEmpty;

-(BOOL) isPowerUp;

-(BOOL) hasMovesLeft;

-(BOOL) hasNoMovesLeft;

-(BOOL) isStanding;

-(BOOL) shouldMove;

-(BOOL) isMoving;

-(BOOL) isBeingPotted;

-(BOOL) isDeadlock;

#pragma mark -
#pragma mark Movement

-(void) startMovingInDirection: (Direction) direction;

-(void) startMovingInDirection: (Direction) direction withShot: (Shot) shot;

-(BOOL) checkColor: (Tile *) tile;

-(NSInteger) prepareMove;

-(BOOL) beforeMove: (Tile *) tile;

-(void) move;

-(BOOL) afterMove;

-(void) stopMoving;

-(void) setInfiniteMoves;

#pragma mark -
#pragma mark Helpers

-(CGPoint) calculateSpritePosition: (PositionOnTable) positionOnTable;

#pragma mark -
#pragma mark Update

-(BOOL) update: (ccTime) dt skip: (BOOL) skip;

/*#pragma mark -
#pragma mark Animations

-(void) addAnimation;

-(void) activateAnimation: (BOOL) yesNo;

-(void) stopAnimation;*/

@end
