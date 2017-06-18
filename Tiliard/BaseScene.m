//
//  BaseScene.m
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/26/10.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#import "BaseScene.h"
#import "GameplayScene.h"


@implementation Base

//@synthesize recording = _recording;

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super initWithColor: ccc4(0, 0, 0, 255)])) {
		
		_table = [[NSArray arrayWithObjects:
				   [NSMutableArray arrayWithCapacity: 15],
				   [NSMutableArray arrayWithCapacity: 15],
				   [NSMutableArray arrayWithCapacity: 15],
				   [NSMutableArray arrayWithCapacity: 15],
				   [NSMutableArray arrayWithCapacity: 15],
				   [NSMutableArray arrayWithCapacity: 15],
				   [NSMutableArray arrayWithCapacity: 15],
				   [NSMutableArray arrayWithCapacity: 15],
				   nil] retain];
		
		_playableTiles = [[NSMutableArray arrayWithCapacity: 30] retain];
		
		//[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"Sprites.plist"];
		//_spriteBatch = [[CCSpriteBatchNode batchNodeWithFile: @"Sprites.png"] retain];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: [self convertFileName: @"Sprites" extension: @"plist"]];
		_spriteBatch = [[CCSpriteBatchNode batchNodeWithFile: [self convertFileName: @"Sprites" extension: @"png"]] retain];

		// don't forget AppDelegate !!!
		//[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"Sprites_tp.plist"];
		//_spriteBatch = [[CCSpriteBatchNode batchNodeWithFile: @"Sprites_tp.pvr.ccz"] retain];
	
		[self addChild: _spriteBatch z: kPlayground tag: kPlayground];
		//[CCTexture2D setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_Default];
		
		// init loader
		/*UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *) [[[CCDirector sharedDirector] openGLView] viewWithTag: kActivityIndicator];
		if (activityIndicatorView == nil) {
			activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite] autorelease];
			activityIndicatorView.tag = kActivityIndicator;
			activityIndicatorView.center = [[CCDirector sharedDirector] convertToGL: [self convertPoint: ccp(460, 20)]];
			//[activityIndicatorView setHidesWhenStopped: YES];
			[[[CCDirector sharedDirector] openGLView] addSubview: activityIndicatorView];
		}*/
		
		_glow = [[CCSequence actions:
				  [CCSpawn actions:
				   [CCScaleTo actionWithDuration: 0.3f scale: 1.0f],
				   [CCFadeIn actionWithDuration: 0.3f],
				   [CCRotateBy actionWithDuration: 0.3f angle: 45],
				   nil],
				  [CCSpawn actions:
				   [CCScaleTo actionWithDuration: 0.3f scale: 0.0f],
				   [CCFadeOut actionWithDuration: 0.3f],
				   [CCRotateBy actionWithDuration: 0.3f angle: 45],
				   nil],
				  [CCCallFunc actionWithTarget: self selector: @selector(hideGlow)],
				  nil] retain];
				  
		_updateTime = 0.0f;
		_glowType = kGlowDisabled;
		_timeBetweenGlows = (arc4random() % 3) + 1;
		
		_recording = NO;
		_recordingFrameNum = 0;

		CGSize winSize = [CCDirector sharedDirector].winSize;
		_framebufferWidth = winSize.width;
		_framebufferHeight = winSize.height;
		if ([Game sharedGame].retina || [Game sharedGame].iPad) {
			_framebufferHeight = _framebufferHeight * 2;
			_framebufferWidth = _framebufferWidth * 2;
		}

		_ready = NO;
	}
	return self;
}

-(void) ready {

	_ready = YES;
}

#pragma mark -
#pragma mark Loading

-(void) showActivityIndicator {
	
	UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *) [[[CCDirector sharedDirector] openGLView] viewWithTag: kActivityIndicator];
	//UIImageView *activityIndicatorView = (UIImageView *) [[[CCDirector sharedDirector] openGLView] viewWithTag: kActivityIndicator];
	if (activityIndicatorView != nil) {
		[activityIndicatorView startAnimating];
	}
}

-(void) hideActivityIndicator {

	UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *) [[[CCDirector sharedDirector] openGLView] viewWithTag: kActivityIndicator];
	//UIImageView *activityIndicatorView = (UIImageView *) [[[CCDirector sharedDirector] openGLView] viewWithTag: kActivityIndicator];
	if (activityIndicatorView != nil) {
		[activityIndicatorView stopAnimating];
	}
}

