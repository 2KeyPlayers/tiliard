//
//  GameScene.m
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/26/10.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#import "GameplayScene.h"
#import	"MenuScene.h"
#import "EndingScene.h"
#import "Localization.h"
#import "MessageUI/MessageUI.h"
#import "DDGameKitHelper.h"
#import <Twitter/Twitter.h>


@implementation Gameplay

#pragma mark -
#pragma mark Scene Creator

+(id) scene {

	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// add layer as a child to scene
	[scene addChild: [Gameplay node]];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
		
		_viewController = [[UIViewController alloc] init];
		
		Game *game = [Game sharedGame];
		[game start];
		
		_ignore = NO;
		_button = kButtonDefault;
		_shake = NO;
		_action = kActionDefault;
		_doubleTap = NO;
		
		[self addBackground];
		[self addPlayground];
		[self addMenu];
		
		// prepare array for undo
		_deadlock = NO;
		_undoPossible = NO;
		_undoLayouts = [[NSMutableArray arrayWithCapacity: kMaximumSolutionShots] retain];
		
		// prepare array for solution steps
		_solution = [[NSMutableArray arrayWithCapacity: kMaximumSolutionShots] retain];

		// init hints (if available)
		_hint = -1;
		Table *table = [game table];
		if (([table totalHints] > 0) && [table displayHints]){
			
			_hint = 0;
		}
		_detail = -1;
		
		SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
		if (sae != nil) {
			
			sae.effectsVolume = (game.music ? 0.1f : 0.3f);
			
			if (game.music) {
				[sae preloadBackgroundMusic: [NSString stringWithFormat: @"Music%02d.mp3", [game nextTrack]]];
				if (sae.willPlayBackgroundMusic) {
					sae.backgroundMusicVolume = 0.5f;
				}
			}
			if (game.sound) {
				[sae preloadEffect: kSoundError];
				[sae preloadEffect: kSoundInfo];
				[sae preloadEffect: kSoundMenuTap];
				[sae preloadEffect: kSoundMenuSlide];
				[sae preloadEffect: kSoundRackUp];
				[sae preloadEffect: kSoundRank];
				[sae preloadEffect: kSoundReset];
				[sae preloadEffect: kSoundTableCloseFull];
				[sae preloadEffect: kSoundTableCloseHalf];
				[sae preloadEffect: kSoundTableOpenFull];
				[sae preloadEffect: kSoundTableOpenFull];
				[sae preloadEffect: kSoundUndo];
			}
		}
		
		// init tiles count for achievemnts
		GKAchievement *century = [[DDGameKitHelper sharedGameKitHelper] getAchievement: @"Century"];
		_tilesForCentury = -1;
		if (century != nil) {
			_tilesForCentury = century.percentComplete;
		}
		
		GKAchievement *willieM = [[DDGameKitHelper sharedGameKitHelper] getAchievement: @"WillieM"];
		_tilesForWillieM = -1;
		if (willieM != nil) {
			_tilesForWillieM = willieM.percentComplete;
		}
		
		self.isTouchEnabled = YES;
		//self.isAccelerometerEnabled = YES;
		//[self scheduleUpdate];
		
		// open table
		//[self openTable: @selector(ready)];
		[self openTable: @selector(showTableNumberAndDescription)];
	}
	return self;
}

-(void) onEnter {
	
	[self hideActivityIndicator];
	[self scheduleUpdate];
	//[self schedule: @selector(record:) interval: 1/30];
	
	Game *game = [Game sharedGame];
	if (game.music) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic: [NSString stringWithFormat: @"Music%02d.mp3", game.trackNr]];
	}
	
	[super onEnter];
}

#pragma mark -
#pragma mark Content Builders

-(void) addBackground {
	
	Game *game = [Game sharedGame];
	
	// add background (containing light)
	CCSprite *bg = [CCSprite spriteWithSpriteFrameName: @"gpBackground.png"];
	bg.position = [self convertPoint: ccp(240, 160)];
	[_spriteBatch addChild: bg z: kBackground tag: kBackground];
	
	if (game.iPad || game.iPhone5) {
		
		CCSprite *bl = [CCSprite spriteWithSpriteFrameName: @"gpBorder.png"];
		//CCSprite *bl = [CCSprite spriteWithSpriteFrameName: @"gpBorderL.png"];
		bl.anchorPoint = ccp(1.0f, 0.5f);
		
		CCSprite *br = [CCSprite spriteWithSpriteFrameName: @"gpBorder.png"];
		//CCSprite *br = [CCSprite spriteWithSpriteFrameName: @"gpBorderR.png"];
		br.flipX = YES;
		br.anchorPoint = ccp(0, 0.5f);
		
		if (game.iPad) {
			bl.position = ccp(32, 384);
			br.position = ccp(990, 384);
		}
		else {
			bl.position = ccp(44, 160);
			br.position = ccp(523, 160);
		}
		
		[_spriteBatch addChild: bl z: kBackground tag: kBorderLeft];
		[_spriteBatch addChild: br z: kBackground tag: kBorderRight];
	}
	
	// add notations
	CCSprite *upperNotation = [CCSprite spriteWithSpriteFrameName: @"gpBtoN.png"];
	upperNotation.position = [self convertPoint: ccp(230, 262)];
	upperNotation.opacity = 77;
	[_spriteBatch addChild: upperNotation z: kBackground tag: kUpperNotation];
	
	CCSprite *lowerNotation = [CCSprite spriteWithSpriteFrameName: @"gpBtoN.png"];
	lowerNotation.position = [self convertPoint: ccp(249, 57)];
	lowerNotation.opacity = 77;
	[_spriteBatch addChild: lowerNotation z: kBackground tag: kLowerNotation];
	
	CCSprite *leftNotation = [CCSprite spriteWithSpriteFrameName: @"gp2to7.png"];
	leftNotation.position = [self convertPoint: ccp(25, 150)];
	leftNotation.opacity = 77;
	[_spriteBatch addChild: leftNotation z: kBackground tag: kLeftNotation];
	
	CCSprite *rightNotation = [CCSprite spriteWithSpriteFrameName: @"gp2to7.png"];
	rightNotation.position = [self convertPoint: ccp(454, 169)];
	rightNotation.opacity = 77;
	[_spriteBatch addChild: rightNotation z: kBackground tag: kRightNotation];
	
	// add upper and lower table parts
	CCSprite *upperTable = [CCSprite spriteWithSpriteFrameName: @"gpTable.png"];
	upperTable.flipX = YES;
	upperTable.flipY = YES;
	upperTable.position = [self convertPoint: ccp(240, 256)];
	[_spriteBatch addChild: upperTable z: kTable tag: kUpperTable];
	
	CCSprite *lowerTable = [CCSprite spriteWithSpriteFrameName: @"gpTable.png"];
	lowerTable.position = [self convertPoint: ccp(240, 64)];
	[_spriteBatch addChild: lowerTable z: kTable tag: kLowerTable];
	
	// add glow effect
	CCSprite *glow = [CCSprite spriteWithSpriteFrameName: @"gpGlow.png"];
	glow.position = [self convertPoint: ccp(240, 160)];
	glow.visible = NO;
	glow.color = [Game sharedGame].lightColor;
	glow.opacity = 0;
	glow.scale = 0.0f;
	[self addChild: glow z: kGlow tag: kGlow];
	
	if (game.tilehallIndex == kTilehallColor) {
		[game setColorForTable: kTableColorGray];
	}
	[self setTableColor];
}

-(void) addPlayground {
	
	Game *game = [Game sharedGame];
	
	// init the correct tile set
	char tileSet = [game tileSetChar];
	if (game.tilehallIndex == kTilehallColor) {
		tileSet = kTileSetColor;
	}
	[Tile setTileSet: tileSet];
	[Tile setMoveDuration: [game moveDuration]];
	
	// add empty table
	Table * table = [game table];
	NSArray *layout = [[table layout] componentsSeparatedByCharactersInSet:
                       [NSCharacterSet characterSetWithCharactersInString:@",\n"]];
	
	for (NSInteger y = (kTableHeight - 1); y >= 0; y--) {
		PositionOnTable positionOnTable;
		positionOnTable.y = (kTableHeight - 1 - y);
		
		for (NSInteger x = 0; x < kTableWidth; x++) {
			positionOnTable.x = x;
			
			NSString *number = (NSString *) [layout objectAtIndex: (y * kTableWidth + x)];
			Tile *tile = [Tile tileWithNumber: [number integerValue] onPosition: positionOnTable];
			
			// add tile on the table
			[[_table objectAtIndex: positionOnTable.y] addObject: tile];
			
			if ([tile isPlayable]) {
				[self addPlayableTile: tile];
			}
			
			// add tile's sprite into the batch node
			if (tile.backgroundSprite) {
				[_spriteBatch addChild: tile.backgroundSprite z: kBackground];
			}
			if (tile.sprite) {
				[_spriteBatch addChild: tile.sprite z: kPlayground];
			}
		}
	}

	CCSprite *aimer = [CCSprite spriteWithSpriteFrameName: @"gpAimer.png"];
	aimer.position = [self convertPoint: ccp(240, -100)];
	aimer.visible = NO;
	[_spriteBatch addChild: aimer z: kPlayground tag: kAimer];
	
	// add ranks and rank shots
	CCSprite *rank1 = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"gpRank_1_%@.png", game.language]];
	rank1.position = [self convertPoint: ccp(32, 16) iPadOffset: ccp(0, -32) iPhone5Offset: ccp(-38, 0)];
	rank1.anchorPoint = ccp(0, 0.5f);
	rank1.visible = NO;
	[_spriteBatch addChild: rank1 z: kButton tag: kRank1];
	
	NSInteger x = 32 + 10;
	for (NSInteger i = 0; i < kMaximumSolutionShots; i++) {
		if (i == (kMaximumSolutionShots - [table shotsForRank: kRankPro])) {
			
			CCSprite *rank2 = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"gpRank_2_%@.png", game.language]];
			rank2.position = [self convertPoint: ccp(x + (i * 20), 16) iPadOffset: ccp(0, -32) iPhone5Offset: ccp(-38, 0)];
			rank2.anchorPoint = ccp(0, 0.5f);
			rank2.visible = NO;
			[_spriteBatch addChild: rank2 z: kButton tag: kRank2];
			x = x + 10;
		}
		else if (i == (kMaximumSolutionShots - [table shotsForRank: kRankStar])) {

			CCSprite *rank3 = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"gpRank_3_%@.png", game.language]];
			rank3.position = [self convertPoint: ccp(x + (i * 20), 16) iPadOffset: ccp(0, -32) iPhone5Offset: ccp(-38, 0)];
			rank3.anchorPoint = ccp(0, 0.5f);
			rank3.visible = NO;
			[_spriteBatch addChild: rank3 z: kButton tag: kRank3];
			x = x + 10;
		}
		
		CCSprite *rankShot;
		if (i == (kMaximumSolutionShots - [table bestShots])) {
			rankShot = [CCSprite spriteWithSpriteFrameName: @"gpTileX.png"];
		}
		else {
			rankShot = [CCSprite spriteWithSpriteFrameName: @"gpTile.png"];
		}
		rankShot.position = [self convertPoint: ccp(x + (i * 20), 10) iPadOffset: ccp(0, -32) iPhone5Offset: ccp(-38, 0)];
		rankShot.anchorPoint = ccp(0, 0.5f);
		rankShot.visible = NO;
		[_spriteBatch addChild: rankShot z: kButton tag: (kRankShot + i)];
	}
	
	CCSprite *scoreLabel = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"gpScore_%@.png", game.language]];
	scoreLabel.position = [self convertPoint: ccp(470, 22) iPadOffset: ccp(0, -32) iPhone5Offset: ccp(38, 0)];
	scoreLabel.anchorPoint = ccp(1.0f, 0.5f);
	scoreLabel.visible = NO;
	scoreLabel.opacity = 77;
	[_spriteBatch addChild: scoreLabel z: kButton tag: kScoreLabel];
	
	CCLabelBMFont *score = [CCLabelBMFont labelWithString: @"0" fntFile: [self convertFileName: @"Font" extension: @"fnt"]];
	[score.texture setAliasTexParameters];
	score.position = [self convertPoint: ccp(470, 8) iPadOffset: ccp(0, -32) iPhone5Offset: ccp(38, 0)];
	score.anchorPoint = ccp(1.0f, 0.5f);
	score.visible = NO;
	[self addChild: score z: kGlow tag: kScore];

	CGSize dimension = CGSizeMake(460, 40);
	if (game.iPad) {
		dimension = CGSizeMake(920, 80);
	}
	CCLabelTTF *infoLabel = [CCLabelTTF labelWithString: @" " dimensions: dimension alignment: CCTextAlignmentCenter fontName: kFont fontSize: [self convertFontSize: 14.0f]];
	[infoLabel.texture setAliasTexParameters];
	infoLabel.position = [self convertPoint: ccp(240, 160)];
	infoLabel.visible = NO;
	[self addChild: infoLabel z: kInfo tag: kInfoLabel];
	
	CCSprite *infoSprite = [CCSprite spriteWithSpriteFrameName: @"gpInfo.png"];
	infoSprite.position = [self convertPoint: ccp(240, 160)];
	infoSprite.visible = NO;
	[_spriteBatch addChild: infoSprite z: kButton tag: kInfoSprite];

	/*CCSprite *infoIcon = [CCSprite spriteWithSpriteFrameName: @"gpInfoIcon_0.png"];
	infoIcon.position = [self convertPoint: ccp(60, 145)];
	infoIcon.visible = NO;
	[_spriteBatch addChild: infoIcon z: kButton tag: kInfoIcon];*/
}

