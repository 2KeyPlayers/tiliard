//
//  Tile.m
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/26/10.
//  Copyright 2010-2011 by 2 Key Players. All rights reserved.
//


#import "Tile.h"
#import "Game.h"
#import "cocos2d.h"


@implementation Tile

@synthesize number = _number;
@synthesize type = _type;
@synthesize powerUp = _powerUp;
@synthesize color = _color;
@synthesize positionOnTable = _positionOnTable;

@synthesize sprite = _sprite;
@synthesize backgroundSprite = _backgroundSprite;

@synthesize state = _state;
@synthesize movesLeft = _movesLeft;
@synthesize direction = _direction;

@synthesize collisionWithNumber = _collisionWithNumber;
@synthesize collisionsCount = _collisionsCount;

@synthesize inactiveTime = _inactiveTime;
//@synthesize animation = _animation;

static BOOL _trainingMode;

static char _tileSet;

static float _moveDuration;

#pragma mark -
#pragma mark Initializers

+(void)initialize {
	
	_trainingMode = NO;
	_tileSet = kTileSetTraining;
	_moveDuration = kDefaultMoveDuration;
}

+(id) tileWithNumber: (NSInteger) number onPosition: (PositionOnTable) positionOnTable {
	
	return [[[self alloc] initWithNumber: number onPosition: positionOnTable] autorelease];
}

-(id) init {

	NSAssert(NO, @"Tile: Init not supported.");
	[self release];
	return nil;	
}

-(id) initWithNumber: (NSInteger) number onPosition: (PositionOnTable) positionOnTable {  
	
	if ((self = [super init])) {
		
		_hole = NO;
		_powerUp = kPowerUpNone;
		_type = kTileTypeNormal;

		_positionOnTable = positionOnTable;
		
		//[self setNumber: number];
		_number = number;
		_color = 0;
		
		if (_number < 0) {
			if (_number == (-1)) {

				_number = 0;
				_hole = YES;

				_backgroundSprite = [[CCSprite spriteWithSpriteFrameName: @"gpHole.png"] retain];
				_backgroundSprite.position = [self convertPoint: [self calculateSpritePosition: _positionOnTable]];
			}
			else {
				
				NSInteger hundreds = abs(_number) / 100;
				_color = hundreds % kTileColorMAX;
				
				_powerUp = abs(_number) - (hundreds * 100);
				_number = 0;
				
				NSString *frameName;
				if (_powerUp < 20) { // arrow
					frameName = @"pu10.png";
				}
				else {
					frameName = [NSString stringWithFormat: @"pu%d.png", _powerUp];
				}
				_backgroundSprite = [[CCSprite spriteWithSpriteFrameName: frameName] retain];
				_backgroundSprite.color = [[Game sharedGame] tileColor: _color];
				_backgroundSprite.position = [self convertPoint: [self calculateSpritePosition: _positionOnTable]];
				_backgroundSprite.opacity = (_color > 0 ? 128 : 77);
				
				// rotate arrow into the right position
				if (_powerUp < 20) {
					_backgroundSprite.rotation = (_powerUp - 10) * 45.0f;
				}
				// fix position for +- power ups
				if (_powerUp > 30 && _powerUp < 50) {
					_backgroundSprite.position = ccp(_backgroundSprite.position.x - 1, _backgroundSprite.position.y);
				}
			}
		}
		else if (number > 0) {
		
			NSString *frameName;
			if (_number == kCueTile) {
				frameName = [NSString stringWithFormat: @"%d.png", _number];
				if (_tileSet == kTileSetColor) {
					frameName = [NSString stringWithFormat: @"%dE.png", _number];
				}
			}
			else {
				frameName = [NSString stringWithFormat: @"%d%c.png", _number, _tileSet];
			}
			
			_sprite = [[CCSprite spriteWithSpriteFrameName: frameName] retain];
			_sprite.position = [self convertPoint: [self calculateSpritePosition: _positionOnTable]];
			
			_startPosition = _endPosition = _sprite.position;
			_distance = CGPointZero;
			
			//[self addAnimation];
		}
		
		_state = kTileStateStanding;
		_movesLeft = 0;
		_direction.x = _direction.y = 0;
		
		_collisionWithNumber = 0;
		_collisionsCount = 0;
		
		_dt = 0.0f;
		_inactiveTime = 0.0f;
	}
	return self;
}

