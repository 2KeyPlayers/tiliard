//
//  LoadingScene.h
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/01/11.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "BaseScene.h"

#define kDisplayTime 2.0f


enum {
	kLogoPr = 0,
	kLogo2kp,
	kLogoTiliard,
	kLogoMAX
};


@interface Loading : CCLayerColor {

	NSInteger _logo;
	
	ccTime _updateTime;
}

#pragma mark -
#pragma mark Scene Creator

+(id) scene;

@end