-(void) addMenu {
	
	Game *game = [Game sharedGame];
	
	NSString *gameMenu = [NSString stringWithFormat: @"GameMenu_%@", game.language];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: [self convertFileName: gameMenu extension: @"plist"]];
	
	// GAME
	MenuItemSprite *miTimeout = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmTimeout.png"]
													  selectedSprite: nil
															  target: self
															selector: @selector(menuTimeout:)];
	miTimeout.tag = kTimeoutButton;
	miTimeout.position = [self convertPoint: ccp(224, 144) iPadOffset: ccp(-32, -32) iPhone5Offset: ccp(-6, 0)];
	
	MenuItemSprite *miUndo = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmUndo.png"]
												   selectedSprite: nil
														   target: self
														 selector: @selector(menuUndo:)];
	miUndo.tag = kUndoButton;
	miUndo.position = [self convertPoint: ccp(-224, 144) iPadOffset: ccp(-32, -32) iPhone5Offset: ccp(-82, 0)];
	[miUndo setIsEnabled: NO];
	
	MenuItemSprite *miRanks = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmRanks.png"]
												   selectedSprite: nil
														   target: self
														 selector: @selector(menuRanks:)];
	miRanks.tag = kUndoButton;
	miRanks.position = [self convertPoint: ccp(-224, -144) iPadOffset: ccp(-32, -96) iPhone5Offset: ccp(-82, 0)];
	if ([game canPlayWithoutDelay]) {
		[miRanks setIsEnabled: NO];
	}
	
	// PAUSE
	CGPoint offset = ccp(0, 0);
	if (game.iPad) {
		offset = ccp(32, -64);
	}
	else if (game.iPhone5) {
		offset = ccp(44, 0);
	}
	
	CGPoint iPadOffset = ccp(offset.x + 32, offset.y);
	CGPoint iPhone5Offset = ccp(offset.x + 44, offset.y);
	
	if (game.iPad) {
		offset = ccp(32, -32);
	}
	
	MenuItemSprite *miPaused = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmPaused.png"]
												 selectedSprite: nil
														 target: nil
													   selector: nil];
	miPaused.color = game.lightColor;
	miPaused.tag = kPaused;
	miPaused.position = [self convertPoint: ccp(480, 100) offset: offset];
	[miPaused setIsEnabled: NO];
	miPaused.opacity = 255;
	
	MenuItemSprite *miMenuTimeOutLabel = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmLabelTimeoutMenu.png"]
																 selectedSprite: nil];
	miMenuTimeOutLabel.position = [self convertPoint: ccp(710, -43) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuTimeOutLabel.anchorPoint = ccp(1.0f, 1.0f);
	miMenuTimeOutLabel.tag = kMenuTimeOutLabel;
	[miMenuTimeOutLabel setIsEnabled: NO];
	
	CCSprite *tilehallSprite = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"gmLabelTilehall_%d.png", (game.tilehallIndex + 1)]];
	MenuItemSprite *miMenuTilehallLabel = [MenuItemSprite itemFromNormalSprite: tilehallSprite
																selectedSprite: nil];
	miMenuTilehallLabel.position = [self convertPoint: ccp(250, 43) iPadOffset: ccp(0, -64) iPhone5Offset: ccp(0, 0)];
	miMenuTilehallLabel.anchorPoint = ccp(0.0f, 0.0f);
	[miMenuTilehallLabel setIsEnabled: NO];
	
	CCSprite *tableSprite = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"gmLabelTable_%d.png", (game.tableIndex + 1)]];
	MenuItemSprite *miMenuTableLabel = [MenuItemSprite itemFromNormalSprite: tableSprite
															 selectedSprite: nil];
	miMenuTableLabel.position = ccp(miMenuTilehallLabel.position.x + tilehallSprite.contentSize.width, miMenuTilehallLabel.position.y);
	miMenuTableLabel.anchorPoint = ccp(0.0f, 0.0f);
	[miMenuTableLabel setIsEnabled: NO];
	
	if (game.iPad) {
		offset = ccp(32, -96);
	}
	
	MenuItemSprite *mi11 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmMenu.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuQuit:)];
	mi11.tag = kMenuButtonQuit;
	mi11.position = [self convertPoint: ccp(320, -100) offset: offset];
	
	/*MenuItemSprite *mi12 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmPrevious.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuPrevious:)];
	if ([game previousTable] == nil) {
		[mi12 setIsEnabled: NO];
	}
	mi12.tag = kMenuButtonPrevious;
	mi12.position = [self convertPoint: ccp(-80, -100) offset: offset];*/
	
	MenuItemSprite *mi12 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmDetails_0.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuPauseDetails:)];
	mi12.tag = kMenuButtonPauseDetails;
	mi12.position = [self convertPoint: ccp(400, -100) offset: offset];
	
	MenuItemSprite *mi13 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmPlay.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuResume:)];
	mi13.tag = kMenuButtonPlay;
	mi13.position = [self convertPoint: ccp(480, -100) offset: offset];
	[mi13 runAction: [CCRepeatForever actionWithAction:
					  [CCSequence actions:
					   [CCScaleTo actionWithDuration: 0.4f scale: 1.1f],
					   [CCScaleTo actionWithDuration: 0.4f scale: 1.0f],
					   nil]]];
	
	//Table *next = [game nextTable];
	
	NSString *mi14FrameName = @"gmSkip.png";
	if (![game isLastTable] && [[game table] isCleared]) {
		mi14FrameName = @"gmNext.png";
	}
	MenuItemSprite *mi14 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: mi14FrameName]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuSkipOrNext:)];
	mi14.tag = kMenuButtonSkipOrNext;
	if ([game isLastTable]) {
		[mi14 setIsEnabled: NO];
	}
	mi14.position = [self convertPoint: ccp(560, -100) offset: offset];
	
	MenuItemSprite *mi15 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmRestart.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuRestart:)];
	mi15.tag = kMenuButtonRestart;
	mi15.position = [self convertPoint: ccp(640, -100) offset: offset];
	
	// TABLE CLEARED
	if (game.iPad) {
		offset = ccp(96, -64);
	}
	else if (game.iPhone5) {
		offset = ccp(132, 0);
	}
	
	iPadOffset = ccp(offset.x + 32, offset.y);
	iPhone5Offset = ccp(offset.x + 44, offset.y);
	
	if (game.iPad) {
		offset = ccp(96, -32);
	}
	
	MenuItemSprite *miRank = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmRank_1.png"]
												   selectedSprite: nil
														   target: nil
														 selector: nil];
	miRank.color = game.lightColor;
	miRank.tag = kRank;
	miRank.position = [self convertPoint: ccp(960, 100) offset: offset];
	[miRank setIsEnabled: NO];
	miRank.opacity = 255;
	
	MenuItemSprite *miAward1 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmImprovedResult.png"]
													 selectedSprite: nil
															 target: nil
														   selector: nil];
	miAward1.tag = kAward1;
	miAward1.position = [self convertPoint: ccp(768, 95) offset: offset];
	[miAward1 setIsEnabled: NO];
	
	MenuItemSprite *miAward2 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmBestScore.png"]
													 selectedSprite: nil
															 target: nil
														   selector: nil];
	miAward2.tag = kAward2;
	miAward2.position = [self convertPoint: ccp(1152, 95) offset: offset];
	[miAward2 setIsEnabled: NO];
	
	MenuItemSprite *miMenuTableClearedLabel = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmLabelTableCleared.png"]
																		selectedSprite: nil];
	miMenuTableClearedLabel.position = [self convertPoint: ccp(1190, -40) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuTableClearedLabel.anchorPoint = ccp(1.0f, 1.0f);
	miMenuTableClearedLabel.tag = kMenuTableClearedLabel;
	[miMenuTableClearedLabel setIsEnabled: NO];
	
	CCSprite *tilehallSprite2 = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"gmLabelTilehall_%d.png", (game.tilehallIndex + 1)]];
	MenuItemSprite *miMenuTilehallLabel2 = [MenuItemSprite itemFromNormalSprite: tilehallSprite2
																selectedSprite: nil];
	miMenuTilehallLabel2.position = [self convertPoint: ccp(730, 43) iPadOffset: ccp(64, -64) iPhone5Offset: ccp(88, 0)];
	miMenuTilehallLabel2.anchorPoint = ccp(0.0f, 0.0f);
	[miMenuTilehallLabel2 setIsEnabled: NO];
	
	CCSprite *tableSprite2 = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat: @"gmLabelTable_%d.png", (game.tableIndex + 1)]];
	MenuItemSprite *miMenuTableLabel2 = [MenuItemSprite itemFromNormalSprite: tableSprite2
															 selectedSprite: nil];
	miMenuTableLabel2.position = ccp(miMenuTilehallLabel2.position.x + tilehallSprite2.contentSize.width, miMenuTilehallLabel2.position.y);
	miMenuTableLabel2.anchorPoint = ccp(0.0f, 0.0f);
	[miMenuTableLabel2 setIsEnabled: NO];
	
	if (game.iPad) {
		offset = ccp(96, -96);
	}
	
	MenuItemSprite *mi21 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmMenu.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuQuit:)];
	mi21.tag = kMenuButtonQuit;
	mi21.position = [self convertPoint: ccp(800, -100) offset: offset];
	
	MenuItemSprite *mi22 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmDetails_0.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuDetails:)];
	mi22.tag = kMenuButtonDetails;
	mi22.position = [self convertPoint: ccp(880, -100) offset: offset];
	
	MenuItemSprite *mi23 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmContinue.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuContinue:)];
	mi23.tag = kMenuButtonContinue;
	mi23.position = [self convertPoint: ccp(960, -100) offset: offset];
	[mi23 runAction: [CCRepeatForever actionWithAction:
					  [CCSequence actions:
					   [CCScaleTo actionWithDuration: 0.4f scale: 1.1f],
					   [CCScaleTo actionWithDuration: 0.4f scale: 1.0f],
					   nil]]];
	
	MenuItemSprite *mi24 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmTweet.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuTweet:)];
	mi24.tag = kMenuButtonTweet;
	mi24.position = [self convertPoint: ccp(1040, -100) offset: offset];
	
	MenuItemSprite *mi25 = [MenuItemSprite itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName: @"gmRetry.png"]
												 selectedSprite: nil
														 target: self
													   selector: @selector(menuRetry:)];
	mi25.tag = kMenuButtonRetry;
	mi25.position = [self convertPoint: ccp(1120, -100) offset: offset];
	
	_menu = [[CCMenu menuWithItems:
			  miTimeout, miUndo, miRanks,
			  miPaused,
			  miMenuTimeOutLabel, miMenuTilehallLabel, miMenuTableLabel, mi11, mi12, mi13, mi14, mi15,
			  miRank, miAward1, miAward2,
			  miMenuTableClearedLabel, miMenuTilehallLabel2, miMenuTableLabel2, mi21, mi22, mi23, mi24, mi25,
			  nil] retain];
	//[_menu setIsTouchEnabled: NO];
	
	// add menu into scene
	[self addChild: _menu z: kMenu tag: kMenu];
	
	[self hideMenu];
}

-(void) ready {
	
	[super ready];
	
	Game *game = [Game sharedGame];
	
	if ([game isInState: kGameStarted]) {
		
		// show hints after retry of a table
		if (_hint >= 0) {
			
			//_hint = -1;
			[self showHint];
		}
		
		[self showRanks: game.ranks];
		
		[self showTiles];
		CCSprite *aimer = (CCSprite *) [_spriteBatch getChildByTag: kAimer];
		if (aimer != nil) {
			aimer.opacity = 255;
		}
		
		[self getChildByTag: kScore].visible = YES;
		[_spriteBatch getChildByTag: kScoreLabel].visible = YES;
		
		[super showMenu];
	}
}

-(void) notReady {
	
	_ready = NO;
}

#pragma mark -
#pragma mark Menu System

-(void) showMenu {

	/*if ([Game sharedGame].menu == kMenuTilehallTableSelect) {
		
		[self setTableColor];
	}*/
	
	Game *game = [Game sharedGame];
	
	[super showMenu];
	
	if (game.menu == kMenuPause) {
		
		CCSprite *paused = (CCSprite *) [_menu getChildByTag: kPaused];
		paused.opacity = 0;
		paused.scale = 10.0f;
		[paused runAction: [CCSpawn actions:
							 [CCFadeIn actionWithDuration: 0.3f],
							 [CCScaleTo actionWithDuration: 0.3f scale: 1.0f],
							 nil]];
		
		if (game.sound) {
			[[SimpleAudioEngine sharedEngine] playEffect: kSoundRank];
		}
	}
	[self ready];
}

