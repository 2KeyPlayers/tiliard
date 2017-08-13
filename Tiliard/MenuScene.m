//
//  MenuScene.m
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/01/11.
//  Copyright 2 Key Players 2010-2012. All rights reserved.
//

#import "MenuScene.h"
#import "GameplayScene.h"
#import "Localization.h"
#import "DDGameKitHelper.h"


@implementation MainMenu

#pragma mark -
#pragma mark Scene Creator

+(id) scene {

	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	[scene addChild: [MainMenu node]];
	
	return scene;
}

-(id) init {

    if ((self = [super init])) {
		
		_showTileInterval = 0.0f;
	
		Game *game = [Game sharedGame];
		
		_languageChanged = NO;
		_tileSetAlert = YES;
		
		_more = false;
	
		[self addBackground];
		[self addPlayground];
		[self addMenu];
		[self hideMenu];
		
		_showTile = [[CCSequence actions:
					 [CCFadeIn actionWithDuration: 0.3f],
					 [CCDelayTime actionWithDuration: 1.0f],
					 [CCFadeOut actionWithDuration: 0.3f],
					 nil] retain];
		
		SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
		if (sae != nil) {
			sae.effectsVolume = (game.music ? 0.1f : 0.3f);
			[sae preloadBackgroundMusic: @"MusicMenu.mp3"];
			if (sae.willPlayBackgroundMusic) {
				sae.backgroundMusicVolume = 0.5f;
			}
			
			[sae preloadEffect: kSoundMenuTap];
			[sae preloadEffect: kSoundMenuSlide];
			[sae preloadEffect: kSoundTableCloseFull];
			[sae preloadEffect: kSoundTableCloseHalf];
			[sae preloadEffect: kSoundTableOpenFull];
			[sae preloadEffect: kSoundTableOpenFull];
		}

		CCNode *tiliard = [self getChildByTag: kTiliard];
		if (game.menu == kMenuMain) {

			[[DDGameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
			
			[tiliard runAction: [CCMoveTo actionWithDuration: kHalfTableMovementDuration position: [self convertPoint: ccp(240, 260) iPadOffset: ccp(0, 32) iPhone5Offset: ccp(0, 0)]]];
			[self openTableHalf: @selector(showMenu)];
		}
		else {
			
			tiliard.position = [self convertPoint: ccp(240, 260) iPadOffset: ccp(0, 32) iPhone5Offset: ccp(0, 0)];
			[self menuPlay: nil];
		}
		
		//self.isTouchEnabled = YES;
		//self.isAccelerometerEnabled = YES;
		//[self scheduleUpdate];
		//_updateTable = YES;
		
		_ready = YES;
	}
    return self;
}

-(void) onEnter {
	
	[self hideActivityIndicator];
	[self scheduleUpdate];
	
	[self randomizeTile];
	
	if ([Game sharedGame].music) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic: @"MusicMenu.mp3"];
	}
		
	[super onEnter];
}

#pragma mark -
#pragma mark Content Builders

-(void) addBackground {
	
	Game *game = [Game sharedGame];
	
	// add background (containing light and grid)
	CCSprite *bg = [CCSprite spriteWithSpriteFrameName: @"gpBackground.png"];
	bg.position = [self convertPoint: ccp(240, 160)];
	[_spriteBatch addChild: bg z: kBackground tag: kBackground];
	
	if (game.iPad || game.iPhone5) {
		
		CCSprite *bl = [CCSprite spriteWithSpriteFrameName: @"gpBorder.png"];
		//CCSprite *bl = [CCSprite spriteWithSpriteFrameName: @"gpBorderLeft.png"];
		bl.anchorPoint = ccp(1.0f, 0.5f);
		
		CCSprite *br = [CCSprite spriteWithSpriteFrameName: @"gpBorder.png"];
		br.flipX = YES;
		//CCSprite *br = [CCSprite spriteWithSpriteFrameName: @"gpBorderRight.png"];
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
	
	// add upper and lower table parts
	CCSprite *upperTable = [CCSprite spriteWithSpriteFrameName: @"gpTable.png"];
	upperTable.flipX = YES;
	upperTable.flipY = YES;
	upperTable.position = [self convertPoint: ccp(240, 256)];
	[_spriteBatch addChild: upperTable z: kTable tag: kUpperTable];
	
	CCSprite *lowerTable = [CCSprite spriteWithSpriteFrameName: @"gpTable.png"];
	lowerTable.position = [self convertPoint: ccp(240, 64)];
	[_spriteBatch addChild: lowerTable z: kTable tag: kLowerTable];
	
	[self setTableColor];
    
	// add glow effect
	CCSprite *glow = [CCSprite spriteWithSpriteFrameName: @"gpGlow.png"];
	glow.position = [self convertPoint: ccp(240, 160) offset: ccp(0, 32)];
	glow.visible = NO;
	glow.color = [Game sharedGame].lightColor;
	glow.opacity = 0;
	glow.scale = 0.0f;
	[self addChild: glow z: kGlow tag: kGlow];
}

-(void) randomizeTile {
	
	Game *game = [Game sharedGame];
	
	NSInteger tileNumber = (arc4random() % 15) + 1;
	if (tileNumber == _tileNumber) {
		
		tileNumber = ((tileNumber + 1) % 15) + 1;
	}
	_tileNumber = tileNumber;
	
	if (game.tileSet > 0) {
		_tileSet = 'A' + game.tileSet - 1;
	}
	else {
		NSInteger unlockedTilehalls = 1;
		for (NSInteger i = 1; i < kTilehallComingSoon; i++) {
			if (![game tilehallAtIndex: i].unlocked) {
				break;
			}
			unlockedTilehalls++;
		}
		_tileSet = (arc4random() % unlockedTilehalls) + 'A';
	}
	
	CCSprite *tile = (CCSprite *) [_spriteBatch getChildByTag: kMenuTile];
	NSString *frameName = [NSString stringWithFormat: @"%d%c.png", _tileNumber, _tileSet];
	[tile setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
	
	NSInteger x = (arc4random() % 13);
	NSInteger y = (arc4random() % 2);
	x = x + 1;
	y = (y == 0) ? 3 : 6;
	_tilePosition.x = x;
	_tilePosition.y = y;
	
	if (y == 3) {
		switch (arc4random() % 3) {
			case 0:
				_tileDirection.x = -1;
				_tileDirection.y = 1;
				break;
			case 1:
				_tileDirection.x = 0;
				_tileDirection.y = 1;
				break;
			case 2:
				_tileDirection.x = 1;
				_tileDirection.y = 1;
				break;
		}
	}
	else {
		switch (arc4random() % 3) {
			case 0:
				_tileDirection.x = -1;
				_tileDirection.y = -1;
				break;
			case 1:
				_tileDirection.x = 0;
				_tileDirection.y = -1;
				break;
			case 2:
				_tileDirection.x = 1;
				_tileDirection.y = -1;
				break;
		}
	}
	
	tile.position = [self convertPoint: ccp((x * kTileSize) + (kTileSize / 2), (y * kTileSize) + (kTileSize / 2))];
	
	[tile runAction: [CCSequence actions:
					  [CCDelayTime actionWithDuration: 1.5f],
					  //[CCCallFunc actionWithTarget: self selector: @selector(playTileMoveSound)],
					  [CCMoveTo actionWithDuration: 0.3f position: [self calculateTilePosition]],
					  [CCDelayTime actionWithDuration: 0.1f],
					  //[CCCallFunc actionWithTarget: self selector: @selector(playTileMoveSound)],
					  [CCMoveTo actionWithDuration: 0.3f position: [self calculateTilePosition]],
					  [CCDelayTime actionWithDuration: 0.1f],
					  //[CCCallFunc actionWithTarget: self selector: @selector(playTileMoveSound)],
					  [CCMoveTo actionWithDuration: 0.3f position: [self calculateTilePosition]],
					  [CCDelayTime actionWithDuration: 1.5f],
					  [CCCallFunc actionWithTarget: self selector: @selector(randomizeTile)],
					  nil]];
}

-(CGPoint) calculateTilePosition {
	
	_tileDirection = [self directionForPosition: _tilePosition direction: _tileDirection];
	_tilePosition.x = _tilePosition.x + _tileDirection.x;
	_tilePosition.y = _tilePosition.y + _tileDirection.y;
	
	return [self convertPoint: ccp((_tilePosition.x * kTileSize) + (kTileSize / 2), (_tilePosition.y * kTileSize) + (kTileSize / 2))];
}

-(void) playTileMoveSound {
	
	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundTileMove];
	}
}

