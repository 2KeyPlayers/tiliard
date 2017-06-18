//
//  AppDelegate.h
//  Tiliard
//
//  Created by Patrik Toth on 9/15/11.
//  Copyright patrik.toth@centrum.sk 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