-(void) showRanks: (BOOL) show {

	[_spriteBatch getChildByTag: kRank1].visible = show;
	[_spriteBatch getChildByTag: kRank2].visible = show;
	[_spriteBatch getChildByTag: kRank3].visible = show;
	
	for (NSInteger i = 0; i < kMaximumSolutionShots; i++) {
		[_spriteBatch getChildByTag: (kRankShot + i)].visible = show;
	}
}

#pragma mark -
#pragma mark Info Message

-(void) showInfoMessage: (NSString *) message type: (NSInteger) type position: (CGPoint) position duration: (float) duration {

	[self showInfoMessage: message type: type position: position duration: duration selector: @selector(hideInfoMessage)];
}

-(void) showInfoMessage: (NSString *) message type: (NSInteger) type position: (CGPoint) position duration: (float) duration selector: (SEL) selector {

	_ready = NO;
	
	CCSprite *infoSprite = (CCSprite *) [_spriteBatch getChildByTag: kInfoSprite];
	if (type == kInfoTypeDetail) {
		[infoSprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"gpDetail.png"]];
	}
	else {
		[infoSprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"gpInfo.png"]];
	}
	infoSprite.position = [self convertPoint: position];
	infoSprite.scale = 0.0f;
	infoSprite.visible = YES;
	
	NSInteger correction = 4;
	if ([message rangeOfString: @"\n"].location == NSNotFound) {
		correction = 12;
	}
	
	CCLabelTTF *infoLabel = (CCLabelTTF *) [self getChildByTag: kInfoLabel];
	[infoLabel setString: message];
	[infoLabel.texture setAliasTexParameters];
	//infoLabel.opacity = 0;
	infoLabel.scale = 0.0f;
	infoLabel.position = [self convertPoint: ccp(position.x, position.y - correction)];
	infoLabel.visible = YES;
	
	if (duration > 0.0f) {
		
		[infoLabel runAction: [CCSequence actions:
							   //[CCDelayTime actionWithDuration: 0.2f],
							   //[CCFadeIn actionWithDuration: kTransitionDuration],
							   [CCScaleTo actionWithDuration: 0.2f scale: 1.0f],
							   [CCDelayTime actionWithDuration: duration],
							   [CCCallFunc actionWithTarget: self selector: selector],
							   nil]];
		[infoSprite runAction: [CCSequence actions:
								//[CCDelayTime actionWithDuration: 0.2f],
								//[CCFadeIn actionWithDuration: kTransitionDuration],
								[CCScaleTo actionWithDuration: 0.2f scale: 1.0f],
								//[CCScaleTo actionWithDuration: 0.2f scaleX: 48.0f scaleY: 1.0f],
								nil]];
	}
	else {
		
		[infoLabel runAction: [CCSequence actions:
							   //[CCDelayTime actionWithDuration: 0.2f],
							   //[CCFadeIn actionWithDuration: kTransitionDuration],
							   [CCScaleTo actionWithDuration: 0.2f scale: 1.0f],
							   [CCCallFunc actionWithTarget: self selector: @selector(infoMessageReady)],
							   nil]];
		[infoSprite runAction: [CCSequence actions:
								//[CCDelayTime actionWithDuration: 0.2f],
								//[CCFadeIn actionWithDuration: kTransitionDuration],
								[CCScaleTo actionWithDuration: 0.2f scale: 1.0f],
								//[CCScaleTo actionWithDuration: 0.2f scaleX: 48.0f scaleY: 1.0f],
								nil]];
	}

	/*if ([Game sharedGame].sound) {
	
		NSString *sound = kSoundInfo;
		if (type == kInfoTypeError) {
			sound = kSoundError;
		}
		[[SimpleAudioEngine sharedEngine] playEffect: sound];
	}*/
	if ([Game sharedGame].sound && (type == kInfoTypeError)) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundError];
	}
}

-(void) infoMessageReady {
	
	/*CCNode *infoIcon = [_spriteBatch getChildByTag: kInfoIcon];
	infoIcon.visible = YES;
	[infoIcon runAction: [CCRepeatForever actionWithAction:
						  [CCSequence actions:
						   [CCScaleTo actionWithDuration: 0.4f scale: 0.8f],
						   [CCScaleTo actionWithDuration: 0.4f scale: 1.0f],
						   nil]
						 ]];*/
	
	_ready = YES;
}

-(void) hideInfoMessage {
	
	/*CCNode *infoIcon = [_spriteBatch getChildByTag: kInfoIcon];
	infoIcon.visible = NO;
	[infoIcon stopAllActions];*/
	
	[_spriteBatch getChildByTag: kInfoSprite].visible = NO;
	[self getChildByTag: kInfoLabel].visible = NO;
}

-(void) showTableNumberAndDescription {
	
	Game *game = [Game sharedGame];
	Table *table = [game table];
	NSString *description = [Localization getStringForKey: [NSString stringWithFormat: @"Description%@", [table name]]];

	NSString *text = [NSString stringWithFormat: [Localization getStringForKey: @"TableNumberAndDescription"], game.tilehallIndex + 1, game.tableIndex + 1, description];
	
	[self showInfoMessage: text type: kInfoTypeHint position: ccp(240, 160) duration: 1.5f selector: @selector(hideTableNumberAndDescription)];
}

-(void) hideTableNumberAndDescription {
	
	[self hideInfoMessage];
	[self ready];
	
	_recording = YES;
}

#pragma mark -
#pragma mark Hints

-(void) showHint {
	
	_ready = NO;
	
	Table *table = [[Game sharedGame] table];
	
	NSString *string = [table hintAtIndex: _hint];
	NSArray *items = [string componentsSeparatedByString:@"|"];
	
	CGPoint position = CGPointFromString((NSString *) [items objectAtIndex: 0]);
	
	NSString *actionString = (NSString *) [items objectAtIndex: 1];
	_action = [actionString integerValue];
	
	float duration = 0.0f;
	if (_action < 0.0f) {
		duration = fabsf(_action);
	}
	
	NSString *key = [NSString stringWithFormat: @"Intro%@_%d", [table name], (_hint + 1)];
	NSString *text = [Localization getStringForKey: key];
	
	[self showInfoMessage: text type: kInfoTypeHint position: position duration: duration selector: @selector(hideHint)];
}

-(void) showNextHint {
	
	Game *game = [Game sharedGame];
	
	if ((_hint + 1) < [[game table] totalHints]) {
		
		[self hideInfoMessage];
		_hint++;
		[self showHint];
	}
	else {
		
		_hint = -1;
		_action = kActionDefault;
		
		[self hideInfoMessage];
		
		[game hintsFinished];
		
		if ([game isInState: kGameEnded]) {
			
			[self showEndOfGame];
		}
		else {
		
			_ready = YES;
		}
	}
}

-(void) hideHint {
	
	[self showNextHint];
}

-(void) showTilesAndButtons {
	
	[self showTiles];
	
	[super showMenu];
	
	[self ready];
}

-(void) showRank {
	
	[self showMenu];
	
	Game *game = [Game sharedGame];
	Table *table = [game table];
	
	CGPoint offset = ccp(0, 0);
	if (game.iPad) {
		offset = ccp(96, -32);
	}
	else if (game.iPhone5) {
		offset = ccp(132, 0);
	}
	
	NSInteger earnedRank = [table rankForShots: [game shots]];
	
	NSString *frameName = [NSString stringWithFormat: @"gmRank_%d.png", earnedRank];
	MenuItemSprite *rank =(MenuItemSprite *) [_menu getChildByTag: kRank];
	CCSprite *rankSprite = (CCSprite* ) rank.normalImage;
	[rankSprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
	rank.opacity = 0;
	rank.scale = 10.0f;
	[rank runAction: [CCSequence actions:
								[CCDelayTime actionWithDuration: 0.5f],
								[CCCallFunc actionWithTarget: self selector: @selector(playRankSound)],
								[CCSpawn actions:
								 [CCFadeIn actionWithDuration: 0.3f],
								 [CCScaleTo actionWithDuration: 0.3f scale: 1.0f],
								 nil],
								nil]];
	
	MenuItemSprite *award1 = (MenuItemSprite *) [_menu getChildByTag: kAward1];
	award1.visible = NO;
	award1.position = [self convertPoint: ccp(1152, 95) iPadOffset: offset iPhone5Offset: offset];
	
	if (_improvedResult) {
		
		award1.visible = YES;
		award1.opacity = 0;
		[award1 runAction: [CCSequence actions:
									[CCDelayTime actionWithDuration: 1.5f],
									[CCCallFunc actionWithTarget: self selector: @selector(playInfoSound)],
									[CCFadeTo actionWithDuration: 0.2f opacity: 77],
									nil]];
	}
		
	MenuItemSprite *award2 = (MenuItemSprite *) [_menu getChildByTag: kAward2];
	award2.visible = NO;
	_tableRecord = NO;
	
	if ([game score] < [table score]) {
	
		_tableRecord = YES;
		
		CCSprite *awardSprite = (CCSprite* ) award2.normalImage;
		[awardSprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"gmTableRecord.png"]];
		
		if (_improvedResult) {
			award1.position = [self convertPoint: ccp(768, 95) iPadOffset: offset iPhone5Offset: offset];
			award2.position = [self convertPoint: ccp(1152, 95) iPadOffset: offset iPhone5Offset: offset];
		}
		else {
			award2.position = [self convertPoint: ccp(1152, 95) iPadOffset: offset iPhone5Offset: offset];
		}
		
		award2.visible = YES;
		award2.opacity = 0;
		[award2 runAction: [CCSequence actions:
								 [CCDelayTime actionWithDuration: (_improvedResult ? 2.5f : 1.5f)],
								 [CCCallFunc actionWithTarget: self selector: @selector(playInfoSound)],
								 [CCFadeTo actionWithDuration: 0.2f opacity: 77],
								 [CCDelayTime actionWithDuration: 0.5f],
								 [CCCallFunc actionWithTarget: self selector: @selector(showTableRecordAlert)],
								 nil]];
	}
	else if ([game score] == [table score]) {
		
		CCSprite *awardSprite = (CCSprite* ) award2.normalImage;
		[awardSprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"gmBestScore.png"]];
		
		if (_improvedResult) {
			award1.position = [self convertPoint: ccp(768, 95) iPadOffset: offset iPhone5Offset: offset];
			award2.position = [self convertPoint: ccp(1152, 95) iPadOffset: offset iPhone5Offset: offset];
		}
		else {
			award2.position = [self convertPoint: ccp(1152, 95) iPadOffset: offset iPhone5Offset: offset];
		}
		
		award2.visible = YES;
		award2.opacity = 0;
		[award2 runAction: [CCSequence actions:
							[CCDelayTime actionWithDuration: (_improvedResult ? 2.5f : 1.5f)],
							[CCCallFunc actionWithTarget: self selector: @selector(playInfoSound)],
							[CCFadeTo actionWithDuration: 0.2f opacity: 77],
							nil]];
	}

	if ([game score] == 147) {
		[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"Maximum"
												 percentComplete: 100];
	}
}

-(void) playRankSound {
	
	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundRank];
	}
}

-(void) playInfoSound {
	
	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTileMove];
	}
}

-(void) showTableRecordAlert {
	
	if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"mailto://"]]) {

		UIAlertView *tableRecordAlert = [[UIAlertView alloc] initWithTitle: [Localization getStringForKey: @"AlertTableRecord"]
																message: [Localization getStringForKey: @"AlertTableRecordMessage"]
															   delegate: self
													  cancelButtonTitle: [Localization getStringForKey: @"AlertButtonNo"]
													  otherButtonTitles: [Localization getStringForKey: @"AlertButtonYes"], nil];
		tableRecordAlert.tag = kAlertTableRecord;
		[tableRecordAlert show];
		[tableRecordAlert release];
	}
}

