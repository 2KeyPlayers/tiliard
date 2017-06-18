//
//  GameScene.m
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/26/10.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#import "EndingScene.h"
#import	"MenuScene.h"
#import "Localization.h"
#import "MessageUI/MessageUI.h"
#import "DDGameKitHelper.h"


@implementation Ending

#pragma mark -
#pragma mark Scene Creator

+(id) scene {

	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// add layer as a child to scene
	[scene addChild: [Ending node]];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
		
		_ready = NO;
		_theEnd = NO;
		
		[self addBackground];
		
		Game *game = [Game sharedGame];
		SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
		if (sae != nil) {
			sae.effectsVolume = (game.music ? 0.1f : 0.3f);
			if (game.music) {
				[sae preloadBackgroundMusic: @"MusicMenu.mp3"];
				if (sae.willPlayBackgroundMusic) {
					sae.backgroundMusicVolume = 0.5f;
				}
			}
			if (game.sound) {
				[sae preloadEffect: kSoundEndOfGame];
			}
		}
		
		game.showEndOfGame = NO;

		/*if (game.music) {
			//[[CDAudioManager sharedManager] preloadBackgroundMusic: @"Music02.mp3" loop: YES];
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic: @"Music02.mp3"];
		}*/
		
		self.isTouchEnabled = YES;
		//self.isAccelerometerEnabled = YES;
		//[self scheduleUpdate];
		
		// open table
		[self openTable: @selector(showCongratulations)];
	}
	return self;
}

-(void) onEnter {
	
	[self hideActivityIndicator];
	[self scheduleUpdate];
	
	//[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"TilehallJunkie"
	//										 percentComplete: 100];

	if ([Game sharedGame].music) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic: @"MusicMenu.mp3"];
	}
	
	[super onEnter];
}

#pragma mark -
#pragma mark Content Builders

-(void) addBackground {
	
	Game *game = [Game sharedGame];
	
	// add background (containing light)
	CCSprite *bg = [CCSprite spriteWithFile: [self convertFileName: @"EndOfGame" extension: @"png"]];
	bg.position = [self convertPoint: ccp(240, 160)];
	[self addChild: bg z: 0 tag: kBackground];
	
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
	glow.opacity = 0;
	glow.scale = 0.0f;
	[self addChild: glow z: kGlow tag: kGlow];
	
	CGSize dimension = CGSizeMake(460, 40);
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
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
	
	//[self setTableColor];
}

#pragma mark -
#pragma mark Info Message

-(void) showInfoMessage: (NSString *) message position: (CGPoint) position duration: (float) duration {

	[self showInfoMessage: message position: position duration: duration selector: @selector(hideInfoMessage)];
}