-(void) loading: (NSString *) selectorString {

	UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *) [[[CCDirector sharedDirector] openGLView] viewWithTag: kActivityIndicator];
	if (activityIndicatorView != nil) {
		[activityIndicatorView startAnimating];
	}
	
	[self runAction: [CCSequence actions:
					  [CCDelayTime actionWithDuration: 0.05f],
					  [CCCallFunc actionWithTarget: self selector: NSSelectorFromString(selectorString)],
					  nil]];
}

#pragma mark -
#pragma mark Content Builders

-(void) addBackground {

	// override in subclasses
}

-(void) addPlayground {
	
	// override in subclasses
}
-(void) addMenu {

	// override in subclasses
}	

-(void) setTableColor {
	
	Game *game = [Game sharedGame];
	
	if ((game.clothColor > 0) && (game.tilehallIndex <= kTilehallSpin)) {
		[game setColorForTable: (game.clothColor - 1)];
	}

	[self setColor: game.tableColor];
	
	CCSprite *bg = (CCSprite *) [_spriteBatch getChildByTag: kBackground];
	bg.color = game.lightColor;
}

#pragma mark -
#pragma mark Table Movement

-(void) openTable: (SEL) selector {
	
	_glowType = kGlowDisabled;
	[self hideGlow];

	_updateTime = 0.0f;
	
	CCAction *moveUpAction = [CCSequence actions:
							  [CCMoveTo actionWithDuration: kFullTableMovementDuration position: [self convertPoint: ccp(240, 383)]],
							  [CCDelayTime actionWithDuration: 0.1f],
							  [CCCallFunc actionWithTarget: self selector: selector],
							  nil];
	CCAction *moveDownAction = [CCMoveTo actionWithDuration: kFullTableMovementDuration position: [self convertPoint: ccp(240, -64)]];
	
	//[[_spriteBatch getChildByTag: kUpperTable] stopAllActions];
	//[[_spriteBatch getChildByTag: kLowerTable] stopAllActions];
	[[_spriteBatch getChildByTag: kUpperTable] runAction: moveUpAction];
	[[_spriteBatch getChildByTag: kLowerTable] runAction: moveDownAction];
	
	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTableOpenFull];
	}
}

-(void) closeTable: (SEL) selector {

	_glowType = kGlowDisabled;
	[self hideGlow];
	
	_updateTime = 0.0f;
	
	CCAction *moveUpAction = [CCSequence actions:
							  [CCMoveTo actionWithDuration: kFullTableMovementDuration position: [self convertPoint: ccp(240, 64)]],
							  [CCDelayTime actionWithDuration: 0.1f],
							  [CCCallFunc actionWithTarget: self selector: selector],
							  nil];
	CCAction *moveDownAction = [CCMoveTo actionWithDuration: kFullTableMovementDuration position: [self convertPoint: ccp(240, 256)]];
	
	[[_spriteBatch getChildByTag: kUpperTable] runAction: moveDownAction];
	[[_spriteBatch getChildByTag: kLowerTable] runAction: moveUpAction];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTableCloseFull];
	}
}

-(void) closeTableAndLoad: (NSString *) selectorString {

	_glowType = kGlowDisabled;
	[self hideGlow];
	
	CCAction *moveUpAction = [CCSequence actions:
							  [CCMoveTo actionWithDuration: kFullTableMovementDuration position: [self convertPoint: ccp(240, 64)]],
							  [CCDelayTime actionWithDuration: 0.1f],
							  [CCCallFuncO actionWithTarget: self selector: @selector(loading:) object: selectorString],
							  nil];
	CCAction *moveDownAction = [CCMoveTo actionWithDuration: kFullTableMovementDuration position: [self convertPoint: ccp(240, 256)]];
	
	[[_spriteBatch getChildByTag: kUpperTable] runAction: moveDownAction];
	[[_spriteBatch getChildByTag: kLowerTable] runAction: moveUpAction];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTableCloseFull];
	}
}