-(void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {

	if (buttonIndex == 1) {
		if (alertView.tag == kAlertTableRecord) {
			
			Game *game = [Game sharedGame];
			
			NSString *solution = [_solution componentsJoinedByString: @" "];
			NSString *equation = [game equationString];
			NSString *player = @"XXX";
			if ([DDGameKitHelper sharedGameKitHelper].isGameCenterAvailable && ([DDGameKitHelper sharedGameKitHelper].currentPlayerID != nil)) {
				
				GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
				player = [NSString stringWithString: localPlayer.alias];
			}
			NSString *subject = [Localization getStringForKey: @"Subject"];
			NSString *body = [NSString stringWithFormat: [Localization getStringForKey: @"Body"], ([game tilehallIndex] + 1), ([game tableIndex] + 1), solution, equation, player];
			
			subject = [subject stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
			body = [body stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
			body = [body stringByReplacingOccurrencesOfString: @"\n" withString: @"%0A"];
			//body = [body stringByReplacingOccurrencesOfString: @"@" withString: @"%40"];
			body = [body stringByReplacingOccurrencesOfString: @"<" withString: @"%3C"];
			body = [body stringByReplacingOccurrencesOfString: @">" withString: @"%3E"];
			
			NSString *url = [NSString stringWithFormat: @"mailto://contact@2keyplayers.com?subject=%@&body=%@", subject, body];
			[[UIApplication sharedApplication] openURL: [[[NSURL alloc] initWithString: url] autorelease]];
		}
	}
}

-(void) showEndOfGame {

	_ready = NO;
	
	_recording = NO;
	
	_undoPossible = NO;
	
	_detail = -1;
	NSString *frameName = [NSString stringWithFormat: @"gmDetails_%d.png", (_detail + 1)];
	MenuItemSprite *mi = (MenuItemSprite *) [_menu getChildByTag: kMenuButtonDetails];
	CCSprite *sprite = (CCSprite* ) mi.normalImage;
	[sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
	
	[self hideMenu];
	
	MenuItemSprite *undo = (MenuItemSprite *) [_menu getChildByTag: kUndoButton];
	[undo setIsEnabled: NO];
	
	[self getChildByTag: kScore].visible = NO;
	[_spriteBatch getChildByTag: kScoreLabel].visible = NO;
	
	//[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 0.25f];
	
	[self showRanks: NO];
	
	[self closeTableHalfly: @selector(showRank)];
}

-(void) pause {
	
	_ready = NO;
	
	[[Game sharedGame] pause];
	
	[self hideMenu];

	[self getChildByTag: kScore].visible = NO;
	[_spriteBatch getChildByTag: kScoreLabel].visible = NO;
	
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 0.25f];
	
	[self hideTiles];
	CCSprite *aimer = (CCSprite *) [_spriteBatch getChildByTag: kAimer];
	if (aimer != nil) {
		aimer.opacity = 32;
	}
	[self showRanks: NO];
	
	_detail = -1;
	NSString *frameName = [NSString stringWithFormat: @"gmDetails_%d.png", (_detail + 1)];
	MenuItemSprite *mi = (MenuItemSprite *) [_menu getChildByTag: kMenuButtonPauseDetails];
	CCSprite *sprite = (CCSprite* ) mi.normalImage;
	[sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
	
	[self closeTableHalfly: @selector(showMenu)];
}

-(void) resume {
		
	_ready = NO;
	
	[[Game sharedGame] resume];
	
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 0.5f];
	
	[self hideMenu];
	[self hideInfoMessage];
	
	[self openTableHalfly: @selector(ready)];
}

-(void) reset {

	Game *game = [Game sharedGame];
	Table * table = [game table];
	NSArray *layout = [[table layout] componentsSeparatedByCharactersInSet:
                       [NSCharacterSet characterSetWithCharactersInString:@",\n"]];
	[self rackUpTiles: layout];
	
	MenuItemSprite *undo = (MenuItemSprite *) [_menu getChildByTag: kUndoButton];
	[undo setIsEnabled: NO];
	
	if (([table totalHints] > 0) && [table displayHints]) {
		_hint = 0;
	}
	else {
		_hint = -1;
	}
	_undoPossible = NO;
	
	[_solution removeAllObjects];
	[_undoLayouts removeAllObjects];
	
	[game restart];
	[game resetSoundFlags];
	
	[self updateRankShots: YES];
	[self updateScore];
}

-(void) undo {

	Game *game = [Game sharedGame];
	
	NSString *undoLayout = [_undoLayouts lastObject];
	NSArray *layout = [undoLayout componentsSeparatedByCharactersInSet:
					   [NSCharacterSet characterSetWithCharactersInString:@","]];
	[_undoLayouts removeLastObject];

	[self rackUpTiles: layout];
	
	NSInteger index = [_undoLayouts count];
	game.tableStats = _undoStats[index];
	
	[_solution removeLastObject];
	
	[game resetSoundFlags];
	[self updateRankShots: YES];
	[self updateScore];
	
	_undoPossible = ([_undoLayouts count] > 0);

	MenuItemSprite *undo = (MenuItemSprite *) [_menu getChildByTag: kUndoButton];
	[undo setIsEnabled: _undoPossible];
}

-(void) gameplay {
	
	[[CCDirector sharedDirector] replaceScene: [Gameplay scene]];
}

-(void) mainMenu {
	
	[[CCDirector sharedDirector] replaceScene: [MainMenu scene]];
}

-(void) ending {
	
	[[CCDirector sharedDirector] replaceScene: [Ending scene]];
}

-(void) resetAndReady {
	
	[self reset];
	[self ready];
}

-(void) menuTimeout: (CCMenuItem *) menuItem {

	// hide hints
	if (_hint >= 0) {
		
		[self hideInfoMessage];
	}
	
	[self pause];
}

-(void) menuUndo: (CCMenuItem *) menuItem {

	//_ignore = YES;

	if (_hint >= 0) {
		if (_action == kActionUndo) {
			
			[self showNextHint];
		}
		else {
			
			_shake = YES;
			return;
		}
	}
	
	if (_undoPossible) {
		[self undo];
	}
}

-(void) menuRanks: (CCMenuItem *) menuItem {
	
	//_ignore = YES;

	if (_hint >= 0) {
		if (_action == kActionRanks) {
			
			[self showNextHint];
		}
		else {
			
			_shake = YES;
			return;
		}
	}

	Game *game = [Game sharedGame];
	[game switchSettings: kSettingsRanks];
	
	// save game settings
	[game save];
	
	[self showRanks: game.ranks];
	
	if ((_hint >= 0) && (_action == kActionRanks)) {
		
		[self hideHint];
	}

	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuResume: (CCMenuItem *) menuItem {

	[self resume];
	
	//if ([Game sharedGame].sound) {
	//	[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	//}
}

-(void) menuRestart: (CCMenuItem *) menuItem {

	_ready = NO;
	
	[[Game sharedGame] resume];
	
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 0.5f];
	
	[self hideMenu];
	[self hideInfoMessage];
	[self hideAimingAssistent];
	
	[self openTableHalfly: @selector(resetAndReady)];

	//if ([Game sharedGame].sound) {
	//	[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	//}
}

-(void) menuQuit: (CCMenuItem *) menuItem {
	
	Game *game = [Game sharedGame];
	[game stop];
	game.menu = kMenuTilehallTableSelect;
		
	[self hideMenu];
	[self hideInfoMessage];

	[self closeTableHalfAndLoad: @"mainMenu"];

	//if (game.sound) {
	//	[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	//}
}

-(void) menuSkipOrNext: (CCMenuItem *) menuItem {
	
	_ready = NO;
	
	Game *game = [Game sharedGame];
	[game stop];
	
	[self hideMenu];
	[self hideInfoMessage];
	
	if (![[game table] isCleared]) {
		[game skipTable];
	}
	
	Table *next = [game nextTable];
	if (next != nil) {
	
		[game randomizeColor];
		[game setNextTable];
		
		[self closeTableHalfAndLoad: @"gameplay"];
	}
	else {
		
		game.menu = kMenuTilehallTableSelect;
		[game setNextTilehall];
		
		[self closeTableHalfAndLoad: @"mainMenu"];
	}

	//if (game.sound) {
	//	[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	//}
}

-(void) menuPrevious: (CCMenuItem *) menuItem {
	
	_ready = NO;
	
	Game *game = [Game sharedGame];
	[game stop];
	
	[self hideMenu];
	
	if ([game previousTable] != nil) {
	
		[game randomizeColor];
		[game setPreviousTable];
		
		[self closeTableHalfAndLoad: @"gameplay"];
	}

	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuPauseDetails: (id) sender {
	
	Game *game = [Game sharedGame];
	Table *table = [game table];
	NSString *detail = nil;
	
	_detail++;
	if (_detail == 0) {
		
		NSString *description = [Localization getStringForKey: [NSString stringWithFormat: @"Description%@", [table name]]];
		detail = [NSString stringWithFormat: [Localization getStringForKey: @"TableDescription"], description, [table author]];
	}
	else if (_detail == 1) {
		
		NSString *equation = [NSString stringWithFormat: @"%d = %d x %d", [table score], [table shots], [table moves]];
		detail = [NSString stringWithFormat: [Localization getStringForKey: @"CreatorEquation"], [table scoreSetter], equation];
	}
	else if (_detail == 2) {
		
		if ([table bestRank] != kRankNo) {
			detail = [NSString stringWithFormat: [Localization getStringForKey: @"BestRankAndScore"], [Localization getStringForKey: [NSString stringWithFormat: @"Rank_%d", [table bestRank]]], [table bestScore], [table bestShots], ([table bestScore] / [table bestShots])];
		}
		else {
			detail = [Localization getStringForKey: @"BestNoRankAndScore"];
		}
	}
	else if (_detail == 3) {
		
		if ([table bestRank] != kRankNo) {
			detail = [NSString stringWithFormat: [Localization getStringForKey: @"BestSolution"], [table bestSolution]];
		}
		else {
			detail = [Localization getStringForKey: @"BestNoSolution"];
		}
	}
	else if (_detail == 4) {
		
		[self hideInfoMessage];
		_detail = -1;
	}

	if (detail != nil) {
		
		[self showInfoMessage: detail type: kInfoTypeDetail position: ccp(240, 160) duration: 0];
	}
	
	NSString *frameName = [NSString stringWithFormat: @"gmDetails_%d.png", (_detail + 1)];
	MenuItemSprite *mi = (MenuItemSprite *) [_menu getChildByTag: kMenuButtonPauseDetails];
	CCSprite *sprite = (CCSprite* ) mi.normalImage;
	[sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuDetails: (id) sender {
	
	Game *game = [Game sharedGame];
	Table *table = [game table];
	NSString *detail = nil;
	
	_detail++;
	if (_detail == 0) {
		
		NSString *description = [Localization getStringForKey: [NSString stringWithFormat: @"Description%@", [table name]]];
		detail = [NSString stringWithFormat: [Localization getStringForKey: @"TableDescription"], description, [table author]];
	}
	if (_detail == 1) {
		
		detail = [NSString stringWithFormat: [Localization getStringForKey: @"CurrentScoreEquation"], [game equationString]];
	}
	else if (_detail == 2) {
		
		detail = [NSString stringWithFormat: [Localization getStringForKey: @"CurrentSolution"], [_solution componentsJoinedByString: @" "]];
	}
	else if (_detail == 3) {
		
		NSString *equation = [NSString stringWithFormat: @"%d = %d x %d", [table score], [table shots], [table moves]];
		detail = [NSString stringWithFormat: [Localization getStringForKey: @"CreatorEquation"], [table scoreSetter], equation];
	}
	else if (_detail == 4) {
		
		detail = [NSString stringWithFormat: [Localization getStringForKey: @"BestRankAndScore"], [Localization getStringForKey: [NSString stringWithFormat: @"Rank_%d", [table bestRank]]], [table bestScore], [table bestShots], ([table bestScore] / [table bestShots])];
	}
	else if (_detail == 5) {
		
		detail = [NSString stringWithFormat: [Localization getStringForKey: @"BestSolution"], [table bestSolution]];
	}
	else if (_detail == 6) {
		
		[self hideInfoMessage];
		_detail = -1;
	}
	
	if (detail != nil) {
		
		[self showInfoMessage: detail type: kInfoTypeDetail position: ccp(240, 160) duration: 0];
	}
	
	NSString *frameName = [NSString stringWithFormat: @"gmDetails_%d.png", (_detail + 1)];
	MenuItemSprite *mi = (MenuItemSprite *) [_menu getChildByTag: kMenuButtonDetails];
	CCSprite *sprite = (CCSprite* ) mi.normalImage;
	[sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuTweet: (id) sender {
	
	Game *game = [Game sharedGame];

	NSString *rank = [Localization getStringForKey: [NSString stringWithFormat: @"TweetRank_%d", [game rank]]];
	NSString *solution = [_solution componentsJoinedByString: @""];
	NSString *tweet = [NSString stringWithFormat: [Localization getStringForKey: @"Tweet"], ([game tilehallIndex] + 1), ([game tableIndex] + 1), rank, solution];
	
	[self hideInfoMessage];
	
	if ((NSClassFromString(@"TWTweetComposeViewController") != nil) && [TWTweetComposeViewController canSendTweet]) {

		TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
		
		// set initial text
		[tweetViewController setInitialText: tweet];
		
		// setup completion handler
		tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
			if(result == TWTweetComposeViewControllerResultDone) {
				// the user finished composing a tweet
			} else if(result == TWTweetComposeViewControllerResultCancelled) {
				// the user cancelled composing a tweet
			}
			[_viewController dismissViewControllerAnimated: YES completion: nil];
		};
		
		// present view controller
		[[[CCDirector sharedDirector] openGLView] addSubview: _viewController.view];
		[_viewController presentViewController: tweetViewController animated: YES completion: nil];
	}
	else {
		
		tweet = [tweet stringByReplacingOccurrencesOfString: @" " withString: @"%20"];
		tweet = [tweet stringByReplacingOccurrencesOfString: @"#" withString: @"%23"];
		tweet = [tweet stringByReplacingOccurrencesOfString: @"@" withString: @"%40"];
		tweet = [tweet stringByReplacingOccurrencesOfString: @"<" withString: @"%3C"];
		tweet = [tweet stringByReplacingOccurrencesOfString: @">" withString: @"%3E"];
		tweet = [tweet stringByReplacingOccurrencesOfString: @"bit.ly/Tiliard" withString: @"bit.ly%2FTiliard"];
		
		if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"twitter://"]]) {
			
			NSString *url = [NSString stringWithFormat: @"twitter://post?message=%@", tweet];
			[[UIApplication sharedApplication] openURL: [[[NSURL alloc] initWithString: url] autorelease]];
		}
		else if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"http://"]]) {
			
			NSString *url = [NSString stringWithFormat: @"http://twitter.com/home?status=%@", tweet];
			[[UIApplication sharedApplication] openURL: [[[NSURL alloc] initWithString: url] autorelease]];
		}
	}

	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuContinue: (CCMenuItem *) menuItem {
	
	_ready = NO;
	
	Game *game = [Game sharedGame];
	[game stop];
	
	[self hideMenu];
	[self hideInfoMessage];
	
	if (game.showEndOfGame || (game.completed && [game isLastTableInSpin])) {
		
		[game setColorForTable: kTableColorFinal];
		[self closeTableHalfAndLoad: @"ending"];
		
		return;
	}

	if ([game nextTable] != nil) {
	 
		[game randomizeColor];
		[game setNextTable];
		
		[self closeTableHalfAndLoad: @"gameplay"];
	}
	else {
		
		[game setNextTilehall];
		game.menu = kMenuTilehallTableSelect;
		[self closeTableHalfAndLoad: @"mainMenu"];
		
		/*if ([game setNextTilehall]) {
			 
			game.menu = kMenuTilehallTableSelect;
			[self closeTableHalfAndLoad: @"mainMenu"];
		}
		else {
			 
			[game setColorForTable: kTableColorFinal];
			[self closeTableHalfAndLoad: @"ending"];
		}*/
	}
	
	//if (game.sound) {
	//	[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	//}
}

-(void) menuRetry: (CCMenuItem *) menuItem {
	
	Game *game = [Game sharedGame];
	Table *table = [game table];
	if ([table isCleared]) {
	
		if (![game isLastTable]) {
			// change button Skip to Next in pause menu
			MenuItemSprite *mi = (MenuItemSprite *) [_menu getChildByTag: kMenuButtonSkipOrNext];
			CCSprite *sprite = (CCSprite* ) mi.normalImage;
			[sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"gmNext.png"]];
		}
		
		// correct best rank shot
		for (NSInteger i = 0; i < kMaximumSolutionShots; i++) {
			
			CCSprite *rankShot = (CCSprite *) [_spriteBatch getChildByTag: (kRankShot + i)];
			if (i == (kMaximumSolutionShots - [table bestShots])) {
				[rankShot setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"gpTileX.png"]];
			}
			else {
				[rankShot setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"gpTile.png"]];
			}
		}
	}

	[self hideMenu];
	[self hideInfoMessage];
	
	[self openTableHalfly: @selector(resetAndReady)];

	//if ([Game sharedGame].sound) {
	//	[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	//}
}

