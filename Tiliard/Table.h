//
//  Table.h
//  Tiliard
//
//  Created by Patrik & Marek Toth on 05/18/11.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#define kTableAuthorKey @"Author"
#define kTableNameKey @"Name"
#define kTableDescriptionKey @"Description"
#define kTableMovesKey @"Moves"
#define kTableShotsKey @"Shots"
#define kTableHintsKey @"Hints"
#define kTableLayoutKey @"Layout"
#define kTableSolutionKey @"Solution"
#define kTableScoreSetterKey @"ScoreSetter"

#define kMaximumSolutionShots 15

#define kColorWhite		ccc3(255, 255, 255)
#define kColorBlack		ccc3(0, 0, 0)
#define kColorGray		ccc3(119, 119, 119)
#define kColorDarkGray	ccc3(60, 60, 60)
#define kColorRed		ccc3(255, 0, 0)
#define kColorGold		ccc3(255, 240, 65) //ccc3(238, 229, 77) //ccc3(255, 228, 0) //ccc3(235, 186, 55); //ccc3(255, 215, 0);
#define kColorSilver	ccc3(196, 196, 196)
#define kColorBronze	ccc3(204, 113, 74) //ccc3(205, 127, 50);


typedef enum _TableState {
	kTableLocked = 0,
	kTableUnlocked,
	kTableCleared,
	kTableSkipped,
} TableState;

typedef enum _Rank {
	kRankNo = 0,
	kRankPlayer,
	kRankPro,
	kRankStar
} Rank;



@interface Table : NSObject {

	TableState _state;
	
	NSDictionary *_dictionary;
	
	NSInteger _bestRank;
	
	NSInteger _bestScore;
	
	NSString *_bestSolution;
	
	BOOL _displayHints;
}

#pragma mark -
#pragma mark Initializers

+(id) tableWithDictionary: (NSDictionary *) dictionary;

-(id) initWithDictionary: (NSDictionary *) dictionary;

#pragma mark -
#pragma mark State

-(void) lock;

-(BOOL) isLocked;

-(void) unlock;

-(BOOL) isUnlocked;

-(void) clearedWithRank: (NSInteger) rank score: (NSInteger) score solution: (NSString *) solution;

-(BOOL) isCleared;

-(NSInteger) rankForShots: (NSInteger) shots;

-(void) skip;

-(BOOL) isSkipped;

#pragma mark -
#pragma mark Attributes

-(NSString *) author;

-(NSString *) name;

-(NSString *) description;

-(NSString *) layout;

-(NSString *) solution;

-(NSString *) scoreSetter;

-(NSInteger) shots;

-(NSInteger) shotsForRank: (NSInteger) rank;

-(NSInteger) moves;

-(NSInteger) score;

-(NSInteger) bestRank;

-(void) setBestRank: (NSInteger) rank;

-(NSString *) bestRankString;

-(NSInteger) bestScore;

-(void) setBestScore: (NSInteger) score;

-(NSString *) bestScoreString;

-(NSString *) bestSolution;

-(void) setBestSolution: (NSString *) solution;

-(NSInteger) bestShots;

-(NSInteger) totalHints;

-(NSString *) hintAtIndex: (NSInteger) index;

-(BOOL) displayHints;

-(void) setDisplayHints: (BOOL) display;

@end