#pragma mark -
#pragma mark Attribute Modifiers

+(void) setTrainingMode: (BOOL) trainingMode {
	
	_trainingMode = trainingMode;
}

+(void) setTileSet: (char) tileSet {
	
	_tileSet = tileSet;
	
	/*if (_sprite) {
		NSString *frameName = [NSString stringWithFormat: @"%d%c.png", _number, _tileSet];
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName];
		[_sprite setDisplayFrame: frame];
	}*/
}

+(void) setMoveDuration: (float) duration {
	
	_moveDuration = duration;
}

-(BOOL) setNumber: (NSInteger) number {
	
	BOOL spriteCreated = NO;
	
	if (number > 0) {
	
		_number = number;
		
		NSString *frameName;
		if (_number == kCueTile) {
			frameName = [NSString stringWithFormat: @"%d.png", _number];
			if (_tileSet == kTileSetColor) {
				frameName = [NSString stringWithFormat: @"%dE.png", _number];
			}
		}
		else {
			frameName = [NSString stringWithFormat: @"%d%c.png", _number, _tileSet];
		}
		
		if (_sprite) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName];
			[_sprite setDisplayFrame: frame];
		}
		else {
			_sprite = [[CCSprite spriteWithSpriteFrameName: frameName] retain];
			spriteCreated = YES;
		}
		_sprite.position = [self convertPoint: [self calculateSpritePosition: _positionOnTable]];
		
		_startPosition = _endPosition = _sprite.position;
		_distance = CGPointZero;
		
		//[self addAnimation];
	}
	
	_state = kTileStateStanding;
	_movesLeft = 0;
	_direction.x = _direction.y = 0;
	
	_collisionWithNumber = 0;
	_collisionsCount = 0;
	
	_dt = 0.0f;
	_inactiveTime = 0.0f;
	
	return spriteCreated;
}

-(void) setSpritePosition: (PositionOnTable) positionOnTable {

	if (_sprite) {
		_sprite.position = [self convertPoint: [self calculateSpritePosition: positionOnTable]];
	}
}

-(void) setVisible: (BOOL) visible {

	if (_sprite) {
		_sprite.visible = visible;
	}
	if (_backgroundSprite) {
		_backgroundSprite.visible = visible;
	}
}

-(void) changeShot: (Shot) newShot {

	if (_number == kCueTile) {
		NSString *frameName = [NSString stringWithFormat: @"%d.png", _number];
		if (_tileSet == kTileSetColor) {
			frameName = [NSString stringWithFormat: @"%dE.png", _number];
		}
		
		if (newShot == kShotForwardRotation) {
			frameName = [NSString stringWithFormat: @"%d_1.png", _number];
			if (_tileSet == kTileSetColor) {
				frameName = [NSString stringWithFormat: @"%dE_1.png", _number];
			}
		}
		else if (newShot == kShotBackwardRotation) {
			frameName = [NSString stringWithFormat: @"%d_2.png", _number];
			if (_tileSet == kTileSetColor) {
				frameName = [NSString stringWithFormat: @"%dE_2.png", _number];
			}
		}
		/* UPDATE ver. 1.1
		else if (newShot == kShotSideRotation) {
			frameName = [NSString stringWithFormat: @"%d_3.png", _number, _tileSet];
		}*/
		
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName];
		[_sprite setDisplayFrame: frame];
	}
}

-(void) makeTransparent {

	if (_sprite) {
		_sprite.opacity = 32;
	}
}

-(void) makeSemiTransparent {

	if (_sprite) {
		_sprite.opacity = 128;
	}
}

-(void) makeSolid {

	if (_sprite) {
		_sprite.opacity = 255;
	}
}

-(void) inCollisionWith: (Tile *) tile {

	if (_collisionWithNumber == tile.number) {
		_collisionsCount++;
	}
	else {
		_collisionWithNumber = tile.number;
		_collisionsCount = 1;
	}
}

-(void) resetCollision {
	
	_collisionsCount = 0;
	_collisionWithNumber = 0;
}

#pragma mark -
#pragma mark Copy And Clear