-(void) openTableHalf: (SEL) selector {

	_glowType = kGlowDisabled;
	[self hideGlow];
	
	CCAction *moveUpAction = [CCSequence actions:
							  [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 288)]],
							  [CCDelayTime actionWithDuration: 0.1f],
							  [CCCallFunc actionWithTarget: self selector: @selector(setMenuGlow)],
							  [CCCallFunc actionWithTarget: self selector: selector],
							  nil];
	CCAction *moveDownAction = [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 32)]];
	
	//[[_spriteBatch getChildByTag: kUpperTable] stopAllActions];
	//[[_spriteBatch getChildByTag: kLowerTable] stopAllActions];
	[[_spriteBatch getChildByTag: kUpperTable] runAction: moveUpAction];
	[[_spriteBatch getChildByTag: kLowerTable] runAction: moveDownAction];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTableOpenHalf];
	}
}

-(void) closeTableHalf: (SEL) selector {

	_glowType = kGlowDisabled;
	[self hideGlow];
	
	CCAction *moveUpAction = [CCSequence actions:
							  [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 64)]],
							  [CCDelayTime actionWithDuration: 0.1f],
							  [CCCallFunc actionWithTarget: self selector: selector],
							  nil];
	CCAction *moveDownAction = [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 256)]];
	
	[[_spriteBatch getChildByTag: kUpperTable] runAction: moveDownAction];
	[[_spriteBatch getChildByTag: kLowerTable] runAction: moveUpAction];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTableCloseHalf];
	}
}

-(void) closeTableHalfly: (SEL) selector {

	_glowType = kGlowDisabled;
	[self hideGlow];
	
	_updateTime = 0.0f;
	
	CCAction *moveDownAction = [CCSequence actions:
							    [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 288)]],
							    [CCDelayTime actionWithDuration: 0.1f],
							    [CCCallFunc actionWithTarget: self selector: @selector(setMenuGlow)],
							    [CCCallFunc actionWithTarget: self selector: selector],
							    nil];
	CCAction *moveUpAction = [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 32)]];
	
	[[_spriteBatch getChildByTag: kUpperTable] runAction: moveDownAction];
	[[_spriteBatch getChildByTag: kLowerTable] runAction: moveUpAction];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTableCloseHalf];
	}
}

-(void) openTableHalfly: (SEL) selector {

	_glowType = kGlowDisabled;
	[self hideGlow];
	
	_updateTime = 0.0f;
	
	CCAction *moveUpAction = [CCSequence actions:
							  [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 383)]],
							  [CCDelayTime actionWithDuration: 0.1f],
							  [CCCallFunc actionWithTarget: self selector: selector],
							  nil];
	CCAction *moveDownAction = [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, -64)]];
	
	//[[_spriteBatch getChildByTag: kUpperTable] stopAllActions];
	//[[_spriteBatch getChildByTag: kLowerTable] stopAllActions];
	[[_spriteBatch getChildByTag: kUpperTable] runAction: moveUpAction];
	[[_spriteBatch getChildByTag: kLowerTable] runAction: moveDownAction];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTableOpenHalf];
	}
}

-(void) closeTableHalfAndLoad: (NSString *) selectorString {

	_glowType = kGlowDisabled;
	[self hideGlow];
	
	CCAction *moveUpAction = [CCSequence actions:
							  [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 64)]],
							  [CCDelayTime actionWithDuration: 0.1f],
							  [CCCallFuncO actionWithTarget: self selector: @selector(loading:) object: selectorString],
							  nil];
	CCAction *moveDownAction = [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 256)]];
	
	[[_spriteBatch getChildByTag: kUpperTable] runAction: moveDownAction];
	[[_spriteBatch getChildByTag: kLowerTable] runAction: moveUpAction];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTableCloseHalf];
	}
}

#pragma mark -
#pragma mark Helpers

-(void) hideMenu {
	
	_menu.visible = NO;
	//[_spriteBatch getChildByTag: kTableShadow].visible = NO;
}

-(void) showMenu {
	
	Game *game = [Game sharedGame];
	
	NSInteger width = (game.iPad ? 1024 : (game.iPhone5 ? 568 : 480));
	NSInteger y = (game.iPad ? 383 : 160);
	_menu.position = ccp((-width * game.menu) + (width / 2), y);
	_menu.visible = YES;
}

-(void) hideGlow {

	[self getChildByTag: kGlow].visible = NO;
}

-(void) setMenuGlow {
	
	_glowType = kGlowMenu;
}

-(void) setGameGlow {
	
	_glowType = kGlowGame;
}

#pragma mark -
#pragma mark Converters

