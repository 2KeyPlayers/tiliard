//
//  Localization.m
//  Tiliard
//
//  Created by Patrik & Marek Toth on 05/18/11.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#import "Localization.h"


@implementation Localization

static NSBundle *_bundle = nil;

#pragma mark -
#pragma mark Initializers

+(void) initialize {

	// set default language - English
	[self setLanguage: @"en"];
}

+(void) setLanguage: (NSString *) language {

	[_bundle release];
	_bundle = nil;
	
	NSString *path = [[NSBundle mainBundle] pathForResource: language ofType: @"lproj"];
	_bundle = [[NSBundle bundleWithPath: path] retain];
}

+(NSString *) getStringForKey: (NSString *) key {
	
	if (_bundle != nil) {
		NSString *s = [_bundle localizedStringForKey: key value: nil table: nil];
		return s;
	}
	return nil;
}

+(NSString *) getStringForKey: (NSString *) key alter: (NSString *) alternate {
	
	if (_bundle != nil) {
		NSString *s = [_bundle localizedStringForKey: key value: alternate table: nil];
		return s;
	}
	return nil;
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	[_bundle release];
	_bundle = nil;
	
	[super dealloc];
}

@end