#pragma mark -
#pragma mark Tile Handling

-(void) rackUpTiles: (NSArray *) layout {

	// clear playable tiles;
	[self removeAllPlayableTiles];
	
	// movement
	_ready = YES;
	_updateTime = 0.0f;
	_movementOnTable = NO;
	_skipMovement = NO;
	_calculateMovement = NO;
	_pottingOnTable = NO;
	
	// clear cue tile position
	_cueTileIsSet = NO;
	_cueShotSelection = NO;
	_cueTile = nil;
	_cueTilePosition.x = _cueTilePosition.y = 0;
	
	for (NSInteger y = (kTableHeight - 1); y >= 0; y--) {
		PositionOnTable positionOnTable;
		positionOnTable.y = (kTableHeight - 1 - y);
		
		for (NSInteger x = 0; x < kTableWidth; x++) {
			positionOnTable.x = x;
			
			NSNumber *number = (NSNumber *) [layout objectAtIndex: (y * kTableWidth + x)];
			
			Tile *tile = [self getTileOnPosition: positionOnTable];
			if (([number integerValue] <= 0) && tile.sprite) {
				[_spriteBatch removeChild: tile.sprite cleanup: NO];
				[tile clearTile];
			}
			
			if ([tile setNumber: [number integerValue]]) {
				
				// add tile's sprite into the batch node
				[_spriteBatch addChild: tile.sprite z: kPlayground];
			}
			
			if ([tile isPlayable]) {
				[self addPlayableTile: tile];
			}
		}
	}

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundRackUp];
	}
}

-(void) clearTiles {
	
	for (NSInteger y = (kTableHeight - 1); y >= 0; y--) {
		PositionOnTable positionOnTable;
		positionOnTable.y = (kTableHeight - 1 - y);
		
		for (NSInteger x = 0; x < kTableWidth; x++) {
			positionOnTable.x = x;
			
			Tile *tile = [self getTileOnPosition: positionOnTable];
			if (![tile isHole] && tile.backgroundSprite) {
				[_spriteBatch removeChild: tile.backgroundSprite cleanup: NO];
			}
		}
	}
}

-(BOOL) canTileBePlayed: (Tile *) tile {
	
	for (NSInteger i = -1; i <= 1; i++) {
		for (NSInteger j = -1; j <= 1; j++) {
			if (!((i == 0) && (j == 0))) {
				
				PositionOnTable positionOnTable;
				positionOnTable.x = tile.positionOnTable.x + i;
				positionOnTable.y = tile.positionOnTable.y + j;
				
				if ((positionOnTable.x >= 0) && (positionOnTable.x < kTableWidth)
					&& (positionOnTable.y >= 0 && positionOnTable.y < kTableHeight)) {
					
					Tile *nearbyTile = [self getTileOnPosition: positionOnTable];
					if ([nearbyTile isEmpty] && ![nearbyTile isHole]) {
						return YES;
					}
				}
			}
		}
	}
	
	return NO;
}

-(Tile *) findClosestPlayableTile: (CGPoint) location {

	Tile *closestTile = nil;
	float closestDistance = -1.0f;
	
	for (Tile *tile in _playableTiles) {
	
		float distance = ccpDistance(tile.sprite.position, location);
		
		if ((closestDistance < 0.0f) || (fabsf(distance) < closestDistance)) {
			if ([self canTileBePlayed: tile]) {
		
				closestDistance = fabsf(distance);
				closestTile = tile;
			}
		}
	}
	
	return closestTile;
}

#pragma mark -
#pragma mark Cue Tile Handling

-(BOOL) canBeACueTile: (Tile *) tile {
	
	for (NSInteger i = -1; i <= 1; i++) {
		for (NSInteger j = -1; j <= 1; j++) {
			if (!((i == 0) && (j == 0))) {
				
				PositionOnTable positionOnTable;
				positionOnTable.x = tile.positionOnTable.x + i;
				positionOnTable.y = tile.positionOnTable.y + j;
				
				if ((positionOnTable.x >= 0) && (positionOnTable.x < kTableWidth)
					&& (positionOnTable.y >= 0 && positionOnTable.y < kTableHeight)) {
					
					Tile *nearbyTile = [self getTileOnPosition: positionOnTable];
					if ([nearbyTile isPlayable]) {
						return YES;
					}
				}
			}
		}
	}
	
	return NO;
}

-(void) clearCueTile {
	
	// clear previous cue position
	if (_cueTile != nil) {
		
		// clear cue tile's sprite
		if (_cueTile.sprite) {
			[_spriteBatch removeChild: _cueTile.sprite cleanup: NO];
		}
		[_cueTile clearTile];
		
		_cueTile = nil;
		_cueTilePosition.x = _cueTilePosition.y = 0;
		
		_cueTileIsSet = NO;
		_cueShotSelection = NO;
		
		// reset shot type
		[Game sharedGame].shot = kShotStraight;
	}
}

-(void) startMovementFromCueTile: (Tile *) tile {
	
	// set directions for tiles affected by the cue tile
	for (NSInteger i = -1; i <= 1; i++) {
		for (NSInteger j = -1; j <= 1; j++) {
			if (!((i == 0) && (j == 0))) {
				
				PositionOnTable positionOnTable;
				positionOnTable.x = tile.positionOnTable.x + i;
				positionOnTable.y = tile.positionOnTable.y + j;
				
				if ((positionOnTable.x >= 0) && (positionOnTable.x < kTableWidth)
					&& (positionOnTable.y >= 0) && (positionOnTable.y < kTableHeight)) {
					
					Tile *nearbyTile = [self getTileOnPosition: positionOnTable];
					
					if ([nearbyTile isPlayable]) {
						Direction direction;
						direction.x = i;
						direction.y = j;
						
						[nearbyTile startMovingInDirection: direction withShot: [Game sharedGame].shot];
					}
				}
			}
		}
	}
	
	/*Game *game = [Game sharedGame];
	if (game.sound) {
	
		SoundFlags soundFlags = game.soundFlags;
		soundFlags.move = YES;
		soundFlags.rebound = YES;
		soundFlags.collision = YES;
		game.soundFlags = soundFlags;
		
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTileShot];
	}*/
}

-(BOOL) isTilePlayableWithCueTile: (Tile *) tile {
	
	if (_cueTile == nil) {
		return NO;
	}
	
	NSInteger x = abs(tile.positionOnTable.x - _cueTile.positionOnTable.x);
	NSInteger y = abs(tile.positionOnTable.y - _cueTile.positionOnTable.y);
	
	if (x > 1 || y > 1) {
		return NO;
	}
	return YES;
}

-(void) playCueTile {
	
	Game *game = [Game sharedGame];
	
	// play cue tile		
	[self startMovementFromCueTile: _cueTile];
	
	char rotation = '-'; // no rotation
	if (game.shot == kShotForwardRotation) {
		rotation = '>';
	}
	else if (game.shot == kShotBackwardRotation) {
		rotation = '<';
	}
	NSString *shot = [NSString stringWithFormat: @"%@%c", [self convertPositionOnTableIntoNotations: _cueTilePosition], rotation];
	
	// add cue position and rotation into solution
	[_solution addObject: shot];
	
	[self clearCueTile];
	
	_calculateMovement = YES;
	_movementOnTable = YES;
	_skipMovement = NO;
	
	[self prepareUndo];
	
	[game addShot];
	[self updateRankShots: NO];
	
	if ((_hint >= 0) && (_action == kActionShot)) {
		
		[self hideHint];
	}
}

-(void) showTiles {
	
	[super showTiles];
	
	if (_cueTile != nil) {
		
		[_cueTile makeSolid];
	}
}

-(void) hideTiles {
	
	[super hideTiles];

	if (_cueTile != nil) {

		[_cueTile makeTransparent];
	}
}

#pragma mark -
#pragma mark Undo

-(void) prepareUndo {

	NSMutableString *undoLayout = [NSMutableString stringWithCapacity: 256];
	for (NSInteger y = (kTableHeight - 1); y >= 0; y--) {
		PositionOnTable positionOnTable;
		//positionOnTable.y = (kTableHeight - 1 - y);
		positionOnTable.y = y;
		
		for (NSInteger x = 0; x < kTableWidth; x++) {
			positionOnTable.x = x;
			
			Tile *tile = [self getTileOnPosition: positionOnTable];
			[undoLayout appendFormat: @"%d,", tile.number];
		}
	}
	NSString *str = [undoLayout substringToIndex: ([undoLayout length] - 1)];
	[_undoLayouts addObject: str];
	
	MenuItemSprite *undo = (MenuItemSprite *) [_menu getChildByTag: kUndoButton];
	[undo setIsEnabled: YES];
	
	_undoPossible = YES;
	
	// backup current level stats
	NSInteger index = [_undoLayouts count] - 1;
	_undoStats[index] = [Game sharedGame].tableStats;
}

#pragma mark -
#pragma mark Aiming Assistent

-(void) showAimingAssistentForTile: (Tile *) tile direction: (Direction) direction {

	Game *game = [Game sharedGame];
	
	//_aimerTile = tile;
	_aimerPosition = tile.positionOnTable;
	_aimerDirection = direction;
	
	NSInteger moves = tile.number;
	if (game.shot == kShotForwardRotation) {
		moves = (moves * 2);
	}
	else if (game.shot == kShotBackwardRotation) {
		moves = (moves / 2.0f + 0.5f);
	}
	
	CCSprite *aimer = (CCSprite *) [_spriteBatch getChildByTag: kAimer];
	aimer.opacity = 0;
	aimer.visible = YES;
	[aimer runAction: [CCSequence actions:
					   [CCRepeat actionWithAction:
						[CCSequence actions:
						 [CCDelayTime actionWithDuration: 0.1f],
						 [CCCallFunc actionWithTarget: self selector: @selector(calculateAimerPosition)],
						 nil]
					    times: moves],
					   //[CCDelayTime actionWithDuration: 1.0f],
					   //[CCCallFunc actionWithTarget: self selector: @selector(hideAimingAssistent)],
					   [CCDelayTime actionWithDuration: 0.1f],
					   [CCCallFunc actionWithTarget: self selector: @selector(resumeAndShowTiles)],
					   nil]];
					   
	[self hideTiles];
	//[tile makeSolid];
}

