//
//  Table.m
//  Tiliard
//
//  Created by Patrik & Marek Toth on 05/18/11.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#import "Table.h"


@implementation Table

#pragma mark -
#pragma mark Initializers

+(id) tableWithDictionary: (NSDictionary *) dictionary {
	
	return [[[self alloc] initWithDictionary: dictionary] autorelease];
}

-(id) initWithDictionary: (NSDictionary *) dictionary {
	
	if ((self = [super init])) {
		
		_dictionary = [dictionary retain];
		
		_state = kTableLocked;
		_bestRank= kRankNo;
		_bestScore = 0;
		_bestSolution = nil;
		_displayHints = YES;
	}
	return self;
}

#pragma mark -
#pragma mark State

-(void) lock {

	_state = kTableLocked;
}

-(BOOL) isLocked {

	return (_state == kTableLocked);
}

-(void) unlock {

	_state = kTableUnlocked;
	_bestRank = kRankNo;
}

-(BOOL) isUnlocked {

	return (_state == kTableUnlocked);
}

-(void) clearedWithRank: (NSInteger) rank score: (NSInteger) score solution: (NSString *) solution {

	_state = kTableCleared;
	
	_bestRank = rank;
	_bestScore = score;
	[self setBestSolution: solution];
}

-(BOOL) isCleared {

	return (_state == kTableCleared);
}

-(NSInteger) rankForShots: (NSInteger) shots {

	NSInteger rank = kRankPlayer;
	if (shots <= [self shotsForRank: kRankStar]) {
		rank = kRankStar;
	}
	else if (shots <= [self shotsForRank: kRankPro]) {
		rank = kRankPro;
	}
	
	return rank;
}

-(void) skip {

	_state = kTableSkipped;
	
	_bestScore = -1;
	//_bestRank = -1;
}

-(BOOL) isSkipped {

	return (_state == kTableSkipped);
}

#pragma mark -
#pragma mark Attributes

-(NSString *) author {

	return (NSString *) [_dictionary valueForKey: kTableAuthorKey];
}

-(NSString *) name {

	return (NSString *) [_dictionary valueForKey: kTableNameKey];
}

-(NSString *) description {

	return (NSString *) [_dictionary valueForKey: kTableDescriptionKey];
}

-(NSString *) layout {

	return (NSString *) [_dictionary valueForKey: kTableLayoutKey];
}

-(NSString *) solution {

	return (NSString *) [_dictionary valueForKey: kTableSolutionKey];
}

-(NSInteger) shots {

	NSNumber *number = (NSNumber *) [_dictionary valueForKey: kTableShotsKey];
	return [number integerValue];
}

-(NSString *) scoreSetter {
	
	NSString *scoreSetter = (NSString *) [_dictionary valueForKey: kTableScoreSetterKey];
	if (scoreSetter == nil) {
		return (NSString *) [_dictionary valueForKey: kTableAuthorKey];
	}
	return scoreSetter;
}

-(NSInteger) shotsForRank: (NSInteger) rank {

	if (rank == kRankStar) {
		return [self shots];
	}
	if (rank == kRankPro) {
		NSInteger shots = [self shots];
		return (shots + (kMaximumSolutionShots - shots) / 2);
	}
	return 0; //kMaximumSolutionShots // kRankPlayer
}

-(NSInteger) moves {

	NSNumber *number = (NSNumber *) [_dictionary valueForKey: kTableMovesKey];
	return [number integerValue];
}

-(NSInteger) score {

	return ([self shots] * [self moves]);
}

-(void) setBestRank: (NSInteger) rank {
	
	_bestRank = rank;
}

-(NSInteger) bestRank {
	
	return _bestRank;
}

-(NSString *) bestRankString {
	
	return [NSString stringWithFormat: @"%d", _bestRank];
}

-(void) setBestScore: (NSInteger) score {

	_bestScore = score;
}

-(NSInteger) bestScore {
	
	return _bestScore;
}

-(NSString *) bestScoreString {
	
	return [NSString stringWithFormat: @"%d", _bestScore];
}

-(NSString *) bestSolution {

	return _bestSolution;
}

-(void) setBestSolution: (NSString *) solution {

	[_bestSolution release];
	_bestSolution = [[NSString stringWithFormat: @"%@", solution] retain];
}

-(NSInteger) bestShots {
	
	if (_bestSolution == nil) {
		return 0;
	}
	NSArray * solution = [_bestSolution componentsSeparatedByString: @" "];
	return [solution count];
}

-(NSInteger) totalHints {

	NSArray *hints = (NSArray *) [_dictionary valueForKey: kTableHintsKey];
	if (hints != nil) {

		return [hints count];
	}
	return 0;
}

-(NSString *) hintAtIndex: (NSInteger) index {

	if (index < [self totalHints]) {

		NSArray *hints = (NSArray *) [_dictionary valueForKey: kTableHintsKey];
		return (NSString *) [hints objectAtIndex: index];
	}
	return nil;
}

-(BOOL) displayHints {

	return _displayHints;
}

-(void) setDisplayHints: (BOOL) display {

	_displayHints = display;
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	[_dictionary release];
	_dictionary = nil;
	
	[_bestSolution release];
	_bestSolution = nil;
	
	[super dealloc];
}

@end
