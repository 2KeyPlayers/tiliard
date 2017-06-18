//
//  LoadingScene.m
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/01/11.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//

#import "LoadingScene.h"
#import "Game.h"
#import "MenuScene.h"
#import "DDGameKitHelper.h"


@implementation Loading

#pragma mark -
#pragma mark Scene Creator

+(id) scene {

	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	[scene addChild: [Loading node]];
	
	return scene;
}

-(id) init {

    if ((self = [super initWithColor: ccc4(0, 0, 0, 255)])) {
	
		_logo = 0;
		_updateTime = 0.0f;
		
		//CCTexture2DPixelFormat originalFormat = [CCTexture2D defaultAlphaPixelFormat];
		//[CCTexture2D setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_RGB565];

		// add logos
		NSString *logoPr = @"LogoPR.png";
		NSString *logo2kp = @"Logo2KP.png";
		NSString *table = @"Table.png";
		NSString *logoTiliard = [NSString stringWithFormat: @"LogoTiliard_%@.png", [Game sharedGame].language];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			logoPr = @"LogoPR-hd.png";
			logo2kp = @"Logo2KP-hd.png";
			table = @"Table-hd.png";
			logoTiliard = [NSString stringWithFormat: @"LogoTiliard_%@-hd.png", [Game sharedGame].language];
		}
		
		CCSprite* spritePr = [CCSprite spriteWithFile: logoPr];
		spritePr.position = [self convertPoint: ccp(240, 160)];
		spritePr.visible = NO;
		[self addChild: spritePr z: _logo tag: _logo];
		_logo++;
		
		CCSprite* sprite2kp = [CCSprite spriteWithFile: logo2kp];
		sprite2kp.position = [self convertPoint: ccp(240, 160)];
		[self addChild: sprite2kp z: _logo tag: _logo];
		_logo++;
		
		//[CCTexture2D setDefaultAlphaPixelFormat: originalFormat];
		
		// add upper and lower table parts
		CCSprite *upperTable = [CCSprite spriteWithFile: table];
		upperTable.flipX = YES;
		upperTable.flipY = YES;
		upperTable.position = [self convertPoint: ccp(240, 416)];
		upperTable.visible = NO;
		[self addChild: upperTable z: _logo tag: kUpperTable];
		
		CCSprite *lowerTable = [CCSprite spriteWithFile: table];
		lowerTable.position = [self convertPoint: ccp(240, -96)];
		lowerTable.visible = NO;
		[self addChild: lowerTable z: _logo tag: kLowerTable];
		
		Game *game = [Game sharedGame];
		[game randomizeColor];
		
		CCSprite* spriteT = [CCSprite spriteWithFile: logoTiliard];
		spriteT.position = [self convertPoint: ccp(240, 222) offset: ccp(0, 32)];
		spriteT.color = game.lightColor;
		spriteT.visible = NO;
		[self addChild: spriteT z: _logo tag: kTiliard];
		_logo++;
		
		SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
		if (sae != nil) {
			sae.effectsVolume = (game.music ? 0.1f : 0.3f);
		}
		
		self.isTouchEnabled = YES;
		//[self scheduleUpdate];
	}
    return self;
}

-(void) onEnter {

	_updateTime = [[Game sharedGame] timeSinceLaunch];
	[self scheduleUpdate];
	
	[super onEnter];
}

-(void) onExit {

	[self unscheduleUpdate];
	
	[super onExit];
}

-(CGPoint) convertPoint: (CGPoint) point offset: (CGPoint) offset {
	
	Game *game = [Game sharedGame];
	
	if (game.iPad) {
		return ccp(32 + point.x * 2 + offset.x, 64 + point.y * 2 + offset.y);
	}
	else if (game.iPhone5) {
		return ccp(44 + point.x, point.y);
	}
	return point;
}

-(CGPoint) convertPoint: (CGPoint) point {
	return [self convertPoint: point offset: ccp(0, 0)];
}