-(void) calculateAimerPosition {
	
	CCSprite *aimer = (CCSprite *) [_spriteBatch getChildByTag: kAimer];
	
	Tile *tile = [self getTileOnPosition: _aimerPosition];
	if (([Game sharedGame].tilehallIndex == kTilehallTraining) && [tile isHole]) {
		
		[aimer stopAllActions];
		[aimer runAction: [CCSequence actions:
						   //[CCDelayTime actionWithDuration: 0.5f],
						   //[CCCallFunc actionWithTarget: self selector: @selector(hideAimingAssistent)],
						   [CCDelayTime actionWithDuration: 0.1f],
						   [CCCallFunc actionWithTarget: self selector: @selector(resumeAndShowTiles)],
						   nil]];
	}
	else {

		_aimerDirection = [self directionForPosition: _aimerPosition direction: _aimerDirection];
		_aimerPosition.x = _aimerPosition.x + _aimerDirection.x;
		_aimerPosition.y = _aimerPosition.y + _aimerDirection.y;

		aimer.opacity = 255;
		aimer.position = [self convertPoint: ccp((_aimerPosition.x * kTileSize) + (kTileSize / 2), ((_aimerPosition.y + 1) * kTileSize) + (kTileSize / 2))];
		
		/*if ((_aimerPosition.x == _aimerTile.positionOnTable.x) && (_aimerPosition.y == _aimerTile.positionOnTable.y)) {
			[_aimerTile makeTransparent];
		}
		else {
			[_aimerTile makeSolid];
		}*/
	}
}

-(void) hideAimingAssistent {

	CCNode *aimer = [_spriteBatch getChildByTag: kAimer];
	aimer.visible = NO;
	[aimer stopAllActions];
	
	[self showTiles];
	[[Game sharedGame] resume];
}

-(void) resumeAndShowTiles {

	[self showTiles];
	[[Game sharedGame] resume];
}

#pragma mark -
#pragma mark Touch Handling

-(void) registerWithTouchDispatcher {

	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority: kCCMenuTouchPriority swallowsTouches: YES];
}

-(BOOL) ccTouchBegan: (UITouch *) touch withEvent: (UIEvent *) event {

	Game *game = [Game sharedGame];
	
	if (!_ready || [game isInState: kGameStopped]) {
		return NO;
	}
	
	if ([game isInState: kGameAborted]) {
		
		[game resume];
		[self hideInfoMessage];
		[self undo];
		return NO;
	}
	
	if ([game isInState: kGameAiming]) {
		
		/*if (_action == kActionHideAiming) {
			[self showNextHint];
		}
		else {
			[self hideAimingAssistent];
		}*/
		[self hideAimingAssistent];
		return NO;
	}
	
	CGPoint location = [self convertTouchToNodeSpace: touch];
	if (game.iPad && (((location.x - 32) < 0.0f) || ((location.y - 64) < 0.0f))) {
		return NO;
	}
	else if (game.iPhone5 && ((location.x - 44) < 0.0f)) {
		return NO;
	}
	
	// hide aimer if visible
	if ([_spriteBatch getChildByTag: kAimer].visible) {
		[self hideAimingAssistent];
	}
	
	PositionOnTable positionOnTable = [self convertLocationToTablePosition: location];
	
	if (_movementOnTable) {
		if (!_skipMovement) {
			_skipMovement = YES;
		}
		/*else {
			_shake = YES;
		}*/
		return NO;
	}
	if ([game isInState: kGamePaused]) {
		return NO;
	}
	
	if ((_hint >= 0) && ((_action == kActionTap) || (_action < 0))) {
		
		[self hideHint];
		return NO;
	}
	
	if ([game isInState: kGameEnded]) {
		return NO;
	}
	
	// check if we are on the table
	if ((positionOnTable.y >= 0) && (positionOnTable.y < kTableHeight)) {
		
		Tile *tile = [self getTileOnPosition: positionOnTable];
		
		_tapPoint = location;

		if (touch.tapCount == 2) {
				
			_doubleTap = YES;
			//_tapPoint = location;
			return YES;
		}
		
		if (_cueTileIsSet && [tile isCue]) {
			
			// do nothing, we might shoot or select shot type
		}
		else if ([tile isEmpty] && ![tile isHole]) {
			
			_cueTileIsSet = NO;
			
			if ([self canBeACueTile: tile]) {
				
				[self clearCueTile];
				[tile setNumber: kCueTile];
				//[tile makeSemiTransparent];
				
				[_spriteBatch addChild: tile.sprite];
				
				// set new cue position
				_cueTile = tile;
				_cueTilePosition = positionOnTable;
			}
			else {
				
				Tile *closestTile = [self findClosestPlayableTile: location];
				
				if (closestTile != nil) {
                    
					float offRealX = (location.x - closestTile.sprite.position.x);
					float offRealY = (location.y - closestTile.sprite.position.y);
					
					float angleRadians = atanf(offRealY / offRealX);
					float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
					float angle = fabs(angleDegrees);  //-1 * angleDegrees;
					
					Direction direction;
					direction.x = direction.y = 0;
					//direction.x = MAX(-1, MIN(1, tile.positionOnTable.x - closestTile.positionOnTable.x));
					//direction.y = MAX(-1, MIN(1, tile.positionOnTable.y - closestTile.positionOnTable.y));
					if (angle < 22.5f) {
						direction.x = ((positionOnTable.x - closestTile.positionOnTable.x) > 0) ? 1 : (-1);
					}
					else if (angle < 67.5f) {
						direction.x = ((positionOnTable.x - closestTile.positionOnTable.x) > 0) ? 1 : (-1);
						direction.y = ((positionOnTable.y - closestTile.positionOnTable.y) > 0) ? 1 : (-1);
					}
					else {
						direction.y = ((positionOnTable.y - closestTile.positionOnTable.y) > 0) ? 1 : (-1);
					}
					
                    positionOnTable = closestTile.positionOnTable;
                    positionOnTable.x = (positionOnTable.x + direction.x);
                    positionOnTable.y = (positionOnTable.y + direction.y);
					
					Tile *possibleCueTile = [self getTileOnPosition: positionOnTable];
					if ([possibleCueTile isHole]) {
					
						// special case if the possible cue tile is one of the middle pockets
						if (positionOnTable.y == 0) {
							positionOnTable.y = positionOnTable.y + 1;
						}
						else if (positionOnTable.y == (kTableHeight - 1)) {
							positionOnTable.y = positionOnTable.y - 1;
						}
						possibleCueTile = [self getTileOnPosition: positionOnTable];
					}
					
					if (([possibleCueTile isEmpty] || [possibleCueTile isCue])) {
					
						[self clearCueTile];
						[possibleCueTile setNumber: kCueTile];
						//[possibleCueTile makeSemiTransparent];
						
						[_spriteBatch addChild: possibleCueTile.sprite];
						
						// set closest cue tile
						_cueTile = possibleCueTile;
						_cueTilePosition = _cueTile.positionOnTable;
					}
				}
				else {
					
					[self clearCueTile];
				}
			}
		}
		else if (_cueTileIsSet && [tile isPlayable] && [self isTilePlayableWithCueTile: tile]) {
			
			if ((_hint >= 0) && (_action != kActionAiming)) {
				
				_shake = YES;
				return NO;
			}
			
			Direction direction;
			direction.x = tile.positionOnTable.x - _cueTile.positionOnTable.x;
			direction.y = tile.positionOnTable.y - _cueTile.positionOnTable.y;
			
			[game aim];
			[self showAimingAssistentForTile: tile direction: direction];
			
			if ((_hint >= 0) && (_action == kActionAiming)) {
				
				[self hideHint];
			}
			
			return NO;
		}
		else {
			
			_shake = YES;
			return NO;
		}
	}
	else {
	
		[self clearCueTile];
	}
	
	return YES;
}

-(void) ccTouchMoved: (UITouch *) touch withEvent: (UIEvent *) event {

	CGPoint location = [self convertTouchToNodeSpace: touch];
	PositionOnTable positionOnTable = [self convertLocationToTablePosition: location];
	
	Game *game = [Game sharedGame];
	
	/*if ((_hint >= 0) && (_action == kActionSwipe)) {
		
		[self hideHint];
		return;
	}*/

	if ([game isInState: kGameEnded]) {
		return; // no need to go further in code
	}
	
	CGPoint diff = ccpSub(location, _tapPoint);
	// 3D Touch fix
	if ((diff.x == 0) && (diff.y == 0)) {
		return;
	}
	
	if (_cueTileIsSet) {
		
		_cueShotSelection = YES;
		
		if ([game isRotationEnabled]) {
			
			CGPoint pointOfTouch = (_doubleTap ? _tapPoint : _cueTile.sprite.position);
			CGPoint distance = ccpSub(location, pointOfTouch);
			
			//float angleRadians = atanf(distance.y / distance.x);
			//float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
			//float cocosAngle = -1 * angleDegrees;
			
			if (fabsf(distance.y) < 16) {
				game.shot = kShotStraight;
				[_cueTile changeShot: kShotStraight];
			}
			// forward or side rotation
			else if (distance.y > 0) {
				if (fabs(distance.y) > fabs(distance.x)) {
					game.shot = kShotForwardRotation;
					[_cueTile changeShot: kShotForwardRotation];
				}
				else {
					game.shot = kShotStraight;
					[_cueTile changeShot: kShotStraight];
					
					/* UPDATE ver. 1.1
					game.shot = kShotSideRotation;
					[_cueTile changeShot: kShotSideRotation];*/
				}
			}
			// backward or side rotation
			else {
				if (fabs(distance.y) > fabs(distance.x)) {
					game.shot = kShotBackwardRotation;
					[_cueTile changeShot: kShotBackwardRotation];
				}
				else {
					game.shot = kShotStraight;
					[_cueTile changeShot: kShotStraight];
					
					/* UPDATE ver. 1.1
					game.shot = kShotSideRotation;
					[_cueTile changeShot: kShotSideRotation];*/
				}
			}
		}
		
		if ((_hint >= 0) && (_action == kActionRotation)) {
			
			[self hideHint];
			_ready = YES;
		}
	}
	else if ((positionOnTable.y >= 0) && (positionOnTable.y < kTableHeight)) {

		Tile *tile = [self getTileOnPosition: positionOnTable];

		if ((_cueTilePosition.x != positionOnTable.x) || (_cueTilePosition.y != positionOnTable.y)) {
				
			if ([self canBeACueTile: tile] && ![tile isPlayable] && ![tile isHole]) {
					
				[_cueTile setSpritePosition: positionOnTable];

				// set new cue position and store previous
				_cueTilePosition = positionOnTable;
			}
			else {
				
				Tile *closestTile = [self findClosestPlayableTile: location];
				
				if (closestTile != nil) {
				
					float offRealX = (location.x - closestTile.sprite.position.x);
					float offRealY = (location.y - closestTile.sprite.position.y);
					
					float angleRadians = atanf(offRealY / offRealX);
					float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
					float angle = fabs(angleDegrees);  //-1 * angleDegrees;
					
					Direction direction;
					direction.x = direction.y = 0;
					//direction.x = MAX(-1, MIN(1, tile.positionOnTable.x - closestTile.positionOnTable.x));
					//direction.y = MAX(-1, MIN(1, tile.positionOnTable.y - closestTile.positionOnTable.y));
					if (angle < 22.5f) {
						direction.x = ((positionOnTable.x - closestTile.positionOnTable.x) > 0) ? 1 : (-1);
					}
					else if (angle < 67.5f) {
						direction.x = ((positionOnTable.x - closestTile.positionOnTable.x) > 0) ? 1 : (-1);
						direction.y = ((positionOnTable.y - closestTile.positionOnTable.y) > 0) ? 1 : (-1);
					}
					else {
						direction.y = ((positionOnTable.y - closestTile.positionOnTable.y) > 0) ? 1 : (-1);
					}
					
					positionOnTable = closestTile.positionOnTable;
					positionOnTable.x = (positionOnTable.x + direction.x);
					positionOnTable.y = (positionOnTable.y + direction.y);
					
					Tile *possibleCueTile = [self getTileOnPosition: positionOnTable];
					if (([possibleCueTile isEmpty] || [possibleCueTile isCue]) && ![possibleCueTile isHole]) {
						
						[_cueTile setSpritePosition: positionOnTable];
						
						// set new cue position and store previous
						_cueTilePosition = positionOnTable;
					}
				}
				else {
					
					[self clearCueTile];
				}
			}
		}
	}
}

-(void) ccTouchEnded: (UITouch *) touch withEvent: (UIEvent *) event {

	//CGPoint location = [self convertTouchToNodeSpace: touch];
	//PositionOnTable positionOnTable = [self convertLocationToTablePosition: location];
	
	//Game *game = [Game sharedGame];
	
	// check if this touch should not be ignored
	if (_ignore) {
		
		_ignore = NO;
		_button = kButtonDefault;
		return;
	}
	
	if (!_cueTileIsSet && (_cueTile != nil)) {
		
		_cueTileIsSet = YES;
		
		if ((_cueTile.positionOnTable.x != _cueTilePosition.x) || (_cueTile.positionOnTable.y != _cueTilePosition.y)) {
			
			Tile *newCueTile = [self getTileOnPosition: _cueTilePosition];
			[newCueTile copyTile: _cueTile];
			[_cueTile clearTile];
			
			_cueTile = newCueTile;
		}
		
		//[_cueTile makeSolid];
		
		if ((_hint >= 0) && (_action == kActionSet)) {
			
			[self hideHint];
		}
	}
	else if (_cueTileIsSet) {
		if (_doubleTap) {
		
			_doubleTap = NO;
			
			if ((_hint >= 0) && (_action != kActionShot)) {
				
				_shake = YES;
				return;
			}
			
			[self playCueTile];
		}
		else if (_cueShotSelection) {
			
			_cueShotSelection = NO;
		}
		else {
			
			if ((_hint >= 0) && (_action != kActionShot)) {
				
				_shake = YES;
				return;
			}
			
			[self playCueTile];
		}
	}
}