-(void) showInfoMessage: (NSString *) message position: (CGPoint) position duration: (float) duration selector: (SEL) selector {

	_ready = NO;
	
	CCSprite *infoSprite = (CCSprite *) [_spriteBatch getChildByTag: kInfoSprite];
	infoSprite.position = [self convertPoint: position];
	infoSprite.scale = 0.0f;
	infoSprite.visible = YES;
	
	NSInteger correction = 4;
	if ([message rangeOfString: @"\n"].location == NSNotFound) {
		correction = 12;
	}
	/*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		correction = correction * 2;
	}*/
	
	CCLabelTTF *infoLabel = (CCLabelTTF *) [self getChildByTag: kInfoLabel];
	[infoLabel setString: message];
	[infoLabel.texture setAliasTexParameters];
	//infoLabel.opacity = 0;
	infoLabel.scale = 0.0f;
	infoLabel.position = [self convertPoint: ccp(position.x, position.y - correction)];
	infoLabel.visible = YES;
	
	if (duration > 0.0f) {
		
		[infoLabel runAction: [CCSequence actions:
							   [CCDelayTime actionWithDuration: 0.2f],
							   //[CCFadeIn actionWithDuration: kTransitionDuration],
							   [CCScaleTo actionWithDuration: 0.2f scale: 1.0f],
							   [CCDelayTime actionWithDuration: duration],
							   [CCCallFunc actionWithTarget: self selector: selector],
							   nil]];
		[infoSprite runAction: [CCSequence actions:
								[CCDelayTime actionWithDuration: 0.2f],
								//[CCFadeIn actionWithDuration: kTransitionDuration],
								[CCScaleTo actionWithDuration: 0.2f scale: 1.0f],
								//[CCScaleTo actionWithDuration: 0.2f scaleX: 40.0f scaleY: 1.0f],
								nil]];
	}
	else {
		
		[infoLabel runAction: [CCSequence actions:
							   [CCDelayTime actionWithDuration: 0.2f],
							   //[CCFadeIn actionWithDuration: kTransitionDuration],
							   [CCScaleTo actionWithDuration: 0.2f scale: 1.0f],
							   [CCCallFunc actionWithTarget: self selector: @selector(infoMessageReady)],
							   nil]];
		[infoSprite runAction: [CCSequence actions:
								[CCDelayTime actionWithDuration: 0.2f],
								//[CCFadeIn actionWithDuration: kTransitionDuration],
								[CCScaleTo actionWithDuration: 0.2f scale: 1.0f],
								//[CCScaleTo actionWithDuration: 0.2f scaleX: 40.0f scaleY: 1.0f],
								nil]];
	}	
}

-(void) infoMessageReady {
	
	_ready = YES;
	
	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundEndOfGame];
	}
}

-(void) hideInfoMessage {
	
	[_spriteBatch getChildByTag: kInfoSprite].visible = NO;
	[self getChildByTag: kInfoLabel].visible = NO;
}

-(void) showCongratulations {
	
	_glowType = kGlowMenu;
	
	Game *game = [Game sharedGame];
	NSInteger ranking = [game totalRanking];
	NSInteger maximum = 3 * kTablesPerTilehall * (kTilehallMAX - 2);
	
	NSString *congrats = [NSString stringWithFormat: [Localization getStringForKey: @"Congratulations"], ranking, maximum];
	
	[self showInfoMessage: congrats position: ccp(240, 80) duration: 0];
}

-(void) showThanksForPlaying {

	[self showInfoMessage: [Localization getStringForKey: @"ThanksForPlaying"] position: ccp(240, 80) duration: 0];
}

#pragma mark -
#pragma mark Touch Handling

-(void) registerWithTouchDispatcher {

	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority: kCCMenuTouchPriority swallowsTouches: YES];
}

-(BOOL) ccTouchBegan: (UITouch *) touch withEvent: (UIEvent *) event {

	if (!_ready) {
		return NO;
	}
	
	[self hideInfoMessage];
	
	if (!_theEnd) {
		_theEnd = YES;
		[self showThanksForPlaying];
		return NO;
	}
	
	Game *game = [Game sharedGame];
	game.menu = kMenuTilehallTableSelect;
	[game randomizeColor];
	
	[self closeTableAndLoad: @"mainMenu"];
	return NO;
}

-(void) ccTouchMoved: (UITouch *) touch withEvent: (UIEvent *) event {
}

-(void) ccTouchEnded: (UITouch *) touch withEvent: (UIEvent *) event {
}

-(void) ccTouchCancelled: (UITouch *) touch withEvent: (UIEvent *) event {
}

-(void) mainMenu {
	
	[[CCDirector sharedDirector] replaceScene: [MainMenu scene]];
}

#pragma mark -
#pragma mark Glow

-(CGPoint) getGlowPosition {

	CGPoint glowPosition;
	glowPosition.x = 255;
	glowPosition.y = [Game sharedGame].iPad ? 207 : 223;
	
	return glowPosition;
}

#pragma mark -
#pragma mark Update

-(void) update: (ccTime) dt {
	
	[super update: dt];
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[super dealloc];
}

@end