-(void) copyTile: (Tile *) tile {
	
	_number = tile.number;
	_type = tile.type;
	
	_state = tile.state;
	_movesLeft = tile.movesLeft;
	_direction = tile.direction;
	
	_collisionWithNumber = tile.collisionWithNumber;
	_collisionsCount = tile.collisionsCount;
	
	_sprite = tile.sprite;
	[_sprite retain];

	_startPosition = _sprite.position;
	_endPosition = [self convertPoint: [self calculateSpritePosition: _positionOnTable]];
	_distance = ccpSub(_endPosition, _startPosition);
	
	/*if (tile.animation) {
		_animation = tile.animation;
		[_animation retain];
	}*/
}

-(void) copyTileAndPrepareMovement: (Tile *) tile {
	
	[self copyTile: tile];
	_sprite.position = tile.sprite.position;
}

-(void) copyTileAndPrepareMovementFromDirection: (Tile *) tile {
	
	[self copyTile: tile];
	
	PositionOnTable startPositionOnTable = _positionOnTable;
	startPositionOnTable.x = startPositionOnTable.x + (-1) * _direction.x;
	startPositionOnTable.y = startPositionOnTable.y + (-1) * _direction.y;
	
	_startPosition = [self convertPoint: [self calculateSpritePosition: startPositionOnTable]];
	_endPosition = [self convertPoint: [self calculateSpritePosition: _positionOnTable]];
	_distance = ccpSub(_endPosition, _startPosition);
	
	_sprite.position = _startPosition;
}

-(void) clearTile {
	
	_number = 0;
	
	_state = kTileStateStanding;
	_movesLeft = 0;
	_direction.x = _direction.y = 0;
	
	_collisionWithNumber = 0;
	_collisionsCount = 0;

	if (_sprite) {
		[_sprite release];
		_sprite = nil;
	}
	/*if (_animation) {
		[_animation release];
		_animation = nil;
	}*/
	
	_inactiveTime = 0.0f;
}

-(void) clearTileAndPrepareMovement {
	
	NSInteger number = _number;
	
	PositionOnTable endPositionOnTable = _positionOnTable;
	endPositionOnTable.x = endPositionOnTable.x + _direction.x;
	endPositionOnTable.y = endPositionOnTable.y + _direction.y;
	
	//_startPosition = _sprite.position;
	_startPosition = [self convertPoint: [self calculateSpritePosition: _positionOnTable]];
	_endPosition = [self convertPoint: [self calculateSpritePosition: endPositionOnTable]];
	_distance = ccpSub(_endPosition, _startPosition);
	
	[self clearTile];
	
	// create sprite only for movement
	NSString *frameName;
	if (_number == kCueTile) {
		frameName = [NSString stringWithFormat: @"%d.png", number];
		if (_tileSet == kTileSetColor) {
			frameName = [NSString stringWithFormat: @"%dE.png", _number];
		}
	}
	else {
		frameName = [NSString stringWithFormat: @"%d%c.png", number, _tileSet];
	}
	
	_sprite = [[CCSprite spriteWithSpriteFrameName: frameName] retain];
	_sprite.position = _startPosition;
	
	_state = kTileStateOneMoveOnly;
	_dt = 0.0f;
}

#pragma mark -
#pragma mark State Checkers

-(BOOL) isPlayable {
	
	return ((_number > 0) && (_number < 16));
}

-(BOOL) isCue {

	return (_number == kCueTile);
}

-(BOOL) isHole {
	
	return _hole;
}

-(BOOL) isEmpty {
	
	return (_number == 0);
}

-(BOOL) isPowerUp {

	return (_powerUp != kPowerUpNone);
}

-(BOOL) hasMovesLeft {
	
	return (_movesLeft > 0);
}

-(BOOL) hasNoMovesLeft {
	
	return ((_movesLeft == 0) || (_hole && _trainingMode));
	//return (_movesLeft == 0);
}

-(BOOL) isStanding {
	
	return (_state == kTileStateStanding);
}

-(BOOL) shouldMove {
	
	return (_state == kTileStateShouldMove);
}

-(BOOL) isMoving {
	
	return ((_state == kTileStateMoving) || (_state == kTileStateOneMoveOnly));
}

-(BOOL) isBeingPotted {
	
	return (_state == kTileStatePotted);
}

