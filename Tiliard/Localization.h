//
//  Localization.h
//  Tiliard
//
//  Created by Patrik & Marek Toth on 07/28/11.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


@interface Localization : NSObject {
}

+(void) setLanguage: (NSString *) language;

+(NSString *) getStringForKey: (NSString *) key;

+(NSString *) getStringForKey: (NSString *) key alter: (NSString *) alternate;

@end