-(NSString *) convertFileName: (NSString *) name extension: (NSString *) extension {
	
	NSString *suffix = @"";
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		suffix = @"-hd";
	}
	/*else if ([Game sharedGame].retina) {
		suffix = @"-hd";
	}*/
	
	return [NSString stringWithFormat: @"%@%@.%@", name, suffix, extension];
}

-(CGPoint) convertPoint: (CGPoint) point {    

	Game *game = [Game sharedGame];
	
	if (game.iPad) {
		return ccp(32 + (point.x * 2), 64 + (point.y * 2));
	}
	if (game.iPhone5) {
		return ccp(44 + point.x, point.y);
	}
	return point;
}

-(CGPoint) convertPoint: (CGPoint) point offset: (CGPoint) offset {
	
	Game *game = [Game sharedGame];
	
	if (game.iPad) {
		return ccp(32 + (point.x * 2) + offset.x, 64 + (point.y * 2) + offset.y);
	}
	if (game.iPhone5) {
		return ccp(44 + point.x + offset.x, point.y + offset.y);
	}
	return point;
}

-(CGPoint) convertPoint: (CGPoint) point iPadOffset: (CGPoint) iPadOffset iPhone5Offset: (CGPoint) iPhone5Offset {
	
	Game *game = [Game sharedGame];
	
	if (game.iPad) {
		return ccp(32 + (point.x * 2) + iPadOffset.x, 64 + (point.y * 2) + iPadOffset.y);
	}
	if (game.iPhone5) {
		return ccp(44 + point.x + iPhone5Offset.x, point.y + iPhone5Offset.y);
	}
	return point;
}

-(float) convertFontSize: (float) size {
	
	Game *game = [Game sharedGame];
	
	if (game.iPad) {
		return (size * 2.0f);
	}
	return size;
}

-(PositionOnTable) convertLocationToTablePosition: (CGPoint) location {
	
	Game *game = [Game sharedGame];
	
	NSInteger tileSize = kTileSize;
	if (game.iPad) {
		location = ccp(location.x - 32, location.y - 64);
		tileSize = (2 * tileSize);
	}
	if (game.iPhone5) {
		location = ccp(location.x - 44, location.y);
	}
	
	PositionOnTable positionOnTable;
	positionOnTable.x = (NSInteger) (location.x / tileSize);
	if (location.y < kTablePosition) {
		positionOnTable.y = -1;
	}
	else {
		positionOnTable.y = (NSInteger) ((location.y - kTablePosition) / tileSize);
	}
	
	return positionOnTable;
}

-(PositionOnTable) convertLocationToMovingTablePosition: (CGPoint) location {
	
	Game *game = [Game sharedGame];
	
	NSInteger tileSize = kTileSize;
	NSInteger offset = 24;
	if (game.iPad) {
		location = ccp(location.x - 32, location.y - 64);
		tileSize = (2 * tileSize);
		offset = (2 * offset);
	}
	if (game.iPhone5) {
		location = ccp(location.x - 44, location.y);
	}
	
	PositionOnTable positionOnTable;
	positionOnTable.x = (NSInteger) (location.x / tileSize);
	positionOnTable.y = (NSInteger) ((location.y - offset) / tileSize);
	
	return positionOnTable;
}

-(NSString *) convertPositionOnTableIntoNotations: (PositionOnTable) positionOnTable {

	return [NSString stringWithFormat: @"%c%d", ('A' + positionOnTable.x), (positionOnTable.y + 1)];
}

#pragma mark -
#pragma mark Playable Tiles

-(void) addPlayableTile: (Tile *) tile {
	
	[_playableTiles addObject: tile];
	
	// sort tiles by their numbers
	NSSortDescriptor *sortByNumber = [NSSortDescriptor sortDescriptorWithKey: @"number" ascending: YES];
	[_playableTiles sortUsingDescriptors: [NSArray arrayWithObject: sortByNumber]];
}

-(void) replacePlayableTile: (Tile *) tile withTile: (Tile *) newTile {
	
	NSInteger index = 0;
	
	for (Tile *playableTile in _playableTiles) {
		if (playableTile == tile) {
			break;
		}
		index++;
	}
	
	[_playableTiles replaceObjectAtIndex: index withObject: newTile];
}