-(BOOL) isDeadlock {

	return (_collisionsCount > 4);
}

#pragma mark -
#pragma mark Movement

-(void) startMovingInDirection: (Direction) direction {
	
	_state = kTileStateShouldMove;
	_direction = direction;
	_movesLeft = _number;
}

-(void) startMovingInDirection: (Direction) direction withShot: (Shot) shot {
	
	_state = kTileStateShouldMove;
	_direction = direction;
	
	NSInteger shotCoef = 1; // ShotStraight
	if (shot == kShotForwardRotation) {
		shotCoef = 2;
	}

	_movesLeft = (_number * shotCoef);

	if (shot == kShotBackwardRotation) {
		_movesLeft = (_movesLeft / 2.0f + 0.5f);
	}
}

-(BOOL) checkColor: (Tile *) tile {
	
	if (_color > 0) {
		return (_color == (tile.number % kTileColorMAX));
	}
	return YES;
}

-(BOOL) checkColor {
	
	return [self checkColor: self];
}

-(NSInteger) prepareMove {

	if ([self checkColor]) {
		if (_powerUp == kPowerUpNone) {
			// do nothing
		}
		else if (_powerUp == kPowerUpMoveUp) {
			_direction.x = 0;
			_direction.y = 1;
		}
		else if (_powerUp == kPowerUpMoveUpRight) {
			_direction.x = 1;
			_direction.y = 1;
		}
		else if (_powerUp == kPowerUpMoveRight) {
			_direction.x = 1;
			_direction.y = 0;
		}
		else if (_powerUp == kPowerUpMoveDownRight) {
			_direction.x = 1;
			_direction.y = -1;
		}
		else if (_powerUp == kPowerUpMoveDown) {
			_direction.x = 0;
			_direction.y = -1;
		}
		else if (_powerUp == kPowerUpMoveDownLeft) {
			_direction.x = -1;
			_direction.y = -1;
		}
		else if (_powerUp == kPowerUpMoveLeft) {
			_direction.x = -1;
			_direction.y = 0;
		}
		else if (_powerUp == kPowerUpMoveUpLeft) {
			_direction.x = -1;
			_direction.y = 1;
		}
	}
	
	return _powerUp;
}

-(BOOL) beforeMove: (Tile *) tile {

	if ([self checkColor: tile]) {
		if (_powerUp == kPowerUpGhost) {
			return NO;
		}
	}
	
	return YES;
}

-(void) move {
	
	_state = kTileStateMoving;
	_dt = 0.0f;
	
	if (_movesLeft > 0) {
		_movesLeft = _movesLeft - 1;
	}
	
	/*if (_animation && _animation.running) {
		[self stopAnimation];
	}*/
}

-(BOOL) afterMove {

	if ([self checkColor]) {
		if (_powerUp == kPowerUpStop) {
			_movesLeft = 0;
		}
		else if (_powerUp == kPowerUpPlus) {
			_type = kTileTypeAddable;
		}
		else if (_powerUp == kPowerUpMinus) {
			_type = kTileTypeSubtractable;
		}
		else if (_powerUp == kPowerUpEquals) {
			_type = kTileTypeEqualable;
		}
		else if (_powerUp == kPowerUpSign) {
			_type = kTileTypeSignable;
		}
		/*else if (_powerUp == kPowerUpTheEnd) {
			return NO;
		}*/
		
		if (_powerUp > 40) {
			_movesLeft = MAX(_movesLeft - (_powerUp - 40), 0);
		}
		else if (_powerUp > 30) {
			_movesLeft = _movesLeft + (_powerUp - 30);
		}
	}
	
	return YES;
}

-(void) stopMoving {
	
	_state = kTileStateStanding;
	if (_hole) {
		_state = kTileStatePotted;
	}
	
	_type = kPowerUpNone;
	
	_movesLeft = 0;
	_direction.x = _direction.y = 0;
	
	//_collisionWithNumber = 0;
	//_collisionsCount = 0;
	
	_inactiveTime = 0.0f;
}

-(void) setInfiniteMoves {
	
	_movesLeft = (-1);
}

#pragma mark -
#pragma mark Helpers