-(void) ccTouchCancelled: (UITouch *) touch withEvent: (UIEvent *) event {

	[self clearCueTile];
	
	_ignore = NO;
	_button = kButtonDefault;
	_doubleTap = NO;
	
	//[self ccTouchEnded: touch withEvent: event];
}

#pragma mark -
#pragma mark Update

-(void) update: (ccTime) dt {
	
	[super update: dt];

	Game *game = [Game sharedGame];
	
	if (![game isInState: kGameStarted]) {
		return;
	}
	
	if (_movementOnTable) {
		
		_updateTime = _updateTime + dt;
		
		if (_calculateMovement) {
			
			NSInteger counter = 0;
			
			while (_calculateMovement) {
				
				_calculateMovement = NO;
				
				//NSMutableArray *playableTilesCopy = [[NSMutableArray alloc] initWithArray: _playableTiles copyItems: YES];
				NSMutableArray *playableTilesCopy = [NSMutableArray arrayWithCapacity: 16];
				for (Tile *tile in _playableTiles) {
					
					[playableTilesCopy addObject: tile];
				}
				
				for (Tile *tile in playableTilesCopy) {
					
					if ([tile shouldMove]) {
						
						// try to move tile and check whether another tile was affected by this movement
						if (![self moveTile: tile]) {
							
							_calculateMovement = YES;
							//break;
						}
					}
				}
				
				if (_calculateMovement) {
					counter++;
				}
				
				// check for a deadlock
				if (counter > 100) {
					
					_deadlock = YES;
					
					[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"Deadlock"
															 percentComplete: 100];
					
					[game abort];
					[self showInfoMessage: [Localization getStringForKey: @"DeadlockDetected"] type: kInfoTypeError position: ccp(240, 160) duration: 0 selector: @selector(hideInfoMessage)];
					
					return;
				}
			}
		}
		
		if (_skipMovement || (_updateTime >= kTableSpeed)) {
			
			_calculateMovement = YES;
			_movementOnTable = NO;
			_pottingOnTable = NO;
			
			_deadlock = NO;
			
			//NSMutableArray *playableTilesCopy = [[NSMutableArray alloc] initWithArray: _playableTiles copyItems: YES];
			NSMutableArray *playableTilesCopy = [NSMutableArray arrayWithCapacity: 16];
			for (Tile *tile in _playableTiles) {
					
				// check deadlock
				if ([tile isDeadlock]) {
					_deadlock = YES;
					break;
				}
				
				[playableTilesCopy addObject: tile];
			}
			
			if (_deadlock) {
			
				[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"Deadlock"
														 percentComplete: 100];
														 
				[game abort];
				[self showInfoMessage: [Localization getStringForKey: @"DeadlockDetected"] type: kInfoTypeError position: ccp(240, 160) duration: 0 selector: @selector(hideInfoMessage)];
				
				return;
			}
				
			// perform move animations on tiles
			for (Tile *tile in playableTilesCopy) {
			
				// movement and potting
				if ([tile shouldMove]) {

					_movementOnTable = YES;
				}
				else if ([tile isMoving] || [tile isBeingPotted]) {
					
					// only calculate movement when finished moving tiles
					if ([tile isMoving]) {
						_movementOnTable = YES;
						_calculateMovement = NO;
						
						SoundFlags soundFlags = game.soundFlags;
						if (!soundFlags.move && game.sound) {
							
							soundFlags.move = YES;
							game.soundFlags = soundFlags;
							[[SimpleAudioEngine sharedEngine] playEffect: kSoundTileMove];
						}
					}
					else {
						_pottingOnTable = YES;
						
						SoundFlags soundFlags = game.soundFlags;
						if (!soundFlags.pot && game.sound) {
							
							soundFlags.pot = YES;
							game.soundFlags = soundFlags;
							[[SimpleAudioEngine sharedEngine] playEffect: kSoundTilePot];
						}
					}
					
					if ([tile update: dt skip: _skipMovement]) {
						
						// clear tile's sprite and other attributes
						if (tile.sprite) {
							[_spriteBatch removeChild: tile.sprite cleanup: NO];
						}
						
						// tile potted, remove it from playable tiles
						[self removePlayableTile: tile];
						[tile clearTile];
						
						if ((game.tilehallIndex == kTilehallTraining) && (game.tableIndex == 0)) {
							
							[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"FirstPot"
																	 percentComplete: 100];
						}
						
						if (_tilesForCentury >= 0 && _tilesForCentury < 100) {
							
							_tilesForCentury = _tilesForCentury + 1;
							[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"Century"
																	 percentComplete: _tilesForCentury];
						}
						if (_tilesForWillieM >= 0 && _tilesForWillieM < 100) {
							
							_tilesForWillieM = _tilesForWillieM + 0.19015f;
							if (_tilesForWillieM >= 100.0f) {
								[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"WillieM"
																		 percentComplete: 100];
							}
							else {
								[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"WillieM"
																		 percentComplete: _tilesForWillieM];
							}
						}
						
						game.tpRanking = game.tpRanking + 1;
						[[DDGameKitHelper sharedGameKitHelper] submitScore: game.tpRanking category: @"TpRankings"];
					}
				}
			}
			
			if (!_movementOnTable && _pottingOnTable) {

				_movementOnTable = YES;
				_calculateMovement = NO;
				
				[self updateScore];
			}
			if (_calculateMovement) {
				
				_updateTime = 0.0f;
				
				[self updateScore];
				[game resetSoundFlags];
			}
				
			if (!_movementOnTable) {
				
				[game resetSoundFlags];
				if ([_playableTiles count] == 0) {

					_ready = NO;
					
					[game end];
					
					NSString *s = [_solution componentsJoinedByString: @" "];
					_improvedResult = [game clearedTableWithShots: [game shots] score: [game score] solution: s];
					
					//if (_hint < 0) {
					//	[self showEndOfGame];
					//}
					[self runAction: [CCSequence actions:
									  [CCDelayTime actionWithDuration: 0.5f],
									  [CCCallFunc actionWithTarget: self selector: @selector(showEndOfGame)],
									  nil]];
				}
				else {
					
					[self updateRankShots: YES];
					
					if ([game shots] == kMaximumSolutionShots) {
					 
						[game abort];
						[self showInfoMessage: [Localization getStringForKey: @"MaximumShotsReached"] type: kInfoTypeError position: ccp(240, 160) duration: 0 selector: @selector(hideInfoMessage)];
					}
					else {
						for (Tile *tile in _playableTiles) {
							
							[tile resetCollision];
						}
					}
				}
			}
		}
	}
	else if (_glowType == kGlowDisabled) {
	
		// glow on tiles instead of table
		_updateTime = _updateTime + dt;
		if (_timeBetweenGlows < 5.0f) {
			_timeBetweenGlows = (arc4random() % 3) + 5;
		}
		
		if (_updateTime > _timeBetweenGlows) {
			
			_updateTime = 0.0f;
			_timeBetweenGlows = (arc4random() % 3) + 5;
			
			// display glow on a random tile
			NSInteger index = [_playableTiles count];
			if (index > 0) {
			
				index = (arc4random() % index);
				Tile *tile = [_playableTiles objectAtIndex: index];
				
				CCSprite *glow = (CCSprite *) [self getChildByTag: kGlow];
				glow.color = kColorWhite;
				glow.visible = YES;
				
				NSInteger offset = (kTileSize / 2) - 1;
				if (game.iPad) {
					offset = 2 * offset;
				}
				glow.position = ccp(tile.sprite.position.x + offset, tile.sprite.position.y + offset);
				
				[glow runAction: _glow];
			}
		}
		
		// perform animations on tiles
		/*for (Tile *tile in _playableTiles) {
		
			[tile update: dt];
		}*/
	}
	
	if (_shake) {
		
		_shake = NO;
		_ready = NO;
		
		//[self stopAllActions];
		CCSequence * shake = [CCSequence actions:
							  [CCMoveBy actionWithDuration: 0.05 position: ccp(0, 10)],
							  [CCMoveBy actionWithDuration: 0.1 position: ccp(0, -20)],
							  [CCMoveTo actionWithDuration: 0.1 position: ccp(0, 10)],
							  [CCMoveTo actionWithDuration: 0.05 position: ccp(0, 0)],
							  [CCCallFunc actionWithTarget: self selector: @selector(ready)],
							  nil];
		[self runAction: shake];
		
		if (game.sound) {
			[[SimpleAudioEngine sharedEngine] playEffect: kSoundError];
		}
	}
}

-(void) updateRankShots: (BOOL) ranks {
	
	Game *game = [Game sharedGame];
	Table *table = [game table];
	
	NSInteger shots = [game shots];
	for (NSInteger i = 0; i < kMaximumSolutionShots; i++) {
		CCSprite *rankShot = (CCSprite *) [_spriteBatch getChildByTag: (kRankShot + i)];
		
		if (shots < (kMaximumSolutionShots - i)) {
			rankShot.opacity = 255;
		}
		else {
			rankShot.opacity = 77;
		}
	}
	
	if (ranks) {
		
		CCSprite *rank1 = (CCSprite *) [_spriteBatch getChildByTag: kRank1];
		CCSprite *rank2 = (CCSprite *) [_spriteBatch getChildByTag: kRank2];
		CCSprite *rank3 = (CCSprite *) [_spriteBatch getChildByTag: kRank3];
		if (shots < [table shotsForRank: kRankStar]) {
			rank3.opacity = 255;
		}
		else {
			rank3.opacity = 77;
		}
		if (shots < [table shotsForRank: kRankPro]) {
			rank2.opacity = 255;
		}
		else {
			rank2.opacity = 77;
		}
		if (shots < kMaximumSolutionShots) {
			rank1.opacity = 255;
		}
		else {
			rank1.opacity = 77;
		}
	}
}

-(void) updateScore {

	Game *game = [Game sharedGame];

	CCLabelTTF *score = (CCLabelTTF *) [self getChildByTag: kScore];
	[score setString: [game scoreString]];
}

#pragma mark -
#pragma mark Glow