-(void) removePlayableTile: (Tile *) tile {
	
	Tile *tileToRemove = nil;
	
	for (Tile *playableTile in _playableTiles) {
		if (playableTile == tile) {
			tileToRemove = playableTile;
			break;
		}
	}
	
	if (tileToRemove != nil) {
		[_playableTiles removeObject: tileToRemove];
	}
}

-(void) removeAllPlayableTiles {
	
	[_playableTiles removeAllObjects];
}

-(void) sortPlayableTiles {

	// sort tiles by their numbers
	NSSortDescriptor *sortByNumber = [NSSortDescriptor sortDescriptorWithKey: @"number" ascending: YES];
	[_playableTiles sortUsingDescriptors: [NSArray arrayWithObject: sortByNumber]];
}

-(BOOL) existsPlayableTileWithNumber: (NSInteger) number {

	for (Tile *playableTile in _playableTiles) {
		if (playableTile.number == number) {
			return YES;
		}
	}
	
	return NO;
}

-(void) showTiles {
	
	for (Tile *tile in _playableTiles) {
		
		[tile makeSolid];
	}
}

-(void) hideTiles {
	
	for (Tile *tile in _playableTiles) {
		
		[tile makeTransparent];
	}
}

#pragma mark -
#pragma mark Tile Movement

-(Tile *) getTileOnPosition: (PositionOnTable) positionOnTable {
	
	Tile *tile = nil;
	if (_table != nil &&
			(positionOnTable.x >= 0) && (positionOnTable.x < kTableWidth) && 
			(positionOnTable.y >= 0) && (positionOnTable.y < kTableHeight)) {
		tile = [[_table objectAtIndex: positionOnTable.y] objectAtIndex: positionOnTable.x];
	}
	
	return tile;
}

/*-(BOOL) moveTile: (Tile *) tile {
	
	PositionOnTable newPosition = [self moveTileAndReturnPositionOnTable: tile];
	
	if ((tile.positionOnTable.x == newPosition.x)
		&& (tile.positionOnTable.y == newPosition.y)) {
		
		return NO;
	}
	return YES;
}
-(PositionOnTable) moveTileAndReturnPositionOnTable: (Tile *) tile {*/

-(BOOL) moveTile: (Tile *) tile {
	
	// prepare power-ups if tile is on one
	[tile prepareMove];
	
	// handle rebounds
	[self handleReboundsForTile: tile];
	
	// if there was a collision do not move tile just adapt its direction
	if ([self handleCollisionsForTile: tile]) {
		
		Game *game = [Game sharedGame];
		SoundFlags soundFlags = game.soundFlags;
		if (!soundFlags.collision && game.sound) {
			
			soundFlags.collision = YES;
			game.soundFlags = soundFlags;
			[[SimpleAudioEngine sharedEngine] playEffect: kSoundTileCollision];
		}

		return NO;
	}
	
	// recalculate the position for cases we hit the bounds or collided with another tile
	PositionOnTable positionOnTable;
	positionOnTable.x = tile.positionOnTable.x + tile.direction.x;
	positionOnTable.y = tile.positionOnTable.y + tile.direction.y;
	
	/* UPDATE ver. 2.0
	if (tile.shot == kShotSideRotation) {
		if (positionOnTable.x < 0) {
			positionOnTable.x = (kTableWidth - 1);
		}
		else if (positionOnTable.x > (kTableWidth - 1)) {
			positionOnTable.x = 0;
		}
	}*/
	
	Tile *destinationTile = [self getTileOnPosition: positionOnTable];
	
	if ([destinationTile isEmpty]) {
		// switch tiles on the table
		
		/* UPDATE ver. 2.0
		if (tile.shot == kShotSideRotation &&
				((positionOnTable.x == 0 && tile.direction.x == 1) || 
				(positionOnTable.x == (kTableWidth - 1) && tile.direction.x == (-1)))) {
				
			[destinationTile copyTileAndPrepareMovementFromDirection: tile];
			[tile clearTileAndPrepareMovement];
			
			[self replacePlayableTile: tile withTile: destinationTile];
			[self addPlayableTile: tile];
			
			// add aditional sprite for side movement
			[_spriteBatch addChild: tile.sprite];
		}
		else {
			
			[destinationTile copyTileAndPrepareMovement: tile];
			[tile clearTile];
			
			[self replacePlayableTile: tile withTile: destinationTile];
		}*/
		
		if ([destinationTile beforeMove: tile]) {
		
			[destinationTile copyTileAndPrepareMovement: tile];
			[tile clearTile];
			
			[self replacePlayableTile: tile withTile: destinationTile];
				
			[destinationTile move];
			[[Game sharedGame] addMove];
			
			// set position after tile moved
			positionOnTable = destinationTile.positionOnTable;
		}
		else {
		
			positionOnTable = tile.positionOnTable;
		}
		
		if (![destinationTile afterMove]) {
		
			// end of game, restart
			//[self reset];
			
			//_endOfGame = YES;
		}
	}
	else {
		
		positionOnTable = tile.positionOnTable;
		[tile stopMoving];
		
		return NO;
	}
	
	return YES; //positionOnTable;
}