-(CGPoint) convertPoint: (CGPoint) point {
	
	Game *game = [Game sharedGame];
	
	if (game.iPad) {
		return ccp(32 + (point.x * 2), 64 + (point.y * 2));
	}
	else if (game.iPhone5) {
		return ccp(44 + point.x, point.y);
	}
	return point;
}

-(CGPoint) calculateSpritePosition: (PositionOnTable) positionOnTable {
	
	return ccp((positionOnTable.x * kTileSize) + (kTileSize / 2), ((positionOnTable.y + 1) * kTileSize) + (kTileSize / 2));
}

#pragma mark -
#pragma mark Update

-(BOOL) update: (ccTime) dt skip: (BOOL) skip {

	BOOL finished = NO;
	
	// movement
	if ((_state == kTileStateMoving) || (_state == kTileStateOneMoveOnly)) {
		_dt = _dt + dt;
		if (!skip && _dt <= _moveDuration) {
			_sprite.position = ccp(_startPosition.x + _distance.x / _moveDuration * _dt, _startPosition.y + _distance.y / _moveDuration * _dt);
		}
		else {
			if (_state == kTileStateMoving) {
				_state = kTileStateShouldMove;
				_dt = 0.0f;
			
				// !!! _sprite.position = _endPosition;
				_sprite.position = [self convertPoint: [self calculateSpritePosition: _positionOnTable]];
			
				if ([self hasNoMovesLeft]) {
				
					[self stopMoving];
				}
			}
			/*else { // kTileStateMovingOnlyOnce = temporary tile used for movement out of the table
				_state = kTileStateStanding;
				//[self clearTile];
				finished = YES;
			}*/
		}
	}
	// pot
	else if (_state == kTileStatePotted) {
		_dt = _dt + dt;
		if (!skip && _dt < _moveDuration) { //kPotDuration
			_sprite.scale = (1.0f - 1.0f / _moveDuration * _dt);
			_sprite.opacity = (255 - 255 / _moveDuration * _dt);
		}
		else {
			_dt = 0.0f;
			_sprite.opacity = 0;
			_state = kTileStateStanding;
			finished = YES;
		}
	}
	// idle animation
	/*else if (_animation && _animation.active) {
		if (_animation.running) {
			BOOL running = [_animation run: dt];
			if (!running) {
				[self stopAnimation];
				finished = YES;
			}
		}
		else {
			_inactiveTime = _inactiveTime + dt;
			
			if (_inactiveTime >= _animation.delay) {
				[_animation start];
			}
		}
	}*/
	
	return finished;
}

/*#pragma mark -
#pragma mark Animations

-(void) addAnimation {

	// clear previous animation (if any)
	if (_animation) {
		[_animation release];
		_animation = nil;
	}
	
	if (_type == kTileTypeNormal) {
		return;
	}
	
	if (_type == kTileTypeDraggable) {
		_animation = [[TileAnimationShake tileAnimationWithSprite: _sprite] retain];
	}
	else if (_type == kTileTypeChangeable) {
		_animation = [[TileAnimationRotateL tileAnimationWithSprite: _sprite] retain];
	}
	else if (_type == kTileTypeAddable) {
		_animation = [[TileAnimationBounceUD tileAnimationWithSprite: _sprite] retain];
	}
	else if (_type == kTileTypeSubtractable) {
		_animation = [[TileAnimationBounceLR tileAnimationWithSprite: _sprite] retain];
	}
	else if (_type == kTileTypeDestructable) {
		_animation = [[TileAnimationZoomOut tileAnimationWithSprite: _sprite] retain];
	}
	else if (_type == kTileTypeShrinking) {
		_animation = [[TileAnimationZoomIn	tileAnimationWithSprite: _sprite] retain];
	}
}

-(void) activateAnimation: (BOOL) yesNo {

	if (_animation) {
		if (!yesNo) {
			[_animation stop];
			//_inactiveTime = 0.0f;
		}
		_animation.active = yesNo;
	}
}

-(void) stopAnimation {
	
	_inactiveTime = 0.0f;
	[_animation stop];
}*/

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	[_sprite release];
	_sprite = nil;

	[_backgroundSprite release];
	_backgroundSprite = nil;
	
	/*[_animation release];
	_animation = nil;*/
	
	[super dealloc];
}

@end