-(void) nextLogo {

	_updateTime = 0.0f;

	if (_logo >= 0) {
	
		_logo--;
		if (_logo == 0) {
			
			CCNode *logo = [self getChildByTag: _logo];
			[logo runAction: [CCFadeOut actionWithDuration: kHalfTableMovementDuration]];
			//[self unscheduleUpdate];
			
			CCAction *moveUpAction = [CCSequence actions:
									  [CCMoveTo actionWithDuration: 0.6f position: [self convertPoint: ccp(240, 64)]],
									  [CCDelayTime actionWithDuration: 0.3f],
									  [CCCallFunc actionWithTarget: self selector: @selector(showLogo)],
									  nil];
			CCAction *moveDownAction = [CCMoveTo actionWithDuration: 0.6f position: [self convertPoint: ccp(240, 256)]];
			
			CCNode *upperTable = [self getChildByTag: kUpperTable];
			upperTable.visible = YES;
			[upperTable runAction: moveDownAction];
			CCNode *lowerTable = [self getChildByTag: kLowerTable];
			lowerTable.visible = YES;
			[lowerTable runAction: moveUpAction];
			/*CCNode *tiliard = [self getChildByTag: kTiliard];
			tiliard.visible = YES;
			[tiliard runAction: moveAction];*/
			
			if ([Game sharedGame].sound) {
				[[SimpleAudioEngine sharedEngine] playEffect: kSoundTableCloseFull];
			}
		}
		else {
		
			[self removeChildByTag: _logo cleanup: YES];
			//self.color = ccc3(0, 0, 0);
			[self getChildByTag: (_logo - 1)].visible = YES;
		}
	}
}

-(void) mainMenu {
	
	//[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration: 1.0f scene: [MainMenu scene]]];
	[[CCDirector sharedDirector] replaceScene: [MainMenu scene]];
}

-(void) showLogo {
	
	CCSprite *tiliard = (CCSprite *) [self getChildByTag: kTiliard];
	tiliard.visible = YES;
	tiliard.opacity = 0;
	tiliard.scale = 10.0f;
	[tiliard runAction: [CCSequence actions:
						 //[CCDelayTime actionWithDuration: 0.8f],
						 //[CCCallFunc actionWithTarget: self selector: @selector(playRankSound)],
						 [CCSpawn actions:
						  [CCFadeIn actionWithDuration: 0.3f],
						  [CCScaleTo actionWithDuration: 0.3f scale: 1.0f],
						  nil],
						 [CCCallFunc actionWithTarget: self selector: @selector(loading)],
						 nil]];

	if ([Game sharedGame].sound) {
		[[SimpleAudioEngine sharedEngine] playEffect: kSoundRank];
	}
}

-(void) loading {

	//[self removeChildByTag: _logo cleanup: YES];

	UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *) [[[CCDirector sharedDirector] openGLView] viewWithTag: kActivityIndicator];
	if (activityIndicatorView != nil) {
		[activityIndicatorView startAnimating];
	}
	
	[self runAction: [CCSequence actions:
					  [CCDelayTime actionWithDuration: 0.05f],
					  [CCCallFunc actionWithTarget: self selector: @selector(mainMenu)],
					  nil]];
}

#pragma mark -
#pragma mark Touch Handling

-(void) registerWithTouchDispatcher {

	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority: kCCMenuTouchPriority swallowsTouches: YES];
}

-(BOOL) ccTouchBegan: (UITouch *) touch withEvent: (UIEvent *) event {

	if (_logo > 0) {
		[self nextLogo];
	}
	return NO;
}

/*-(void) ccTouchMoved: (UITouch *) touch withEvent: (UIEvent *) event {
}

-(void) ccTouchCancelled: (UITouch *) touch withEvent: (UIEvent *) event {
}

-(void) ccTouchEnded: (UITouch *) touch withEvent: (UIEvent *) event {
}*/

#pragma mark -
#pragma mark Update

-(void) update: (ccTime) dt {
	
	if (_logo > 0) {
		if (_updateTime >= kDisplayTime) {
			[self nextLogo];
		}
		
		_updateTime += dt;
	}
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[super dealloc];
}

@end