-(Direction) directionForPosition: (PositionOnTable) currentPositionOnTable direction: (Direction) currentDirection {

	PositionOnTable positionOnTable;
	positionOnTable.x = currentPositionOnTable.x + currentDirection.x;
	positionOnTable.y = currentPositionOnTable.y + currentDirection.y;
	
	Direction direction;
	direction.x = currentDirection.x;
	direction.y = currentDirection.y;
	
	// handle corner pocket rebounds
	if (((positionOnTable.y == 0) || (positionOnTable.y == (kTableHeight - 1)))
			&& (direction.y == 0) && ((positionOnTable.x < 0) || (positionOnTable.x >= kTableWidth))) {
		
		/* UPDATE ver. 2.0
		if (tile.shot != kShotSideRotation) {*/

		if (positionOnTable.y == 0) {
			direction.y = 1;
		}
		else if (positionOnTable.y == (kTableHeight - 1)) {
			direction.y = (-1);
		}
		direction.x = 0;
	}
	else if (((positionOnTable.x == 0) || (positionOnTable.x == (kTableWidth - 1)))
			 && (direction.x == 0) && ((positionOnTable.y < 0) || (positionOnTable.y >= kTableHeight))) {
		
		/* UPDATE ver. 2.0
		if (tile.shot != kShotSideRotation) {*/

		if (positionOnTable.x == 0) {
			direction.x = 1;
		}
		else if (positionOnTable.x == (kTableWidth - 1)) {
			direction.x = (-1);
		}
		direction.y = 0;
	}
	// handle other rebounds
	else {
		if ((positionOnTable.x < 0) || (positionOnTable.x >= kTableWidth)) {
			/* UPDATE ver. 2.0
			if (tile.shot != kShotSideRotation) {*/

			direction.x = ((-1) * direction.x);
		}
		if ((positionOnTable.y < 0) || (positionOnTable.y >= kTableHeight)) {
			direction.y = ((-1) * direction.y);
		}
	}
	
	return direction;
}

-(void) handleReboundsForTile: (Tile *) tile {
	
	Direction direction = [self directionForPosition: tile.positionOnTable direction: tile.direction];
	
	if ((tile.direction.x != direction.x) || (tile.direction.y != direction.y)) {

		Game *game = [Game sharedGame];
		SoundFlags soundFlags = game.soundFlags;
		if (!soundFlags.rebound && game.sound) {
			
			soundFlags.rebound = YES;
			game.soundFlags = soundFlags;
			[[SimpleAudioEngine sharedEngine] playEffect: kSoundTileRebound];
		}
	}
	
	// set direction after rebound
	tile.direction = direction;
}