-(void) addPlayground {

	CCSprite *tile = [CCSprite spriteWithSpriteFrameName: @"1A.png"];
	tile.position = [self convertPoint: ccp(240, 208)];
	//tile.visible = YES;
	//tile.opacity = 0;
	[_spriteBatch addChild: tile z: kPlayground tag: kMenuTile];
	
	/*[tile runAction: [CCRepeatForever actionWithAction:
					  [CCSequence actions:
					   [CCCallFunc actionWithTarget: self selector: @selector(randomizeTile)],
					   [CCDelayTime actionWithDuration: 3.0f],
					   [CCRepeat actionWithAction:
						[CCSequence actions:
						 [CCMoveTo actionWithDuration: 0.5f position: [self calculateTilePosition]],
						 [CCDelayTime actionWithDuration: 0.1f],
						 nil] times: 4],
					   nil]]];*/
}

-(void) addMenu {
	
	Game *game = [Game sharedGame];
	
	NSString *mainMenu = [NSString stringWithFormat: @"MainMenu_%@", game.language];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: [self convertFileName: mainMenu extension: @"plist"]];

	// add Tiliard logo
	CCSprite *tiliard = [CCSprite spriteWithSpriteFrameName: @"mmTiliard.png"];
	tiliard.position = [self convertPoint: ccp(240, 222) iPadOffset: ccp(0, 32) iPhone5Offset: ccp(0, 0)];
	tiliard.color = game.lightColor;
	[self addChild: tiliard z: kTable tag: kTiliard];
	
	// SETTINGS
	CGPoint offset = ccp(0, 0);
	if (game.iPad) {
		offset = ccp(-32, -64);
	}
	else if (game.iPhone5) {
		offset = ccp(-44, 0);
	}
	
	CGPoint iPadOffset = ccp(offset.x + 32, offset.y);
	CGPoint iPhone5Offset = ccp(offset.x + 44, offset.y);
	
	MenuItemSprite *miMenuOptionsLabel = [MenuItemSprite itemWithSpriteFrameName: @"mmLabelOptions.png"
																		   target: nil
																		 selector: nil];
	miMenuOptionsLabel.position = [self convertPoint: ccp(230, -40) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuOptionsLabel.anchorPoint = ccp(1.0f, 1.0f);
	miMenuOptionsLabel.tag = kMenuOptionsLabel;
	[miMenuOptionsLabel setIsEnabled: NO];
	//miMenuOptionsLabel.opacity = 255;
	
	iPadOffset = ccp(offset.x - 32, offset.y);
	iPhone5Offset = ccp(offset.x - 44, offset.y);
	
	MenuItemSprite *miMenuCloudLabel = [MenuItemSprite itemWithSpriteFrameName: @"mmLabelCloud.png"
																		  target: nil
																		selector: nil];
	miMenuCloudLabel.position = [self convertPoint: ccp(-230, 43) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuCloudLabel.anchorPoint = ccp(0.0f, 0.0f);
	miMenuCloudLabel.tag = kMenuCloudLabel;
	[miMenuCloudLabel setIsEnabled: NO];
	if (!game.iCloud) {
		miMenuCloudLabel.opacity = 0;
	}
	
	if (game.iPad) {
		offset = ccp(-32, -96);
	}
	
	MenuItemSprite *mi10 = [MenuItemSprite itemWithSpriteFrameName: @"mmMore.png"
															target: self
														  selector: @selector(menuMore:)];
	mi10.tag = kMenuButtonMore;
	mi10.position = [self convertPoint: ccp(-175, -100) offset: offset];
	
	MenuItemSprite *mi11On = [MenuItemSprite itemWithSpriteFrameName: @"mmMusic.png"
															  target: nil
															selector: nil];
	MenuItemSprite *mi11Off = [MenuItemSprite itemWithSpriteFrameName: @"mmMusicOff.png"
															   target: nil
															 selector: nil];
	MenuItemSprite *mi11a = (game.music) ? mi11On : mi11Off;
	MenuItemSprite *mi11b = (game.music) ? mi11Off : mi11On;
	CCMenuItemToggle *mi11 = [CCMenuItemToggle itemWithTarget: self
													 selector: @selector(menuMusic:)
														items: mi11a, mi11b, nil];
	mi11.tag = kMenuButtonMusic;
	mi11.position = [self convertPoint: ccp(-105, -100) offset: offset];
	
	NSString *mi15Color = [NSString stringWithFormat: @"mmTableColor_%d.png", game.clothColor];
	MenuItemSprite *mi15 = [MenuItemSprite itemWithSpriteFrameName: mi15Color
															target: self
														  selector: @selector(menuChangeColor:)];
	mi15.tag = kMenuButtonClothColor;
	mi15.position = [self convertPoint: ccp(-105, -100) offset: offset];
	
	MenuItemSprite *mi12On = [MenuItemSprite itemWithSpriteFrameName: @"mmSound.png"
															  target: nil
															selector: nil];
	MenuItemSprite *mi12Off = [MenuItemSprite itemWithSpriteFrameName: @"mmSoundOff.png"
															   target: nil
															 selector: nil];
	MenuItemSprite *mi12a = (game.sound) ? mi12On : mi12Off;
	MenuItemSprite *mi12b = (game.sound) ? mi12Off : mi12On;
	CCMenuItemToggle *mi12 = [CCMenuItemToggle itemWithTarget: self
													 selector: @selector(menuSound:)
														items: mi12a, mi12b, nil];
	mi12.tag = kMenuButtonSound;
	mi12.position = [self convertPoint: ccp(-35, -100) offset: offset];
	
	/*MenuItemSprite *mi16On = [MenuItemSprite itemWithSpriteFrameName: @"mmCloudOn.png"
															  target: nil
															selector: nil];
	MenuItemSprite *mi16Off = [MenuItemSprite itemWithSpriteFrameName: @"mmCloudOff.png"
															   target: nil
															 selector: nil];
	MenuItemSprite *mi16a = (game.cloud && game.iCloud) ? mi16On : mi16Off;
	MenuItemSprite *mi16b = (game.cloud && game.iCloud) ? mi16Off : mi16On;
	CCMenuItemToggle *mi16 = [CCMenuItemToggle itemWithTarget: self
													 selector: @selector(menuCloud:)
														items: mi16a, mi16b, nil];
	mi16.tag = kMenuButtonCloud;
	mi16.position = [self convertPoint: ccp(-35, -100) offset: offset];
	if (!game.iCloud) {
		[mi16 setIsEnabled: NO];
	}*/
	
	NSString *mi16Set = [NSString stringWithFormat: @"mmTileSet_%d.png", game.tileSet];
	MenuItemSprite *mi16 = [MenuItemSprite itemWithSpriteFrameName: mi16Set
															target: self
														  selector: @selector(menuChangeTileSet:)];
	mi16.tag = kMenuButtonTileSet;
	mi16.position = [self convertPoint: ccp(-35, -100) offset: offset];
	
	MenuItemSprite *mi13Eng = [MenuItemSprite itemWithSpriteFrameName: @"mmEnglish.png"
															   target: nil
															 selector: nil];
	MenuItemSprite *mi13Svk = [MenuItemSprite itemWithSpriteFrameName: @"mmSlovencina.png"
															   target: nil
															 selector: nil];
	MenuItemSprite *mi13a = [game isLanguage: kLanguageEnglish] ? mi13Eng : mi13Svk;
	MenuItemSprite *mi13b = [game isLanguage: kLanguageEnglish] ? mi13Svk : mi13Eng;
	CCMenuItemToggle *mi13 = [CCMenuItemToggle itemWithTarget: self
													 selector: @selector(menuLanguage:)
														items: mi13a, mi13b, nil];
	mi13.tag = kMenuButtonLanguage;
	mi13.position = [self convertPoint: ccp(35, -100) offset: offset];
	
	MenuItemSprite *mi17 = [MenuItemSprite itemWithSpriteFrameName: @"mmRate.png"
															target: self
														  selector: @selector(menuRate:)];
	/*MenuItemSprite *mi17 = [MenuItemSprite itemWithSpriteFrameName: @"mmGift.png"
															target: self
														  selector: @selector(menuGift:)];*/
	mi17.tag = kMenuButtonGiftRate;
	mi17.position = [self convertPoint: ccp(35, -100) offset: offset];
	
	
	MenuItemSprite *mi14 = [MenuItemSprite itemWithSpriteFrameName: @"mmReset.png"
															target: self
														  selector: @selector(menuResetProgress:)];
	mi14.tag = kMenuButtonResetProgress;
	mi14.position = [self convertPoint: ccp(105, -100) offset: offset];
	
	MenuItemSprite *mi18 = [MenuItemSprite itemWithSpriteFrameName: @"mmShare.png"
															target: self
														  selector: @selector(menuShare:)];
	mi18.tag = kMenuButtonShare;
	mi18.position = [self convertPoint: ccp(105, -100) offset: offset];
	if (NSClassFromString(@"UIActivityViewController") == nil) {
		[mi18 setIsEnabled: NO];
	}
	
	MenuItemSprite *mi19 = [MenuItemSprite itemWithSpriteFrameName: @"mmBackReverse.png"
															target: self
														  selector: @selector(menuBack:)];
	mi19.tag = kMenuButtonResetProgress;
	mi19.position = [self convertPoint: ccp(175, -100) offset: offset];
	
	mi11.visible = !_more;
	mi12.visible = !_more;
	mi13.visible = !_more;
	mi14.visible = !_more;
	mi15.visible = _more;
	mi16.visible = _more;
	mi17.visible = _more;
	mi18.visible = _more;
	
	// MAIN MENU
	if (game.iPad) {
		offset = ccp(32, -64);
	}
	else if (game.iPhone5) {
		offset = ccp(44, 0);
	}
	
	iPadOffset = ccp(offset.x + 32, offset.y);
	iPhone5Offset = ccp(offset.x + 44, offset.y);
	
	MenuItemSprite *miMenuMainLabel = [MenuItemSprite itemWithSpriteFrameName: @"mmLabelMainMenu.png"
																	target: nil
																  selector: nil];
	miMenuMainLabel.position = [self convertPoint: ccp(710, -40) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuMainLabel.anchorPoint = ccp(1.0f, 1.0f);
	miMenuMainLabel.tag = kMenuMainLabel;
	[miMenuMainLabel setIsEnabled: NO];
	//miMenuMainLabel.opacity = 255;
	
	if (game.iPad) {
		offset = ccp(32, -96);
	}
	
	MenuItemSprite *mi21 = [MenuItemSprite itemWithSpriteFrameName: @"mmOptions.png"
															target: self
														  selector: @selector(menuOptions:)];
	mi21.tag = kMenuButtonOptions;
	mi21.position = [self convertPoint: ccp(320, -100) offset: offset];
	
	MenuItemSprite *mi22 = [MenuItemSprite itemWithSpriteFrameName: @"mmEditor.png"
															target: self
														  selector: @selector(menuEditor:)];
	mi22.tag = kMenuButtonEditor;
	mi22.position = [self convertPoint: ccp(400, -103) offset: offset];
	
	MenuItemSprite *mi23 = [MenuItemSprite itemWithSpriteFrameName: @"mmPlay.png"
															target: self
														  selector: @selector(menuPlay:)];
	mi23.tag = kMenuButtonPlay;
	mi23.position = [self convertPoint: ccp(480, -100) offset: offset];
	[mi23 runAction: [CCRepeatForever actionWithAction:
					  [CCSequence actions:
					   [CCScaleTo actionWithDuration: 0.4f scale: 1.1f],
					   [CCScaleTo actionWithDuration: 0.4f scale: 1.0f],
					   nil]]];
	
	MenuItemSprite *mi24 = [MenuItemSprite itemWithSpriteFrameName: @"mmGameCenter.png"
															target: self
														  selector: @selector(menuGameCenter:)];
	[mi24 setIsEnabled: [DDGameKitHelper sharedGameKitHelper].isGameCenterAvailable];
	mi24.tag = kMenuButtonGameCenter;
	mi24.position = [self convertPoint: ccp(560, -103) offset: offset];
	
	MenuItemSprite *mi25 = [MenuItemSprite itemWithSpriteFrameName: @"mmCredits.png"
															target: self
														  selector: @selector(menuCredits:)];
	mi25.tag = kMenuButtonCredits;
	mi25.position = [self convertPoint: ccp(640, -100) offset: offset];
	
	// CREDITS
	if (game.iPad) {
		offset = ccp(96, -64);
	}
	else if (game.iPhone5) {
		offset = ccp(132, 0);
	}
	
	iPadOffset = ccp(offset.x + 32, offset.y);
	iPhone5Offset = ccp(offset.x + 44, offset.y);
	
	MenuItemSprite *miMenuCreditsLabel = [MenuItemSprite itemWithSpriteFrameName: @"mmLabelCredits.png"
																		  target: nil
																		selector: nil];
	miMenuCreditsLabel.position = [self convertPoint: ccp(1190, -43) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuCreditsLabel.anchorPoint = ccp(1.0f, 1.0f);
	miMenuCreditsLabel.tag = kMenuCreditsLabel;
	[miMenuCreditsLabel setIsEnabled: NO];
	//miMenuCreditsLabel.opacity = 255;
	
	iPadOffset = ccp(offset.x - 32, offset.y);
	iPhone5Offset = ccp(offset.x - 44, offset.y);
	
	/*MenuItemSprite *miMenuVersionLabel = [MenuItemSprite itemWithSpriteFrameName: @"mmLabelVersion.png"
																		  target: nil
																		selector: nil];
	miMenuVersionLabel.position = [self convertPoint: ccp(730, 43) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuVersionLabel.anchorPoint = ccp(0.0f, 0.0f);
	miMenuVersionLabel.tag = kMenuTilehallsLabel;
	[miMenuVersionLabel setIsEnabled: NO];*/
	//miMenuVersionLabel = 255;
	
	if (game.iPad) {
		offset = ccp(96, -96);
	}
	
	MenuItemSprite *mi31 = [MenuItemSprite itemWithSpriteFrameName: @"mmBack.png"
															target: self
														selector: @selector(menuBack:)];
	//mi31.tag = kMenuButtonBack;
	mi31.position = [self convertPoint: ccp(1200, -100) offset: offset];
	mi31.anchorPoint = ccp(1.0f, 0.5f);
	
	MenuItemSprite *mi32 = [MenuItemSprite itemWithSpriteFrameName: @"mmAuthors.png"
															target: nil
														  selector: nil];
	//[mi32 setIsEnabled: NO];
	[mi32 setSelectionColor: kColorWhite];
	mi32.opacity = 255;
	mi32.tag = kMenuTheMakers;
	mi32.position = [self convertPoint: ccp(730, -100) offset: offset];
	mi32.anchorPoint = ccp(0.0f, 0.5f);
	
	// TILEHALL & TABLE SELECT
	if (game.iPad) {
		offset = ccp(160, -64);
	}
	else if (game.iPhone5) {
		offset = ccp(220, 0);
	}
	
	iPadOffset = ccp(offset.x - 32, offset.y);
	iPhone5Offset = ccp(offset.x - 44, offset.y);
	
	MenuItemSprite *miMenuTilehallsLabel = [MenuItemSprite itemWithSpriteFrameName: @"mmLabelTilehalls.png"
																			target: nil
																		  selector: nil];
	miMenuTilehallsLabel.position = [self convertPoint: ccp(1210, 11) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuTilehallsLabel.anchorPoint = ccp(0.0f, 0.0f);
	miMenuTilehallsLabel.tag = kMenuTilehallsLabel;
	[miMenuTilehallsLabel setIsEnabled: NO];
	//miMenuTilehallsLabel.opacity = 255;
	
	if (game.iPad) {
		offset = ccp(160, -32);
	}
	
	MenuItemSprite *mi41 = [MenuItemSprite itemWithSpriteFrameName: @"mmTilehall_0.png"
															target: self
														  selector: @selector(menuTilehallSelect:)];
	[mi41 setSelectionColor: [game lightColorForTilehall: 0]];
	mi41.tag = kMenuButtonTilehall1;
	mi41.position = [self convertPoint: ccp(1260, 80) offset: offset];
	
	MenuItemSprite *mi42 = [MenuItemSprite itemWithSpriteFrameName: @"mmTilehall_0.png"
															target: self
														  selector: @selector(menuTilehallSelect:)];
	[mi42 setSelectionColor: [game lightColorForTilehall: 1]];
	mi42.tag = kMenuButtonTilehall2;
	mi42.position = [self convertPoint: ccp(1320, 80) offset: offset];
	
	MenuItemSprite *mi43 = [MenuItemSprite itemWithSpriteFrameName: @"mmTilehall_0.png"
															target: self
														  selector: @selector(menuTilehallSelect:)];
	[mi43 setSelectionColor: [game lightColorForTilehall: 2]];
	mi43.tag = kMenuButtonTilehall3;
	mi43.position = [self convertPoint: ccp(1380, 80) offset: offset];
	
	MenuItemSprite *mi44 = [MenuItemSprite itemWithSpriteFrameName: @"mmTilehall_0.png"
															target: self
														  selector: @selector(menuTilehallSelect:)];
	[mi44 setSelectionColor: [game lightColorForTilehall: 3]];
	mi44.tag = kMenuButtonTilehall4;
	mi44.position = [self convertPoint: ccp(1440, 80) offset: offset];
	
	MenuItemSprite *mi45 = [MenuItemSprite itemWithSpriteFrameName: @"mmTilehall_0.png"
															target: self
														  selector: @selector(menuTilehallSelect:)];
	[mi45 setSelectionColor: [game lightColorForTilehall: 3]];
	mi45.tag = kMenuButtonTilehall5;
	mi45.position = [self convertPoint: ccp(1500, 80) offset: offset];
	
	MenuItemSprite *mi4cs = [MenuItemSprite itemWithSpriteFrameName: @"mmTilehall_cs.png"
															target: nil
														  selector: nil];
	[mi4cs setSelectionColor: [game lightColorForTilehall: 4]];
	[mi4cs setIsEnabled: NO];
	mi4cs.tag = kMenuButtonTilehallComingSoon;
	mi4cs.position = [self convertPoint: ccp(1560, 83) offset: offset];
	
	MenuItemSprite *mi4b = [MenuItemSprite itemWithSpriteFrameName: @"mmTilehallBackUp.png"
															target: self
														  selector: @selector(menuBack:)];
	[mi4b setSelectionColor: kColorGray];
	//mi4b.tag = kMenuButtonBack;
	mi4b.position = [self convertPoint: ccp(1620, 80) offset: offset];
	
	if (game.iPad) {
		offset = ccp(160, -64);
	}
	iPadOffset = ccp(offset.x + 32, offset.y);
	iPhone5Offset = ccp(offset.x + 44, offset.y);
	
	MenuItemSprite *miMenuTablesLabel = [MenuItemSprite itemWithSpriteFrameName: @"mmLabelTables.png"
																		 target: nil
																	   selector: nil];
	miMenuTablesLabel.position = [self convertPoint: ccp(1670, -11) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuTablesLabel.anchorPoint = ccp(1.0f, 1.0f);
	miMenuTablesLabel.tag = kMenuTablesLabel;
	[miMenuTablesLabel setIsEnabled: NO];
	//miMenuTablesLabel.opacity = 255;
	
	if (game.iPad) {
		offset = ccp(160, -96);
	}
	
	MenuItemSprite *mi51 = [MenuItemSprite itemWithSpriteFrameName: @"mm1_0.png"
															target: self
														  selector: @selector(menuTableSelect:)];
	mi51.tag = kMenuButtonTable1;
	mi51.position = [self convertPoint: ccp(1320, -50) offset: offset];
	
	MenuItemSprite *mi52 = [MenuItemSprite itemWithSpriteFrameName: @"mm2_0.png"
															target: self
														  selector: @selector(menuTableSelect:)];
	mi52.tag = kMenuButtonTable2;
	mi52.position = [self convertPoint: ccp(1380, -50) offset: offset];
	
	MenuItemSprite *mi53 = [MenuItemSprite itemWithSpriteFrameName: @"mm3_0.png"
															target: self
														  selector: @selector(menuTableSelect:)];
	mi53.tag = kMenuButtonTable3;
	mi53.position = [self convertPoint: ccp(1440, -50) offset: offset];
	
	MenuItemSprite *mi54 = [MenuItemSprite itemWithSpriteFrameName: @"mm4_0.png"
															target: self
														  selector: @selector(menuTableSelect:)];
	mi54.tag = kMenuButtonTable4;
	mi54.position = [self convertPoint: ccp(1500, -50) offset: offset];
	
	MenuItemSprite *mi55 = [MenuItemSprite itemWithSpriteFrameName: @"mm5_0.png"
															target: self
														  selector: @selector(menuTableSelect:)];
	mi55.tag = kMenuButtonTable5;
	mi55.position = [self convertPoint: ccp(1560, -50) offset: offset];
		
	MenuItemSprite *mi56 = [MenuItemSprite itemWithSpriteFrameName: @"mm6_0.png"
															target: self
														  selector: @selector(menuTableSelect:)];
	mi56.tag = kMenuButtonTable6;
	mi56.position = [self convertPoint: ccp(1320, -120) offset: offset];
	
	MenuItemSprite *mi57 = [MenuItemSprite itemWithSpriteFrameName: @"mm7_0.png"
															target: self
														  selector: @selector(menuTableSelect:)];
	mi57.tag = kMenuButtonTable7;
	mi57.position = [self convertPoint: ccp(1380, -120) offset: offset];
	
	MenuItemSprite *mi58 = [MenuItemSprite itemWithSpriteFrameName: @"mm8_0.png"
															target: self
														  selector: @selector(menuTableSelect:)];
	mi58.tag = kMenuButtonTable8;
	mi58.position = [self convertPoint: ccp(1440, -120) offset: offset];
	
	MenuItemSprite *mi59 = [MenuItemSprite itemWithSpriteFrameName: @"mm9_0.png"
															target: self
														  selector: @selector(menuTableSelect:)];
	mi59.tag = kMenuButtonTable9;
	mi59.position = [self convertPoint: ccp(1500, -120) offset: offset];
	
	MenuItemSprite *mi510 = [MenuItemSprite itemWithSpriteFrameName: @"mm10_0.png"
															 target: self
														   selector: @selector(menuTableSelect:)];
	mi510.tag = kMenuButtonTable10;
	mi510.position = [self convertPoint: ccp(1560, -120) offset: offset];
	
	// PROMO
	if (game.iPad) {
		offset = ccp(224, -64);
	}
	else if (game.iPhone5) {
		offset = ccp(308, 0);
	}
	
	/*MenuItemSprite *miMenuPromo = [MenuItemSprite itemWithSpriteFrameName: @"mmPromo_0.png"
																	target: nil
																  selector: nil];*/
	CCMenuItemSprite *miMenuPromo = [CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: (game.iPad ? @"Promo_1-hd.png" : @"Promo_1.png")] selectedSprite: nil];
	miMenuPromo.position = [self convertPoint: ccp(1920, 0) offset: offset];
	miMenuPromo.tag = kMenuButtonPromo;
	//[miMenuPromo setSelectionColor: kColorWhite];
	[miMenuPromo setIsEnabled: NO];
	//miMenuPromo.opacity = 255;
	
	/*MenuItemSprite *miPromoPager = [MenuItemSprite itemWithSpriteFrameName: @"mmPromoPage_0.png"
																	target: nil
																  selector: nil];
	miPromoPager.position = [self convertPoint: ccp(1920, -136) offset: offset];
	miPromoPager.tag = kMenuButtonPromoPager;
	[miPromoPager setSelectionColor: kColorWhite];
	miPromoPager.opacity = 255;
	
	MenuItemSprite *miReturn = [MenuItemSprite itemWithSpriteFrameName: @"mmReturn.png"
																target: self
															  selector: @selector(menuReturn:)];
	miReturn.position = [self convertPoint: ccp(2108, 126) offset: offset];
	[miReturn setSelectionColor: kColorSilver];
	
	MenuItemSprite *miPrevious = [MenuItemSprite itemWithSpriteFrameName: @"mmPrevious.png"
																target: self
															  selector: @selector(menuPrevious:)];
	miPrevious.position = [self convertPoint: ccp(1732, -125) offset: offset];
	[miPrevious setSelectionColor: kColorSilver];
	
	MenuItemSprite *miNext = [MenuItemSprite itemWithSpriteFrameName: @"mmNext.png"
																target: self
															  selector: @selector(menuNext:)];
	miNext.position = [self convertPoint: ccp(2108, -125) offset: offset];
	[miNext setSelectionColor: kColorSilver];
	
	MenuItemSprite *miAppStore = [MenuItemSprite itemWithSpriteFrameName: @"mmAppStore.png"
																  target: self
																selector: @selector(menuAppStore:)];
	miAppStore.position = [self convertPoint: ccp(1920, -90) offset: offset];
	miAppStore.tag = kMenuButtonAppStore;
	[miAppStore setSelectionColor: kColorSilver];
	
	MenuItemSprite *miMail = [MenuItemSprite itemWithSpriteFrameName: @"mmPromoMail.png"
																  target: self
																selector: @selector(menuMail:)];
	miMail.position = [self convertPoint: ccp(1820, -56) offset: offset];
	miMail.tag = kMenuButtonMail;
	[miMail setSelectionColor: ccc3(176, 53, 10)];
	miMail.visible = NO;
	
	MenuItemSprite *miTwitter = [MenuItemSprite itemWithSpriteFrameName: @"mmPromoTwitter.png"
															  target: self
															selector: @selector(menuTwitter:)];
	miTwitter.position = [self convertPoint: ccp(1920, -56) offset: offset];
	miTwitter.tag = kMenuButtonTwitter;
	[miTwitter setSelectionColor: ccc3(0, 172, 237)];
	miTwitter.visible = NO;
	
	MenuItemSprite *miFacebook = [MenuItemSprite itemWithSpriteFrameName: @"mmPromoFacebook.png"
															  target: self
															selector: @selector(menuFacebook:)];
	miFacebook.position = [self convertPoint: ccp(2020, -56) offset: offset];
	miFacebook.tag = kMenuButtonFacebook;
	[miFacebook setSelectionColor: ccc3(61, 98, 179)];
	miFacebook.visible = NO;*/
	
	// add Plus
	if (game.iPad) {
		offset = ccp(32, 0);
	}
	else if (game.iPhone5) {
		offset = ccp(44, 0);
	}
	
	iPadOffset = ccp(offset.x + 32, offset.y);
	iPhone5Offset = ccp(offset.x + 44, offset.y);
	
	/*MenuItemSprite *miMenuPlus = [MenuItemSprite itemWithSpriteFrameName: @"mmPlus.png"
																  target: self
																selector: @selector(menuPlus:)];
	miMenuPlus.position = [self convertPoint: ccp(720, 160) iPadOffset: iPadOffset iPhone5Offset: iPhone5Offset];
	miMenuPlus.anchorPoint = ccp(1.0f, 1.0f);
	miMenuPlus.tag = kMenuPlus;*/
	
	_menu = [[CCMenu menuWithItems:
			  miMenuOptionsLabel, miMenuCloudLabel, mi10, mi11, mi12, mi13, mi14, mi15, mi16, mi17, mi18, mi19,
			  miMenuMainLabel, mi21, mi22, mi23, mi24, mi25,
			  miMenuCreditsLabel, /*miMenuVersionLabel,*/ mi31, mi32,
			  miMenuTilehallsLabel, mi41, mi42, mi43, mi44, mi45, mi4cs, mi4b,
			  miMenuTablesLabel, mi51, mi52, mi53, mi54, mi55, mi56, mi57, mi58, mi59, mi510,
			  /*miMenuPromo, miPromoPager, miReturn, miPrevious, miNext,
			  miAppStore, miMail, miTwitter, miFacebook, miMenuPlus,*/
			  nil] retain];
	
	// add menu into scene
	[self addChild: _menu z: kMenu tag: kMenu];
}

#pragma mark -
#pragma mark Menu System

-(void) showMenu {

	CCNode *plus = [_menu getChildByTag: kMenuPlus];
	if ([Game sharedGame].menu == kMenuMain) {
		plus.position = [self convertPoint: ccp(720 + 28, 160 + 28) iPadOffset: ccp(36, -28) iPhone5Offset: ccp(88, 0)];
		plus.visible = YES;
		[plus stopAllActions];
		[plus runAction: [CCMoveBy actionWithDuration: 0.5f position: ccp(-28, -28)]];
	}
	else {
		plus.visible = NO;
	}
	
	[super showMenu];
}

#pragma mark -
#pragma mark Main Menu

-(void) showMenuAndLogo {
	
	[self showMenu];
	
	CCSprite *tiliard = (CCSprite *) [self getChildByTag: kTiliard];
	tiliard.opacity = 0;
	tiliard.scale = 10.0f;
	tiliard.visible = YES;
	/*[tiliard runAction: [CCSequence actions:
	 //[CCDelayTime actionWithDuration: 0.8f],
	 [CCCallFunc actionWithTarget: self selector: @selector(playRankSound)],
	 [CCSpawn actions:
	 [CCFadeIn actionWithDuration: 0.3f],
	 [CCScaleTo actionWithDuration: 0.3f scale: 1.0f],
	 nil],
	 nil]];*/
	[tiliard runAction: [CCSpawn actions:
						 [CCFadeIn actionWithDuration: 0.3f],
						 [CCScaleTo actionWithDuration: 0.3f scale: 1.0f],
						 nil]];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundRank];
	}
}

-(void) updateTables: (ccColor3B) selectionColor {
	Game *game = [Game sharedGame];
	
	NSInteger max = kMenuButtonTable1 + kTablesPerTilehall;
	for (NSInteger i = kMenuButtonTable1; i < max; i++) {
		MenuItemSprite *item = (MenuItemSprite *) [_menu getChildByTag: i];
		[item setColor: kColorWhite];
		
		NSInteger index = item.tag - kMenuButtonTable1;
		Table *table = [game tableAtIndex: index];
		if ([table isLocked] || [table isSkipped]) {

			NSString *frameName = [NSString stringWithFormat: @"mm%d_0.png", index + 1];
			[item setNormalImage: [CCSprite spriteWithSpriteFrameName: frameName]];
			if ([table isLocked]) {
				[item setIsEnabled: NO];
			}
			else {
				[item setIsEnabled: YES];
			}
		}
		else {
			
			NSString *frameName = nil;
			if (([table bestScore] > 0) && ([table bestScore] < [table score])) {
				frameName = [NSString stringWithFormat: @"mm%d_3tr.png", index + 1];
			}
			else if (([table bestScore] > 0) && ([table bestScore] == [table score])) {
				frameName = [NSString stringWithFormat: @"mm%d_3bs.png", index + 1];
			}
			else {
				frameName = [NSString stringWithFormat: @"mm%d_%d.png", index + 1, [table bestRank]];
			}
			[item setNormalImage: [CCSprite spriteWithSpriteFrameName: frameName]];
			[item setIsEnabled: YES];
		}
		
		[item setSelectionColor: selectionColor];
	}
}

-(void) updateTilehalls {
	Game *game = [Game sharedGame];
	
	NSInteger max = kMenuButtonTilehall1 + kTilehallComingSoon;
	for (NSInteger i = kMenuButtonTilehall1; i < max; i++) {
		MenuItemSprite *item = (MenuItemSprite *) [_menu getChildByTag: i];
		[item setColor: kColorWhite];
		
		NSInteger index = item.tag - kMenuButtonTilehall1;
		Tilehall tilehall = [game tilehallAtIndex: index];
		if (tilehall.unlocked) {
			NSString *frameName = [NSString stringWithFormat: @"mmTilehall_%d.png", index + 1];
			[item setNormalImage: [CCSprite spriteWithSpriteFrameName: frameName]];
			[item setIsEnabled: YES];
		}
		else {
			[item setNormalImage: [CCSprite spriteWithSpriteFrameName: @"mmTilehall_0.png"]];
			[item setIsEnabled: NO];
		}
	}
	
	game.menu = kMenuTilehallTableSelect;
	[game loadTablesForTilehall];
	
	MenuItemSprite *item = (MenuItemSprite *) [_menu getChildByTag: (kMenuButtonTilehall1 + game.tilehallIndex)];
	[item setColor: game.tilehall.color.lightColor];
	
	[self updateTables: game.tilehall.color.lightColor];
}

-(void) menuPlay: (id) sender {
	
	Game *game = [Game sharedGame];
	
	[self updateTilehalls];
	
	game.menu = kMenuTilehallTableSelect;
	[self hideMenu];
	
	[self getChildByTag: kTiliard].visible = NO;
	//[_spriteBatch getChildByTag: kTableShadow].visible = NO;
	
	if (sender == nil) {
		
		[game randomizeColor];
		[self showMenu];
	}
	else if ([game canPlayWithoutDelay]) {
		
		NSInteger color = [game color];
		[game setTilehall: kTilehallTraining];
		[game loadTablesForTilehall];
		[game setColorForTable: color];
		
		[self closeTableHalfAndLoad: @"gameplay"];
	}
	else {
		
		[game setTilehall: game.tilehallIndex];
		[self closeTableHalf: @selector(showMenu)];
	}

	//if ((sender != nil) && game.sound) {
	//	[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	//}
}

-(void) menuEditor: (id) sender {
	
	UIAlertView *editorAlert = [[UIAlertView alloc] initWithTitle: [Localization getStringForKey: @"AlertTableEditor"]
														  message: [Localization getStringForKey: @"AlertTableEditorMessage"]
														 delegate: self
												cancelButtonTitle: [Localization getStringForKey: @"AlertButtonLater"]
												otherButtonTitles: [Localization getStringForKey: @"AlertButtonRate"], nil];
	editorAlert.tag = kAlertEditor;
	[editorAlert show];
	[editorAlert release];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) editor {
	
	//[[CCDirector sharedDirector] replaceScene: [Editor scene]];
}

-(void) menuOptions: (id) sender {
	
	[Game sharedGame].menu = kMenuOptions;
	[self slideMenu: 1];
}

-(void) menuCredits: (id) sender {
	
	[Game sharedGame].menu = kMenuCredits;
	[self slideMenu: -1];
}

-(void) showGameCenterAchievements {
	
	[[DDGameKitHelper sharedGameKitHelper] showAchievements];
}

-(void) showGameCenterLeaderboards {
	
	[[DDGameKitHelper sharedGameKitHelper] showLeaderboard];
}

-(void) menuGameCenter: (id) sender {
	
	/*UIAlertView *gameCenterAlert = [[UIAlertView alloc] initWithTitle: @"Game Center"
															  message: nil
															 delegate: self
													cancelButtonTitle: [Localization getStringForKey: @"AlertButtonBack"]
													otherButtonTitles: [Localization getStringForKey: @"AlertButtonAchievements"], [Localization getStringForKey: @"AlertButtonLeaderboards"], nil];
	gameCenterAlert.tag = kAlertGameCenter;
	[gameCenterAlert show];
	[gameCenterAlert release];*/
	
	[self showGameCenterAchievements];
	//[self showGameCenterLeaderboards];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuPlus: (id) sender {
	
	Game *game = [Game sharedGame];
	[self adaptPromoSprites: game.promo];
	[self adaptPromoButtons: game.promo];
	
	game.menu = kMenuPromo;
	[self showMenu];
	
	[self getChildByTag: kTiliard].visible = NO;
	_glowType = kGlowDisabled;
	[self hideGlow];
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuReturn: (id) sender {
	
	Game *game = [Game sharedGame];
	[game nextPromo];
	
	game.menu = kMenuMain;
	[self showMenu];
	
	[self getChildByTag: kTiliard].visible = YES;
	_glowType = kGlowMenu;
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) adaptPromoSprites: (NSInteger) promo {

	Game *game = [Game sharedGame];
	
	NSString *frameName = [NSString stringWithFormat: (game.iPad ? @"Promo_%d-hd.png" : @"Promo_%d.png"), promo];
	if (promo == kPromoInfo) {
		frameName = [NSString stringWithFormat: (game.iPad ? @"Promo_0_%@-hd.png" : @"Promo_0_%@.png"), game.language];
	}
	CCMenuItemSprite *ccmi = (CCMenuItemSprite *) [_menu getChildByTag: kMenuButtonPromo];
	ccmi.normalImage = [CCSprite spriteWithFile: frameName];
	
	NSInteger page = (promo == kPromoInfo) ? (kPromoMAX - 1) : (promo - 1);
	frameName = [NSString stringWithFormat: @"mmPromoPage_%d.png", page];
	MenuItemSprite *mi = (MenuItemSprite *) [_menu getChildByTag: kMenuButtonPromoPager];
	CCSprite *sprite = (CCSprite* ) mi.normalImage;
	[sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
}

-(void) adaptPromoButtons: (NSInteger) promo {
	
	if (promo == kPromoInfo) {
		[_menu getChildByTag: kMenuButtonAppStore].visible = NO;
		[_menu getChildByTag: kMenuButtonMail].visible = YES;
		[_menu getChildByTag: kMenuButtonTwitter].visible = YES;
		[_menu getChildByTag: kMenuButtonFacebook].visible = YES;
	}
	else {
		[_menu getChildByTag: kMenuButtonAppStore].visible = YES;
		[_menu getChildByTag: kMenuButtonMail].visible = NO;
		[_menu getChildByTag: kMenuButtonTwitter].visible = NO;
		[_menu getChildByTag: kMenuButtonFacebook].visible = NO;
		
		/*MenuItemSprite *mi = (MenuItemSprite *) [_menu getChildByTag: kMenuButtonAppStore];
		
		NSString *frameName = @"mmAppStore.png";
		if (promo == kPromoWhereToJump) {
			frameName = @"mmAppStoreSoon.png";
		}
		CCSprite *sprite = (CCSprite* ) mi.normalImage;
		[sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
		
		//[mi setIsEnabled: (promo != kPromoWhereToJump)];
		mi.opacity = 255;*/
	}
}

-(void) menuPrevious: (id) sender {
	
	Game *game = [Game sharedGame];
	[self adaptPromoSprites: [game previousPromo]];
	[self adaptPromoButtons: game.promo];
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuNext: (id) sender {
	
	Game *game = [Game sharedGame];
	[self adaptPromoSprites: [game nextPromo]];
	[self adaptPromoButtons: game.promo];
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuAppStore: (id) sender {

	Game *game = [Game sharedGame];
	
	switch (game.promo) {
		case kPromoWhereToJump:
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://itunes.apple.com/app/id695246270?mt=8"]];
			break;
			
		case kPromoLums:
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://itunes.apple.com/app/id654746244?mt=8"]];
			break;
			
		case kPromoWoozzle:
			if (game.iPad) {
				[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://itunes.apple.com/app/id416789970?mt=8"]];
			}
			else {
				[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://itunes.apple.com/app/id392895918?mt=8"]];
			}
			break;
			
		case kPromoPunchAHole:
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://itunes.apple.com/app/id456072649?mt=8"]];
			break;
	}
}

-(void) menuMail: (id) sender {
	
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"mailto:contact@2keyplayers.com"]];
}

-(void) menuTwitter: (id) sender {
	
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://twitter.com/2keyplayers"]];
}

-(void) menuFacebook: (id) sender {
	
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://www.facebook.com/2keyplayers"]];
}

#pragma mark -
#pragma mark Tilehall & Table Select Menu

-(void) menuTilehallSelect: (id) sender {
	
	Game *game = [Game sharedGame];
	
	NSInteger max = kMenuButtonTilehall1 + kTilehallComingSoon;
	for (NSInteger i = kMenuButtonTilehall1; i < max; i++) {
		MenuItemSprite *item = (MenuItemSprite *) [_menu getChildByTag: i];
		[item setColor: kColorWhite];
		//[item stopAllActions];
	}
	
	MenuItemSprite *item = (MenuItemSprite *) sender;
	
	game.menu = kMenuTilehallTableSelect;
	[game setTilehall: (item.tag - kMenuButtonTilehall1)];
	[game loadTablesForTilehall];
	
	[item setColor: game.lightColor];
	/*[item runAction: [CCRepeatForever actionWithAction:
					  [CCSequence actions:
					   [CCScaleTo actionWithDuration: 0.4f scale: 1.1f],
					   [CCScaleTo actionWithDuration: 0.4f scale: 1.0f],
					   nil]]];*/
	
	[self updateTables: game.lightColor];
	
	[self setTableColor];

	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuTableSelect: (id) sender {
	
	CCMenuItem *item = (CCMenuItem *) sender;
	
	Game *game = [Game sharedGame];
	[game setTable: (item.tag - kMenuButtonTable1)];
	
	[self hideMenu];
	
	[self loading: @"gameplay"];
}

-(void) gameplay {
	
	[[CCDirector sharedDirector] replaceScene: [Gameplay scene]];
}

-(void) menuSecret: (id) sender {
	
	// used for unlocking special content :)
}

#pragma mark -
#pragma mark Settings Menu

-(void) menuMore: (id) sender {
	
	Game *game = [Game sharedGame];
	_more = !_more;
	
	[_menu getChildByTag: kMenuButtonMusic].visible = !_more;
	[_menu getChildByTag: kMenuButtonSound].visible = !_more;
	[_menu getChildByTag: kMenuButtonLanguage].visible = !_more;
	[_menu getChildByTag: kMenuButtonResetProgress].visible = !_more;
	[_menu getChildByTag: kMenuButtonClothColor].visible = _more;
	[_menu getChildByTag: kMenuButtonTileSet].visible = _more;
	[_menu getChildByTag: kMenuButtonShare].visible = _more;
	[_menu getChildByTag: kMenuButtonGiftRate].visible = _more;
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuMusic: (id) sender {
	
	Game *game = [Game sharedGame];
	[game switchSettings: kSettingsMusic];
	
	if (game.music) {
		[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
	}
	else {
		[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
	}

	SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
	if (sae != nil) {
		sae.effectsVolume = (game.music ? 0.1f : 0.3f);
	}
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuSound: (id) sender {
	
	Game *game = [Game sharedGame];
	[game switchSettings: kSettingsSound];

	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

/*-(void) menuAudio: (id) sender {
	
	Game *game = [Game sharedGame];
	
	UILabel *musicLabel = [[UILabel alloc] initWithFrame: CGRectMake(60,50,260,25)];
	musicLabel.font = [UIFont systemFontOfSize: 16];
	musicLabel.textColor = [UIColor whiteColor];
	musicLabel.backgroundColor = [UIColor clearColor];
	musicLabel.shadowColor = [UIColor blackColor];
	musicLabel.shadowOffset = CGSizeMake(0,-1);
	musicLabel.lineBreakMode = UILineBreakModeWordWrap;
	musicLabel.numberOfLines = 1;
	musicLabel.textAlignment = UITextAlignmentLeft;
	musicLabel.text = [Localization getStringForKey: @"AlertMusic"];
	
	UILabel *soundLabel = [[UILabel alloc] initWithFrame: CGRectMake(60,95,260,25)];
	soundLabel.font = [UIFont systemFontOfSize: 16];
	soundLabel.textColor = [UIColor whiteColor];
	soundLabel.backgroundColor = [UIColor clearColor];
	soundLabel.shadowColor = [UIColor blackColor];
	soundLabel.shadowOffset = CGSizeMake(0,-1);
	soundLabel.lineBreakMode = UILineBreakModeWordWrap;
	soundLabel.numberOfLines = 1;
	soundLabel.textAlignment = UITextAlignmentLeft;
	soundLabel.text = [Localization getStringForKey: @"AlertSound"];
	
	UISwitch *music = [[UISwitch alloc] initWithFrame: CGRectMake(140, 50, 0, 0)];
	music.on = game.music;
	if ([music respondsToSelector: @selector(onTintColor:)]) {
		music.onTintColor = [UIColor whiteColor];
	}
	[music addTarget:self action:@selector(menuMusic:) forControlEvents:UIControlEventValueChanged];
	
	UISwitch *sound = [[UISwitch alloc] initWithFrame: CGRectMake(140, 95, 0, 0)];
	sound.on = game.sound;
	if ([sound respondsToSelector: @selector(onTintColor:)]) {
		sound.onTintColor = [UIColor whiteColor];
	}
	[sound addTarget:self action:@selector(menuSound:) forControlEvents:UIControlEventValueChanged];
	
	UIAlertView *audioAlert = [[UIAlertView alloc] initWithTitle: @"Audio"
														 message: @"\n\n\n\n"
														delegate: nil
											   cancelButtonTitle: [Localization getStringForKey: @"AlertButtonBack"]
											   otherButtonTitles: nil];
	audioAlert.tag = kAlertLanguageChange;
	[audioAlert addSubview: musicLabel];
	[audioAlert addSubview: soundLabel];
	[audioAlert addSubview: music];
	[audioAlert addSubview: sound];
	[audioAlert show];
	
	[audioAlert release];
	[musicLabel release];
	[soundLabel release];
	[music release];
	[sound release];
}*/

-(void) menuLanguage: (id) sender {
	
	if (!_languageChanged) {
		
		UIAlertView *languageAlert = [[UIAlertView alloc] initWithTitle: [Localization getStringForKey: @"AlertLanguageChange"]
																message: [Localization getStringForKey: @"AlertLanguageChangeMessage"]
															   delegate: nil
													  cancelButtonTitle: [Localization getStringForKey: @"AlertButtonOk"]
													  otherButtonTitles: nil];
		languageAlert.tag = kAlertLanguageChange;
		[languageAlert show];
		[languageAlert release];
	}
	
	Game *game = [Game sharedGame];
	[game switchSettings: kSettingsLanguage];
	[Localization setLanguage: game.language];
	
	_languageChanged = YES;

	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuResetProgress: (id) sender {
	
	UIAlertView *resetProgressAlert = [[UIAlertView alloc] initWithTitle: [Localization getStringForKey: @"AlertReset"]
																 message: nil
																delegate: self
													   cancelButtonTitle: [Localization getStringForKey: @"AlertButtonBack"]
													   otherButtonTitles: [Localization getStringForKey: @"AlertButtonProgress"], [Localization getStringForKey: @"AlertButtonHints"], nil];
	/*UIAlertView *resetProgressAlert = [[UIAlertView alloc] initWithTitle: nil //[Localization getStringForKey: @"AlertResetProgress"]
																 message: nil
																delegate: self
													   cancelButtonTitle: [Localization getStringForKey: @"AlertButtonBack"]
													   otherButtonTitles: [Localization getStringForKey: @"AlertButtonProgress"], [Localization getStringForKey: @"AlertButtonHints"], [Localization getStringForKey: @"AlertButtonAchievements"], nil];*/
	 resetProgressAlert.tag = kAlertResetProgress;
	 [resetProgressAlert show];
	 [resetProgressAlert release];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuChangeColor: (id) sender {
	
	Game *game = [Game sharedGame];
	[game switchSettings: kSettingsClothColor];
	
	//[game randomizeColor];
	//[game resetTableColor];
	[self changeColor];
	
	NSString *frameName = [NSString stringWithFormat: @"mmTableColor_%d.png", game.clothColor];
	MenuItemSprite *mi =(MenuItemSprite *) [_menu getChildByTag: kMenuButtonClothColor];
	CCSprite *sprite = (CCSprite* ) mi.normalImage;
	[sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuChangeTileSet: (id) sender {
	
	Game *game = [Game sharedGame];
	[game switchSettings: kSettingsTileSet];
	
	NSString *frameName = [NSString stringWithFormat: @"mmTileSet_%d.png", game.tileSet];
	MenuItemSprite *mi =(MenuItemSprite *) [_menu getChildByTag: kMenuButtonTileSet];
	CCSprite *sprite = (CCSprite* ) mi.normalImage;
	[sprite setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: frameName]];

	if (game.tileSet > 0) {
		CCSprite *tile = (CCSprite *) [_spriteBatch getChildByTag: kMenuTile];
		NSString *tileFrameName = [NSString stringWithFormat: @"%d%c.png", _tileNumber, ('A' + game.tileSet - 1)];
		[tile setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: tileFrameName]];
	}
	else if (_tileSetAlert && ![game tilehallAtIndex: (kTilehallComingSoon - 1)].unlocked) {
		
		_tileSetAlert = NO;
		UIAlertView *tileSetAlert = [[UIAlertView alloc] initWithTitle: [Localization getStringForKey: @"AlertTileSet"]
															   message: [Localization getStringForKey: @"AlertTileSetMessage"]
															  delegate: self
													 cancelButtonTitle: [Localization getStringForKey: @"AlertButtonOk"]
													 otherButtonTitles: nil];
		tileSetAlert.tag = kAlertTileSet;
		[tileSetAlert show];
		[tileSetAlert release];
		
	}
	
	if (game.sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	}
}

-(void) menuShare: (id) sender {
	
	if (NSClassFromString(@"UIActivityViewController") != nil) {
		
		NSString *text = [Localization getStringForKey: @"TellAFriend"];
		NSArray *activityItems = @[text];
		NSArray * excludeActivities = @[UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
			UIActivityTypeMessage];

		UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems: activityItems applicationActivities: nil];
		activityViewController.excludedActivityTypes = excludeActivities;
		
		//UINavigationController *navigationController = [UIApplication sharedApplication].keyWindow.rootViewController.navigationController;
		//UINavigationController *navigationController = [[CCDirector sharedDirector] navigationController];
		//UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: [Game sharedGame].viewController];
		//UIViewController *viewController = [navigationController.viewControllers lastObject];
		UIViewController *viewController = [Game sharedGame].viewController; //[[UIViewController alloc] init];
		
		//[[[CCDirector sharedDirector] openGLView] addSubview: viewController.view];
		[viewController presentViewController: activityViewController animated: YES completion: nil];
		/*[viewController presentModalViewController: activityViewController animated: YES];
		[activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
				
			if (![[viewController modalViewController] isBeingDismissed]) {
				[viewController dismissModalViewControllerAnimated: NO];
			}
			if ([activityType isEqualToString: UIActivityTypeMail] || [activityType isEqualToString: UIActivityTypeMessage]) {
				[viewController.view.superview removeFromSuperview];
				[viewController.view removeFromSuperview];
			}
			else if (activityType != nil) {
				[viewController.view removeFromSuperview];
			}
			
			[viewController release];
		}];*/
	}
}

-(void) productViewControllerDidFinish: (SKStoreProductViewController *) storeProductViewController {

	UIViewController *viewController = [Game sharedGame].viewController;
    [viewController dismissViewControllerAnimated: YES completion: nil];
}

-(void) rate {

	/*NSString* standardUrl = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8", kAppID];
	NSString* iOS7Url = [NSString stringWithFormat: @"itms-apps://itunes.apple.com/app/id%@?at=10l6dK", kAppID];
	
	NSString* url = ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f) ? iOS7Url : standardUrl;
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];*/
	
	if (NSClassFromString(@"SKStoreProductViewController") != nil) {
		
		UIViewController *viewController = [Game sharedGame].viewController;
		
		SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
		[storeProductViewController setDelegate: self];
		[storeProductViewController loadProductWithParameters: @{SKStoreProductParameterITunesItemIdentifier : kAppID} completionBlock:^(BOOL result, NSError *error) {
			if (error) {
				NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
			} else {
				[viewController presentViewController: storeProductViewController animated: YES completion: nil];
			}
		}];
	}
	else {
		
		NSString* url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8", kAppID];
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
	}
}

-(void) menuRate: (id) sender {

	[self rate];
}

/*-(void) gift {
	
	//NSString* url = [NSString stringWithFormat: @"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=%@&productType=C&pricingParameter=STDQ", kAppID];
	NSString* url = [NSString stringWithFormat: @"itms-appss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=%@&productType=C&pricingParameter=STDQ&mt=8&ign-mscache=1", kAppID];
	
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url ]];
}

-(void) menuGift: (id) sender {
	
	[self gift];
}*/

-(void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {

	Game *game = [Game sharedGame];
	if (buttonIndex == 0) {
		/*if (alertView.tag == kAlertResetProgress) {
			[game resetProgress];
		}*/
	}
	else if (buttonIndex == 1) {
		if (alertView.tag == kAlertGameCenter) {
			
			[self showGameCenterAchievements];
		}
		else if (alertView.tag == kAlertEditor) {
			
			[self rate];
		}
		else if (alertView.tag == kAlertResetProgress) {
			
			if (game.iCloud) {
				
				UIAlertView *resetProgressOnCloudAlert = [[UIAlertView alloc] initWithTitle: [Localization getStringForKey: @"AlertCloud"]
																					message: [Localization getStringForKey: @"AlertCloudMessage"]
																				   delegate: self
																		  cancelButtonTitle: [Localization getStringForKey: @"AlertButtonCancel"]
																		  otherButtonTitles: [Localization getStringForKey: @"AlertButtonReset"], nil];
				resetProgressOnCloudAlert.tag = kAlertResetProgressOnCloud;
				[resetProgressOnCloudAlert show];
				[resetProgressOnCloudAlert release];
			}
			else {
				
				[game resetProgress];
			}
		}
		else if (alertView.tag == kAlertResetProgressOnCloud) {
			
			[game resetProgress];
		}
	}
	else if (buttonIndex == 2) {
		if (alertView.tag == kAlertGameCenter) {
			
			//[self showGameCenterLeaderboards];
		}
		else if (alertView.tag == kAlertResetProgress) {
			
			[game resetHints];
		}
	}
	else if (buttonIndex == 3) {
		if (alertView.tag == kAlertResetProgress) {
			
			[[DDGameKitHelper sharedGameKitHelper] resetAchievements];
		}
	}
}

#pragma mark -
#pragma mark Back

-(void) menuBack: (id) sender {
	
	[self back];

	//if ([Game sharedGame].sound) {
	//	[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuTap];
	//}
}

#pragma mark -
#pragma mark Helper Methods

-(void) slideMenu: (NSInteger) direction {
	
	Game *game = [Game sharedGame];
	
	NSInteger width = (game.iPad ? 1024 : (game.iPhone5 ? 568 : 480));
	[_menu stopAllActions];
	[_menu runAction: [CCSequence actions:
					   [CCMoveTo actionWithDuration: kTransitionDuration position: ccp(_menu.position.x + (width * direction), _menu.position.y)],
					   [CCCallFunc actionWithTarget: self selector: @selector(changeColor)],
					   nil]];
	
	CCNode *plus = [_menu getChildByTag: kMenuPlus];
	plus.visible = NO;
	
	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundMenuSlide];
	}
}

-(void) changeColor {
	
	Game *game = [Game sharedGame];
	
	[game randomizeColor];
	[game resetTableColor];
		
	CCSprite *tiliard = (CCSprite *) [self getChildByTag: kTiliard];
	tiliard.color = game.lightColor;
		
	CCSprite *glow = (CCSprite *) [self getChildByTag: kGlow];
	glow.color = game.lightColor;
	
	CCNode *plus = [_menu getChildByTag: kMenuPlus];
	if (game.menu == kMenuMain) {
		plus.position = [self convertPoint: ccp(720 + 28, 160 + 28) iPadOffset: ccp(36, -28) iPhone5Offset: ccp(88, 0)];
		plus.visible = YES;
		[plus stopAllActions];
		[plus runAction: [CCMoveBy actionWithDuration: 0.5f position: ccp(-28, -28)]];
	}
	else {
		plus.visible = NO;
	}
}

-(void) localize {

	Game *game = [Game sharedGame];
	
	if ([game isLanguage: kLanguageEnglish]) {
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile: [self convertFileName: @"MainMenu_sk" extension: @"plist"]];
	}
	else {
		[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile: [self convertFileName: @"MainMenu_en" extension: @"plist"]];
	}
	NSString *mainMenu = [NSString stringWithFormat: @"MainMenu_%@", game.language];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: [self convertFileName: mainMenu extension: @"plist"]];
	
	CCArray *items = [_menu children];
	for (NSInteger i = 0; i < [items count]; i++) {
		id item = [items objectAtIndex: i];

		if ([item isKindOfClass: [MenuItemSprite class]]) {
			
			MenuItemSprite *mi = (MenuItemSprite *) item;
			[mi refreshSprite];
			
			/*if (mi.tag == kMenuButtonPromo) {
				mi.opacity = 255;
			}*/
		}
		else if ([item isKindOfClass: [CCMenuItemToggle class]]) {
			
			CCMenuItemToggle *mi = (CCMenuItemToggle *) item;
			NSArray *toggleItems = [mi subItems];
			NSInteger count = [toggleItems count];
			for (NSInteger j = 0; j < count; j++) {
				
				MenuItemSprite * tmi = (MenuItemSprite *) [toggleItems objectAtIndex: j];
				[tmi refreshSprite];
			}
		}
	}

	CCSprite *tiliard = (CCSprite *) [self getChildByTag: kTiliard];
	[tiliard setDisplayFrame: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: @"mmTiliard.png"]];
}

-(void) back {

	Game *game = [Game sharedGame];
	
	switch (game.menu) {
			
		case kMenuTilehallTableSelect:
			game.menu = kMenuMain;
			[self hideMenu];
			[self changeColor];
			[self openTableHalf: @selector(showMenuAndLogo)];
			break;
			
		case kMenuOptions:
			if (_languageChanged) {
			
				_languageChanged = NO;
				[self localize];
			}
			_tileSetAlert = YES;
			
			[game save: NO];
			
			if (!game.music) {
				[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
			}
			
			game.menu = kMenuMain;
			[self slideMenu: -1];
			break;
			
		case kMenuCredits:
			game.menu = kMenuMain;
			[self slideMenu: 1];
			break;
			
		default:
			// Main Menu has no back
			break;
			
	}
}

#pragma mark -
#pragma mark Touch Handling

/*-(void) registerWithTouchDispatcher {

	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority: kCCMenuTouchPriority swallowsTouches: YES];
}

-(BOOL) ccTouchBegan: (UITouch *) touch withEvent: (UIEvent *) event {

	//CGPoint location = [self convertTouchToNodeSpace: touch];
	//PositionOnTable positionOnTable = [self convertLocationToTablePosition: location];
	
	return NO;
}

-(void) ccTouchMoved: (UITouch *) touch withEvent: (UIEvent *) event {
}

-(void) ccTouchCancelled: (UITouch *) touch withEvent: (UIEvent *) event {
}

-(void) ccTouchEnded: (UITouch *) touch withEvent: (UIEvent *) event {
}*/

#pragma mark -
#pragma mark Update

-(void) update: (ccTime) dt {
	
	[super update: dt];
	
	if ([[Game sharedGame] shouldResetTableColor]) {
		[self setTableColor];
	}
}

#pragma mark -
#pragma mark Glow

-(CGPoint) getGlowPosition {
	
	CGPoint glowPosition;
	
	NSInteger i = arc4random() % 28;
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
			glowPosition.x = 124;
			glowPosition.y = 235;
			break;
		case 3:
			glowPosition.x = 135;
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
			glowPosition.x = 168;
			glowPosition.y = 235;
			break;
			
		case 8:
			glowPosition.x = 179;
			glowPosition.y = 268;
			break;
		case 9:
			glowPosition.x = 190;
			glowPosition.y = 268;
			break;
		case 10:
			glowPosition.x = 179;
			glowPosition.y = 235;
			break;
		case 11:
			glowPosition.x = 212;
			glowPosition.y = 235;
			break;
			
		case 12:
			glowPosition.x = 223;
			glowPosition.y = 268;
			break;
		case 13:
			glowPosition.x = 234;
			glowPosition.y = 268;
			break;
		case 14:
			glowPosition.x = 223;
			glowPosition.y = 235;
			break;
		case 15:
			glowPosition.x = 234;
			glowPosition.y = 235;
			break;
			
		case 16:
			glowPosition.x = 256;
			glowPosition.y = 268;
			break;
		case 17:
			glowPosition.x = 267;
			glowPosition.y = 268;
			break;
		case 18:
			glowPosition.x = 245;
			glowPosition.y = 235;
			break;
		case 19:
			glowPosition.x = 278;
			glowPosition.y = 235;
			break;
			
		case 20:
			glowPosition.x = 289;
			glowPosition.y = 268;
			break;
		case 21:
			glowPosition.x = 322;
			glowPosition.y = 268;
			break;
		case 22:
			glowPosition.x = 289;
			glowPosition.y = 235;
			break;
		case 23:
			glowPosition.x = 322;
			glowPosition.y = 235;
			break;
			
		case 24:
			glowPosition.x = 333;
			glowPosition.y = 268;
			break;
		case 25:
			glowPosition.x = 355;
			glowPosition.y = 268;
			break;
		case 26:
			glowPosition.x = 333;
			glowPosition.y = 235;
			break;
		case 27:
			glowPosition.x = 355;
			glowPosition.y = 235;
			break;
	}
	
	return glowPosition;
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[_showTile release];
	_showTile = nil;
	
	[super dealloc];
}

@end
