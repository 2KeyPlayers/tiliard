//
//  AppDelegate.m
//  Tiliard
//
//  Created by Patrik Tóth on 7/4/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "LoadingScene.h"
#import "RootViewController.h"
#import "LoadingScene.h"


@implementation AppDelegate

@synthesize window;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

	CC_ENABLE_DEFAULT_GL_STATES();
	CCDirector *director = [CCDirector sharedDirector];
	CGSize size = [director winSize];

	CCTexture2DPixelFormat originalFormat = [CCTexture2D defaultAlphaPixelFormat]; // ???
	[CCTexture2D setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_RGB565]; // ???
	
	NSString *spriteName = @"Default.png";
	Game *game = [Game sharedGame];
	if (game.iPad || game.retina) {
		spriteName = @"Default@2x.png";
	}
	CCSprite *sprite = [CCSprite spriteWithFile: spriteName];
	sprite.position = ccp(size.width/2, size.height/2);
	sprite.rotation = -90;
	[sprite visit];
	
	[CCTexture2D setDefaultAlphaPixelFormat: originalFormat]; // ???
	
	[[director openGLView] swapBuffers];
	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
	Game *game = [Game sharedGame];
	game.viewController = viewController;
	game.iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if (! game.iPad) {
		game.retina = [director enableRetinaDisplay:YES];
		if( ! game.retina )
			CCLOG(@"Retina Display Not supported");
	}
	
	CGSize size = [director winSize];
	game.iPhone5 = (size.height == 568);
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	[director setProjection: CCDirectorProjection2D];
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	/*CGSize size = [director winSize];
	CGPoint centerOfIndicator = CGPointMake(460, 300);
	if (size.height > size.width) {
		centerOfIndicator = CGPointMake(460, 20);
	}*/
	
	//UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: (game.iPad ? UIActivityIndicatorViewStyleWhiteLarge : UIActivityIndicatorViewStyleWhite)] autorelease];
	activityIndicatorView.tag = kActivityIndicator;
	//activityIndicatorView.color = [UIColor colorWithRed: game.lightColor.r green: game.lightColor.r blue: game.lightColor.r alpha: 255];
	//CGPoint centerOfIndicator = [director convertToUI: ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? ccp(512, 260) : ccp(240, 98))];
	
	// fix for non-retina devices
	CGPoint center = (game.iPad ? ccp(512, 460) : ccp(240, 240));
	
	NSString* sysVer = [[UIDevice currentDevice] systemVersion];
	bool isOSVer5OrLower = ([sysVer compare: @"5.5" options: NSNumericSearch] != NSOrderedDescending);
	if (isOSVer5OrLower) {
		center = (game.iPad ? ccp(512, 192) : ccp(240, 80));
	}
	
	CGPoint centerOfIndicator = [director convertToUI: (game.iPhone5 ? ccp(284, 328) : center)];
	activityIndicatorView.center = centerOfIndicator;
	//[activityIndicatorView setHidesWhenStopped: YES];
	//[activityIndicatorView stopAnimating];
	[glView addSubview: activityIndicatorView];
	
	/*UIImageView *activityIndicatorView = [[[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Loader1.png"]] autorelease];
	activityIndicatorView.tag = kActivityIndicator;
	activityIndicatorView.animationImages = [NSArray arrayWithObjects:
											 [UIImage imageNamed: @"Loader1.png"],
											 [UIImage imageNamed: @"Loader2.png"],
											 [UIImage imageNamed: @"Loader3.png"],
											 [UIImage imageNamed: @"Loader4.png"],
											 [UIImage imageNamed: @"Loader5.png"],
											 [UIImage imageNamed: @"Loader6.png"],
											 [UIImage imageNamed: @"Loader7.png"],
											 [UIImage imageNamed: @"Loader8.png"],
											 nil];
	activityIndicatorView.animationDuration = 1.5f;
	activityIndicatorView.frame = CGRectMake(223, 200, 34, 30);
	activityIndicatorView.hidden = YES;
	[glView addSubview: activityIndicatorView];*/
	
	window.rootViewController = viewController;
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	//[CCTexture2D setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_RGBA4444];
	
	// !!! [CCTexture2D PVRImagesHavePremultipliedAlpha: YES];
	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	/*NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier: nil];
	if (ubiq) {
		NSLog(@"iCloud access at %@", ubiq);
		game.iCloud = YES;
	} else {
		NSLog(@"No iCloud access");
		game.iCloud = NO;
	}*/
	
	if (NSClassFromString(@"NSUbiquitousKeyValueStore") != nil && [NSUbiquitousKeyValueStore defaultStore] != nil) {
		
		NSLog(@"iCloud: YES");
		game.iCloud = YES;
	}
	
	[game launch];
	
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [Loading scene]];
	//[[CCDirector sharedDirector] runWithScene: [MainMenu scene]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