-(BOOL) handleCollisionsForTile: (Tile *) tile {
	
	BOOL affectedTile = NO;
	
	Direction currentTileDirection = tile.direction;
	
	// set directions for 3 possible colliding tiles in moving direction
	for (NSInteger i = 0; i < 3; i++) {
		Direction direction = currentTileDirection;
		
		if (i == 0) {
			// current moving direction
		}
		if (i == 1) {
			direction.x = ((currentTileDirection.x == 0) ? (-1) : ((currentTileDirection.y != 0) ? 0 : currentTileDirection.x));
			direction.y = ((currentTileDirection.y == 0) ? (-1) : currentTileDirection.y);
		}
		else if (i == 2) {
			direction.x = ((currentTileDirection.x == 0) ? 1 : currentTileDirection.x);
			direction.y = ((currentTileDirection.y == 0) ? 1 : ((currentTileDirection.x != 0) ? 0 : currentTileDirection.y));
		}
		
		PositionOnTable positionOnTable;
		positionOnTable.x = tile.positionOnTable.x;
		positionOnTable.y = tile.positionOnTable.y;
		
		positionOnTable.x = positionOnTable.x + direction.x;
		positionOnTable.y = positionOnTable.y + direction.y;
		
		/* UPDATE ver. 2.0
		if (tile.shot == kShotSideRotation) {
			if (positionOnTable.x < 0) {
				positionOnTable.x = (kTableWidth - 1);
			}
			else if (positionOnTable.x > (kTableWidth - 1)) {
				positionOnTable.x = 0;
			}
		}*/
				
		if ((positionOnTable.x >= 0) && (positionOnTable.x < kTableWidth)
				&& (positionOnTable.y >= 0 && positionOnTable.y < kTableHeight)) {
			
			Tile *nearbyTile = [self getTileOnPosition: positionOnTable];
			
			if ([nearbyTile isPlayable] || ([nearbyTile checkColor: tile] && (nearbyTile.powerUp == kPowerUpGhost))) {
				
				/*if (![nearbyTile isMoving] || (tile.number < nearbyTile.number)) {
					
					[nearbyTile startMovingInDirection: direction];
				}
				else if ([nearbyTile isMoving] && (tile.number > nearbyTile.number)) {
					
					affectedTile = NO;
					continue;
				}*/
				
				if ([nearbyTile isMoving] && (tile.number > nearbyTile.number)) {
					
					//affectedTile = NO;
					continue; // break?
				}
				
				if ((nearbyTile.powerUp != kPowerUpGhost) || ![nearbyTile checkColor: tile]) {

					affectedTile = YES;
					[tile inCollisionWith: nearbyTile];
				
					[nearbyTile startMovingInDirection: direction];
				}

				// is there a tile in the way, if yes we need to stop moving or move backwards (BackwardRotation)
				if ((tile.direction.x == direction.x) && (tile.direction.y == direction.y)) {
					
					[tile stopMoving];
					
					/* UPDATE ver. 2.0
					if (tile.shot != kShotBackwardRotation) {
						[tile stopMoving];
					}
					else {
						Direction oppositeDirection;
						oppositeDirection.x = tile.direction.x * (-1);
						oppositeDirection.y = tile.direction.y * (-1);
						tile.direction = oppositeDirection;
					}*/
				}
				// if tile has not been stopped already, adapt directions
				else if ((tile.direction.x != 0) || (tile.direction.y != 0)) {
					
					// change direction of tile based on collisions
					Direction directionAfterCollision;
					
					if ((direction.x == 0) || (direction.y == 0)) {
						directionAfterCollision.x = ((direction.x == 0) ? tile.direction.x : 0);
						directionAfterCollision.y = ((direction.x == 0) ? 0 : tile.direction.y);
					}
					else {
						directionAfterCollision.x = tile.direction.x;
						if (tile.direction.x == 0) {
							directionAfterCollision.x = (direction.x * (-1));
						}
						directionAfterCollision.y = tile.direction.y;
						if (tile.direction.y == 0) {
							directionAfterCollision.y = (direction.y * (-1));
						}
					}
					tile.direction = directionAfterCollision;
				}
			}
		}
	}
	
	return affectedTile;
}

#pragma mark -
#pragma mark Glow

-(CGPoint) getGlowPosition {
	
	return CGPointMake(0.0f, 0.0f);
}

#pragma mark -
#pragma mark Screen Recording

void releaseScreenshotData(void *info, const void *data, size_t size) {
	
	free((void*) data);
}