-(CGPoint) getGlowPosition {

	CGPoint glowPosition;
	Game *game = [Game sharedGame];
	
	if ([game isLanguage: kLanguageEnglish]) {
		if ([game isInState: kGamePaused]) {
			
			NSInteger i = arc4random() % 24;
			switch (i) {
				case 0:
					glowPosition.x = 113;
					glowPosition.y = 268;
					break;
				case 1:
					glowPosition.x = 146;
					glowPosition.y = 268;
					break;
				case 2:
					glowPosition.x = 113;
					glowPosition.y = 235;
					break;
				case 3:
					glowPosition.x = 124;
					glowPosition.y = 235;
					break;
					
				case 4:
					glowPosition.x = 168;
					glowPosition.y = 268;
					break;
				case 5:
					glowPosition.x = 179;
					glowPosition.y = 268;
					break;
				case 6:
					glowPosition.x = 157;
					glowPosition.y = 235;
					break;
				case 7:
					glowPosition.x = 190;
					glowPosition.y = 235;
					break;
					
				case 8:
					glowPosition.x = 201;
					glowPosition.y = 268;
					break;
				case 9:
					glowPosition.x = 234;
					glowPosition.y = 268;
					break;
				case 10:
					glowPosition.x = 201;
					glowPosition.y = 235;
					break;
				case 11:
					glowPosition.x = 234;
					glowPosition.y = 235;
					break;
					
				case 12:
					glowPosition.x = 256;
					glowPosition.y = 268;
					break;
				case 13:
					glowPosition.x = 278;
					glowPosition.y = 268;
					break;
				case 14:
					glowPosition.x = 245;
					glowPosition.y = 235;
					break;
				case 15:
					glowPosition.x = 267;
					glowPosition.y = 235;
					break;
					
				case 16:
					glowPosition.x = 289;
					glowPosition.y = 268;
					break;
				case 17:
					glowPosition.x = 322;
					glowPosition.y = 268;
					break;
				case 18:
					glowPosition.x = 289;
					glowPosition.y = 235;
					break;
				case 19:
					glowPosition.x = 322;
					glowPosition.y = 235;
					break;
					
				case 20:
					glowPosition.x = 333;
					glowPosition.y = 268;
					break;
				case 21:
					glowPosition.x = 355;
					glowPosition.y = 268;
					break;
				case 22:
					glowPosition.x = 333;
					glowPosition.y = 235;
					break;
				case 23:
					glowPosition.x = 355;
					glowPosition.y = 235;
					break;
			}
		}
		else if ([game rank] == kRankPlayer) {
			
			NSInteger i = arc4random() % 24;
			switch (i) {
				case 0:
					glowPosition.x = 113;
					glowPosition.y = 268;
					break;
				case 1:
					glowPosition.x = 146;
					glowPosition.y = 268;
					break;
				case 2:
					glowPosition.x = 113;
					glowPosition.y = 235;
					break;
				case 3:
					glowPosition.x = 124;
					glowPosition.y = 235;
					break;
					
				case 4:
					glowPosition.x = 157;
					glowPosition.y = 268;
					break;
				case 5:
					glowPosition.x = 168;
					glowPosition.y = 268;
					break;
				case 6:
					glowPosition.x = 157;
					glowPosition.y = 235;
					break;
				case 7:
					glowPosition.x = 190;
					glowPosition.y = 235;
					break;
					
				case 8:
					glowPosition.x = 212;
					glowPosition.y = 268;
					break;
				case 9:
					glowPosition.x = 223;
					glowPosition.y = 268;
					break;
				case 10:
					glowPosition.x = 201;
					glowPosition.y = 235;
					break;
				case 11:
					glowPosition.x = 234;
					glowPosition.y = 235;
					break;
					
				case 12:
					glowPosition.x = 245;
					glowPosition.y = 268;
					break;
				case 13:
					glowPosition.x = 278;
					glowPosition.y = 268;
					break;
				case 14:
					glowPosition.x = 256;
					glowPosition.y = 235;
					break;
				case 15:
					glowPosition.x = 267;
					glowPosition.y = 235;
					break;
					
				case 16:
					glowPosition.x = 289;
					glowPosition.y = 268;
					break;
				case 17:
					glowPosition.x = 322;
					glowPosition.y = 268;
					break;
				case 18:
					glowPosition.x = 289;
					glowPosition.y = 235;
					break;
				case 19:
					glowPosition.x = 322;
					glowPosition.y = 235;
					break;
					
				case 20:
					glowPosition.x = 333;
					glowPosition.y = 268;
					break;
				case 21:
					glowPosition.x = 366;
					glowPosition.y = 268;
					break;
				case 22:
					glowPosition.x = 333;
					glowPosition.y = 235;
					break;
				case 23:
					glowPosition.x = 366;
					glowPosition.y = 235;
					break;
			}
		}
		else if ([game rank] == kRankPro) {
			
			NSInteger i = arc4random() % 12;
			switch (i) {
				case 0:
					glowPosition.x = 179;
					glowPosition.y = 268;
					break;
				case 1:
					glowPosition.x = 212;
					glowPosition.y = 268;
					break;
				case 2:
					glowPosition.x = 179;
					glowPosition.y = 235;
					break;
				case 3:
					glowPosition.x = 190;
					glowPosition.y = 235;
					break;
					
				case 4:
					glowPosition.x = 223;
					glowPosition.y = 268;
					break;
				case 5:
					glowPosition.x = 256;
					glowPosition.y = 268;
					break;
				case 6:
					glowPosition.x = 223;
					glowPosition.y = 235;
					break;
				case 7:
					glowPosition.x = 256;
					glowPosition.y = 235;
					break;

				case 8:
					glowPosition.x = 278;
					glowPosition.y = 268;
					break;
				case 9:
					glowPosition.x = 289;
					glowPosition.y = 268;
					break;
				case 10:
					glowPosition.x = 278;
					glowPosition.y = 235;
					break;
				case 11:
					glowPosition.x = 289;
					glowPosition.y = 235;
					break;
			}
		}
		else if ([game rank] == kRankStar) {
			
			NSInteger i = arc4random() % 16;
			switch (i) {
				case 0:
					glowPosition.x = 168;
					glowPosition.y = 268;
					break;
				case 1:
					glowPosition.x = 190;
					glowPosition.y = 268;
					break;
				case 2:
					glowPosition.x = 157;
					glowPosition.y = 235;
					break;
				case 3:
					glowPosition.x = 179;
					glowPosition.y = 235;
					break;
					
				case 4:
					glowPosition.x = 201;
					glowPosition.y = 268;
					break;
				case 5:
					glowPosition.x = 234;
					glowPosition.y = 268;
					break;
				case 6:
					glowPosition.x = 212;
					glowPosition.y = 235;
					break;
				case 7:
					glowPosition.x = 223;
					glowPosition.y = 235;
					break;
					
				case 8:
					glowPosition.x = 256;
					glowPosition.y = 268;
					break;
				case 9:
					glowPosition.x = 267;
					glowPosition.y = 268;
					break;
				case 10:
					glowPosition.x = 245;
					glowPosition.y = 235;
					break;
				case 11:
					glowPosition.x = 278;
					glowPosition.y = 235;
					break;
					
				case 12:
					glowPosition.x = 289;
					glowPosition.y = 268;
					break;
				case 13:
					glowPosition.x = 322;
					glowPosition.y = 268;
					break;
				case 14:
					glowPosition.x = 289;
					glowPosition.y = 235;
					break;
				case 15:
					glowPosition.x = 322;
					glowPosition.y = 235;
					break;
			}
		}
	}
	else {
		if ([game isInState: kGamePaused]) {
			
			NSInteger i = arc4random() % 20;
			switch (i) {
				case 0:
					glowPosition.x = 135;
					glowPosition.y = 268;
					break;
				case 1:
					glowPosition.x = 168;
					glowPosition.y = 268;
					break;
				case 2:
					glowPosition.x = 135;
					glowPosition.y = 235;
					break;
				case 3:
					glowPosition.x = 146;
					glowPosition.y = 235;
					break;
					
				case 4:
					glowPosition.x = 190;
					glowPosition.y = 268;
					break;
				case 5:
					glowPosition.x = 201;
					glowPosition.y = 268;
					break;
				case 6:
					glowPosition.x = 179;
					glowPosition.y = 235;
					break;
				case 7:
					glowPosition.x = 212;
					glowPosition.y = 235;
					break;
					
				case 8:
					glowPosition.x = 223;
					glowPosition.y = 268;
					break;
				case 9:
					glowPosition.x = 256;
					glowPosition.y = 268;
					break;
				case 10:
					glowPosition.x = 223;
					glowPosition.y = 235;
					break;
				case 11:
					glowPosition.x = 256;
					glowPosition.y = 235;
					break;
					
				case 12:
					glowPosition.x = 267;
					glowPosition.y = 268;
					break;
				case 13:
					glowPosition.x = 289;
					glowPosition.y = 268;
					break;
				case 14:
					glowPosition.x = 278;
					glowPosition.y = 235;
					break;
				case 15:
					glowPosition.x = 300;
					glowPosition.y = 235;
					break;
					
				case 16:
					glowPosition.x = 322;
					glowPosition.y = 268;
					break;
				case 17:
					glowPosition.x = 333;
					glowPosition.y = 268;
					break;
				case 18:
					glowPosition.x = 311;
					glowPosition.y = 235;
					break;
				case 19:
					glowPosition.x = 344;
					glowPosition.y = 235;
					break;
			}
		}
		else if ([game rank] == kRankPlayer) {
			
			NSInteger i = arc4random() % 16;
			switch (i) {
				case 0:
					glowPosition.x = 157;
					glowPosition.y = 268;
					break;
				case 1:
					glowPosition.x = 190;
					glowPosition.y = 268;
					break;
				case 2:
					glowPosition.x = 157;
					glowPosition.y = 235;
					break;
				case 3:
					glowPosition.x = 190;
					glowPosition.y = 235;
					break;
					
				case 4:
					glowPosition.x = 201;
					glowPosition.y = 268;
					break;
				case 5:
					glowPosition.x = 234;
					glowPosition.y = 268;
					break;
				case 6:
					glowPosition.x = 201;
					glowPosition.y = 235;
					break;
				case 7:
					glowPosition.x = 234;
					glowPosition.y = 235;
					break;
					
				case 8:
					glowPosition.x = 256;
					glowPosition.y = 268;
					break;
				case 9:
					glowPosition.x = 267;
					glowPosition.y = 268;
					break;
				case 10:
					glowPosition.x = 245;
					glowPosition.y = 235;
					break;
				case 11:
					glowPosition.x = 278;
					glowPosition.y = 235;
					break;
					
				case 12:
					glowPosition.x = 289;
					glowPosition.y = 268;
					break;
				case 13:
					glowPosition.x = 322;
					glowPosition.y = 268;
					break;
				case 14:
					glowPosition.x = 289;
					glowPosition.y = 235;
					break;
				case 15:
					glowPosition.x = 322;
					glowPosition.y = 235;
					break;
			}
		}
		else if ([game rank] == kRankPro) {
			
			NSInteger i = arc4random() % 24;
			switch (i) {
				case 0:
					glowPosition.x = 124;
					glowPosition.y = 268;
					break;
				case 1:
					glowPosition.x = 157;
					glowPosition.y = 268;
					break;
				case 2:
					glowPosition.x = 124;
					glowPosition.y = 235;
					break;
				case 3:
					glowPosition.x = 135;
					glowPosition.y = 235;
					break;
					
				case 4:
					glowPosition.x = 168;
					glowPosition.y = 268;
					break;
				case 5:
					glowPosition.x = 201;
					glowPosition.y = 268;
					break;
				case 6:
					glowPosition.x = 168;
					glowPosition.y = 235;
					break;
				case 7:
					glowPosition.x = 201;
					glowPosition.y = 235;
					break;
					
				case 8:
					glowPosition.x = 223;
					glowPosition.y = 268;
					break;
				case 9:
					glowPosition.x = 234;
					glowPosition.y = 268;
					break;
				case 10:
					glowPosition.x = 223;
					glowPosition.y = 235;
					break;
				case 11:
					glowPosition.x = 234;
					glowPosition.y = 235;
					break;
					
				case 12:
					glowPosition.x = 256;
					glowPosition.y = 268;
					break;
				case 13:
					glowPosition.x = 289;
					glowPosition.y = 268;
					break;
				case 14:
					glowPosition.x = 256;
					glowPosition.y = 235;
					break;
				case 15:
					glowPosition.x = 267;
					glowPosition.y = 235;
					break;
					
				case 16:
					glowPosition.x = 300;
					glowPosition.y = 268;
					break;
				case 17:
					glowPosition.x = 311;
					glowPosition.y = 268;
					break;
				case 18:
					glowPosition.x = 300;
					glowPosition.y = 235;
					break;
				case 19:
					glowPosition.x = 311;
					glowPosition.y = 235;
					break;
					
				case 20:
					glowPosition.x = 322;
					glowPosition.y = 268;
					break;
				case 21:
					glowPosition.x = 355;
					glowPosition.y = 268;
					break;
				case 22:
					glowPosition.x = 322;
					glowPosition.y = 235;
					break;
				case 23:
					glowPosition.x = 355;
					glowPosition.y = 235;
					break;
			}
		}
		else if ([game rank] == kRankStar) {
			
			NSInteger i = arc4random() % 28;
			switch (i) {
				case 0:
					glowPosition.x = 102;
					glowPosition.y = 268;
					break;
				case 1:
					glowPosition.x = 135;
					glowPosition.y = 268;
					break;
				case 2:
					glowPosition.x = 102;
					glowPosition.y = 235;
					break;
				case 3:
					glowPosition.x = 135;
					glowPosition.y = 235;
					break;
					
				case 4:
					glowPosition.x = 146;
					glowPosition.y = 268;
					break;
				case 5:
					glowPosition.x = 179;
					glowPosition.y = 268;
					break;
				case 6:
					glowPosition.x = 157;
					glowPosition.y = 235;
					break;
				case 7:
					glowPosition.x = 168;
					glowPosition.y = 235;
					break;
					
				case 8:
					glowPosition.x = 190;
					glowPosition.y = 268;
					break;
				case 9:
					glowPosition.x = 201;
					glowPosition.y = 268;
					break;
				case 10:
					glowPosition.x = 190;
					glowPosition.y = 235;
					break;
				case 11:
					glowPosition.x = 201;
					glowPosition.y = 235;
					break;
					
				case 12:
					glowPosition.x = 212;
					glowPosition.y = 268;
					break;
				case 13:
					glowPosition.x = 245;
					glowPosition.y = 268;
					break;
				case 14:
					glowPosition.x = 212;
					glowPosition.y = 235;
					break;
				case 15:
					glowPosition.x = 245;
					glowPosition.y = 235;
					break;
					
				case 16:
					glowPosition.x = 256;
					glowPosition.y = 268;
					break;
				case 17:
					glowPosition.x = 278;
					glowPosition.y = 268;
					break;
				case 18:
					glowPosition.x = 267;
					glowPosition.y = 235;
					break;
				case 19:
					glowPosition.x = 289;
					glowPosition.y = 235;
					break;
					
				case 20:
					glowPosition.x = 300;
					glowPosition.y = 268;
					break;
				case 21:
					glowPosition.x = 322;
					glowPosition.y = 268;
					break;
				case 22:
					glowPosition.x = 300;
					glowPosition.y = 235;
					break;
				case 23:
					glowPosition.x = 322;
					glowPosition.y = 235;
					break;
					
				case 24:
					glowPosition.x = 355;
					glowPosition.y = 268;
					break;
				case 25:
					glowPosition.x = 366;
					glowPosition.y = 268;
					break;
				case 26:
					glowPosition.x = 344;
					glowPosition.y = 235;
					break;
				case 27:
					glowPosition.x = 377;
					glowPosition.y = 235;
					break;
			}
		}
	}
	
	return glowPosition;
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[_viewController release];
	_viewController = nil;
	
	[_cueTile release];
	_cueTile = nil;
	
	[_undoLayouts release];
	_undoLayouts = nil;
	
	[_solution release];
	_solution = nil;
	
	[super dealloc];
}

@end