-(UIImage *) captureScreen {
	
	NSInteger dataLength = _framebufferWidth * _framebufferHeight * 4;
	
	// Allocate array.
	GLuint *buffer = (GLuint *) malloc(dataLength);
	GLuint *resultsBuffer = (GLuint *)malloc(dataLength);
    // Read data
	glReadPixels(0, 0, _framebufferWidth, _framebufferHeight, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
	
    // Flip vertical
	for(int y = 0; y < _framebufferHeight; y++) {
		for(int x = 0; x < _framebufferWidth; x++) {
			resultsBuffer[x + y * _framebufferWidth] = buffer[x + (_framebufferHeight - 1 - y) * _framebufferWidth];
		}
	}
	
	free(buffer);
	
	// make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, resultsBuffer, dataLength, releaseScreenshotData);
	
	// prep the ingredients
	const int bitsPerComponent = 8;
	const int bitsPerPixel = 4 * bitsPerComponent;
	const int bytesPerRow = 4 * _framebufferWidth;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(_framebufferWidth, _framebufferHeight, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	
	// then make the UIImage from that
	UIImage *image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return image;
}

-(void) savePhoto {
	
	UIImage *image = [self captureScreen];
	UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

-(void) saveFrame {
	
	UIImage *image = [self captureScreen];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex: 0] : nil;
	basePath = [basePath stringByAppendingPathComponent: @"/video/"];
	[[NSFileManager defaultManager] createDirectoryAtPath: basePath withIntermediateDirectories: YES attributes: 0 error: NULL];
	NSString *fileName = [NSString stringWithFormat: @"%d.jpg", _recordingFrameNum++];
	[UIImageJPEGRepresentation(image, 1.0) writeToFile: [basePath stringByAppendingPathComponent: fileName] atomically: NO];
}

/*-(void) record: (ccTime) dt {
	
	if (_recording) {
		
		[self saveFrame];
	}
}*/

#pragma mark -
#pragma mark Update

-(void) update: (ccTime) dt {
	
	/*if (_recording) {
		
		[self saveFrame];
		//[self savePhoto];
	}*/

	if (_glowType != kGlowDisabled) {
		
		_updateTime = _updateTime + dt;
		if (_timeBetweenGlows > 5.0f) {
			_timeBetweenGlows = (arc4random() % 2) + 1;
		}
		
		if (_updateTime > _timeBetweenGlows) {
			
			_updateTime = 0.0f;
			_timeBetweenGlows = (arc4random() % 2) + 1;
			
			CCSprite *glow = (CCSprite *) [self getChildByTag: kGlow];
			glow.visible = YES;
			
			glow.color = [Game sharedGame].lightColor;
			glow.position = [self convertPoint: [self getGlowPosition] iPadOffset: ccp(0, 32) iPhone5Offset: ccp(0, 0)];
			[glow runAction: _glow];
		}
	}
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	[_spriteBatch release];
	_spriteBatch = nil;
	
	[_glow release];
	_glow = nil;
	
	/*UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *) [[[CCDirector sharedDirector] openGLView] viewWithTag: kActivityIndicator];
	if (activityIndicatorView != nil) {
		[activityIndicatorView removeFromSuperview];
		[activityIndicatorView release];
	}*/
	
	[_table release];
	_table = nil;
	
	[_playableTiles release];
	_playableTiles = nil;
	
	[_menu release];
	_menu = nil;
	
	[super dealloc];
}

@end


@implementation MenuItemSprite

+(id) itemWithSpriteFrameName: (NSString *) frameName target: (id) target selector: (SEL) selector {
	
	return [[[self alloc] initWithSpriteFrameName: frameName target: target selector: selector] autorelease];
}

-(id) initWithSpriteFrameName: (NSString *) frameName target: (id) target selector: (SEL) selector {

	CCSprite *sprite = [CCSprite spriteWithSpriteFrameName: frameName];
	
	if ((self = [super initFromNormalSprite: sprite selectedSprite: nil disabledSprite: nil target: target selector: selector])) {
	
		_frameName = [frameName retain];
	}
	return self;
}

-(void) selected {
	
	//[super selected];
	if (_isSelectionColorSet) {
		[self setColor: _selectionColor];
	}
	else {
		[self setColor: [Game sharedGame].lightColor];
	}
}

-(void) unselected {
	
	//[super unselected];
	[self setColor: kColorWhite];
}

-(void) setIsEnabled: (BOOL) enabled {
	
	[super setIsEnabled: enabled];
	
	if (enabled) {
		[self setOpacity: 255];
	}
	else {
		[self setOpacity: 77];
	}
}

-(void) setSelectionColor: (ccColor3B) color {
	
	_isSelectionColorSet = YES;
	_selectionColor = color;
}

-(void) refreshSprite {

	if (_frameName != nil) {
		
		CCSprite *sprite = [CCSprite spriteWithSpriteFrameName: _frameName];
		self.normalImage = sprite;
		
		if (![self isEnabled]) {
			[self setIsEnabled: NO];
		}
	}
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	[_frameName release];
	_frameName = nil;
	
	[super dealloc];
}

@end

