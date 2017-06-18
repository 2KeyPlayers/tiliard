//
//  Game.m
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/26/10.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#import "Game.h"
#import "Localization.h"
#import "DDGameKitHelper.h"


@implementation Game

@synthesize viewController = _viewController;

@synthesize menu = _menu;
@synthesize sound = _sound;
@synthesize music = _music;
@synthesize language = _language;
@synthesize clothColor = _clothColor;
@synthesize tileSet = _tileSet;
@synthesize ranks = _ranks;
@synthesize trackNr = _trackNr;
@synthesize completed = _completed;
@synthesize tpRanking = _tpRanking;
@synthesize promo = _promo;

@synthesize tableColor = _tableColor;
@synthesize lightColor = _lightColor;
@synthesize color = _color;

@synthesize tableStats = _tableStats;
@synthesize shot = _shot;

@synthesize soundFlags = _soundFlags;
@synthesize showEndOfGame = _showEndOfGame;

@synthesize retina = _retina;
@synthesize iPad = _iPad;
@synthesize iPhone5 = _iPhone5;
@synthesize iCloud = _iCloud;

static Game *_sharedGame = nil;

#pragma mark -
#pragma mark Initializers

+(Game *) sharedGame {
	
	@synchronized(self) {
		if (!_sharedGame) {
			_sharedGame = [[self alloc] init];
		}
	}
	return _sharedGame;
}

+(id) alloc {
	
	NSAssert(_sharedGame == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

-(id) init {
	
	if ((self = [super init])) {
		
		_state = kGameMenu;
		_menu = kMenuMain;
		
		[self initColors];
		[self initTileColors];
		[self initTilehalls];
		
		// default settings
		_music = YES;
		_sound = YES;
		self.language = kLanguageEnglish;
		_clothColor = 0; // random
		_tileSet = 0; // default
		_ranks = NO;
		_trackNr = kMusicTracks;
		_completed = NO;
		_tpRanking = 0;
		_promo = kPromoWhereToJump;
		
		_resetTableColor = NO;
		
		_shot = kShotStraight;
		
		_tables = [[NSMutableArray arrayWithCapacity: kTablesPerTilehall] retain];
		
		_scoresAndStats = [[NSMutableDictionary dictionaryWithCapacity: (kTilehallMAX * kTablesPerTilehall)] retain];
		[_scoresAndStats setValue: [NSNumber numberWithInteger: 0] forKey: @"TH01T01"];
		
		// set the default tilehall
		[self setTilehall: kTilehallTraining];
		[self setTable: 0];
		
		//_color = 120;
		//[self setColorForHue];
		[self randomizeColor];

		[self resetSoundFlags];
		_showEndOfGame = NO;
		
		_retina = NO;
		_iPad = NO;
		_iPhone5 = NO;
		_iCloud = NO;
	}
	return self;
}

-(void) initColors {

	_colors[kTableColorGreen].backgroundColor = ccc3(43, 139, 43);
	_colors[kTableColorGreen].lightColor = ccc3(77, 219, 79);

	_colors[kTableColorRed].backgroundColor = ccc3(147, 45, 54);
	_colors[kTableColorRed].lightColor = ccc3(227, 82, 99);

	_colors[kTableColorBlue].backgroundColor = ccc3(70, 123, 153);
	_colors[kTableColorBlue].lightColor = ccc3(133, 218, 248);

	_colors[kTableColorPurple].backgroundColor = ccc3(160, 32, 110);
	_colors[kTableColorPurple].lightColor = ccc3(224, 49, 156);

	//_colors[kTableColorOrange].backgroundColor = ccc3(255, 128, 0);
	//_colors[kTableColorOrange].lightColor = ccc3(255, 156, 0);

	_colors[kTableColorOrange].backgroundColor = ccc3(255, 128, 0); //ccc3(255, 158, 61); //ccc3(230, 76, 47);
	_colors[kTableColorOrange].lightColor = ccc3(255, 155, 54); //ccc3(255, 171, 87); //ccc3(255, 107, 79);

	/*_colors[kTableColorBrown].backgroundColor = ccc3(124, 98, 63);
	_colors[kTableColorBrown].lightColor = ccc3(175, 149, 114);

	_colors[kTableColorYellow].backgroundColor = ccc3(245, 245, 0); //ccc3(169, 169, 49);
	_colors[kTableColorYellow].lightColor = ccc3(255, 255, 66); //ccc3(220, 220, 142);
	
	_colors[kTableColorViolet].backgroundColor = ccc3(93, 78, 147);
	_colors[kTableColorViolet].lightColor = ccc3(103, 86, 164); //ccc3(177, 165, 208);

	_colors[kTableColorLightOrange].backgroundColor = ccc3(169, 92, 49);
	_colors[kTableColorLightOrange].lightColor = ccc3(220, 177, 142);
	
	_colors[kTableColorLightRed].backgroundColor = ccc3(163, 66, 56);
	_colors[kTableColorLightRed].lightColor = ccc3(218, 157, 148);
	
	_colors[kTableColorLightGreen].backgroundColor = ccc3(80, 142, 84);
	_colors[kTableColorLightGreen].lightColor = ccc3(168, 207, 171);*/
	
	_colors[kTableColorGray].backgroundColor = ccc3(85, 85, 85);
	_colors[kTableColorGray].lightColor = ccc3(127, 127, 127);
	
	_colors[kTableColorFinal].backgroundColor = ccc3(0, 0, 0);
	_colors[kTableColorFinal].lightColor = ccc3(255, 255, 255);
}

-(void) initTileColors {
	
	_tileColors[kTileColorBlack] = ccc3(0, 0, 0);
	_tileColors[kTileColorYellow] = ccc3(255, 210, 0);
	_tileColors[kTileColorBlue] = ccc3(0, 144, 255);
	_tileColors[kTileColorRed] = ccc3(255, 30, 0);
	_tileColors[kTileColorPurple] = ccc3(255, 0, 156);
	_tileColors[kTileColorOrange] = ccc3(255, 102, 0);
	_tileColors[kTileColorGreen] = ccc3(45, 193, 0);
	_tileColors[kTileColorBrown] = ccc3(85, 57, 46);
}

-(void) initTilehalls {

	_tilehalls[kTilehallTraining].numberOfTables = kTablesPerTilehall;
	_tilehalls[kTilehallTraining].color = _colors[kTableColorGreen];
	_tilehalls[kTilehallTraining].tileSet = kTileSetTraining;
	_tilehalls[kTilehallTraining].rotation = NO;
	_tilehalls[kTilehallTraining].unlocked = YES;
	
	_tilehalls[kTilehallPower].numberOfTables = kTablesPerTilehall;
	_tilehalls[kTilehallPower].color = _colors[kTableColorRed];
	_tilehalls[kTilehallPower].tileSet = kTileSetPower;
	_tilehalls[kTilehallPower].rotation = NO;
	_tilehalls[kTilehallPower].unlocked = NO;
	
	_tilehalls[kTilehallDirection].numberOfTables = kTablesPerTilehall;
	_tilehalls[kTilehallDirection].color = _colors[kTableColorBlue];
	_tilehalls[kTilehallDirection].tileSet = kTileSetDirection;
	_tilehalls[kTilehallDirection].rotation = NO;
	_tilehalls[kTilehallDirection].unlocked = NO;
	
	_tilehalls[kTilehallSpin].numberOfTables = kTablesPerTilehall;
	_tilehalls[kTilehallSpin].color = _colors[kTableColorPurple];
	_tilehalls[kTilehallSpin].tileSet = kTileSetSpin;
	_tilehalls[kTilehallSpin].rotation = YES;
	_tilehalls[kTilehallSpin].unlocked = NO;
	
	_tilehalls[kTilehallColor].numberOfTables = kTablesPerTilehall;
	_tilehalls[kTilehallColor].color = _colors[kTableColorOrange];
	_tilehalls[kTilehallColor].tileSet = kTileSetColor;
	_tilehalls[kTilehallColor].rotation = YES;
	_tilehalls[kTilehallColor].unlocked = NO;
	
	_tilehalls[kTilehallComingSoon].numberOfTables = 0;
	_tilehalls[kTilehallComingSoon].color = _colors[kTableColorGray];
	_tilehalls[kTilehallComingSoon].tileSet = kTileSetTraining;
	_tilehalls[kTilehallComingSoon].rotation = NO;
	_tilehalls[kTilehallComingSoon].unlocked = NO;
}

#pragma mark -
#pragma mark iCloud

-(void) ubiquitousKeyValueStoreDidChange: (NSNotification *) notification {
	
	// get the list of keys that changed
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *reasonForChange = [userInfo objectForKey: NSUbiquitousKeyValueStoreChangeReasonKey];
	NSInteger reason = -1;
	
	// if a reason could not be determined, do not update anything
	if (!reasonForChange) {
		return;
	}
	
	// update only for changes from the server
	reason = [reasonForChange integerValue];
	NSLog(@"iCloud: reason %d", reason);
	
	if ((reason == NSUbiquitousKeyValueStoreServerChange) ||
		(reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
		
		// if something is changing externally, get the changes
		// and update the corresponding keys locally.
		NSArray *changedKeys = [userInfo objectForKey: NSUbiquitousKeyValueStoreChangedKeysKey];
		NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
		
		// this loop assumes you are using the same key names in both
		// the user defaults database and the iCloud key-value store
		for (NSString *key in changedKeys) {
			
			if ([key isEqualToString: kTiliardScoresAndStatsKey]) {
				
				NSDictionary *scoresAndStats = [cloudStore dictionaryForKey: kTiliardScoresAndStatsKey];
				[self mergeScoresAndStats: scoresAndStats];
				
				[[NSNotificationCenter defaultCenter] removeObserver: [NSUbiquitousKeyValueStore defaultStore]];
			}
		}
	}
}

-(void) mergeScoresAndStats: (NSDictionary *) dictionary {
	
	if (dictionary != nil) {
		
		for (NSInteger tilehall = 0; tilehall < kTilehallComingSoon; tilehall++) {
			for (NSInteger table = 0; table < kTablesPerTilehall; table++) {
				
				NSString *scoreKey = [NSString stringWithFormat: @"TH%02dT%02d", (tilehall + 1), (table + 1)];
				NSString *rankKey = [NSString stringWithFormat: @"TH%02dT%02dRank", (tilehall + 1), (table + 1)];
				NSString *solutionKey = [NSString stringWithFormat: @"TH%02dT%02dSolution", (tilehall + 1), (table + 1)];
				NSString *hintsKey = [NSString stringWithFormat: @"TH%02dT%02dHints", (tilehall + 1), (table + 1)];
				
				NSNumber *localRank = [_scoresAndStats valueForKey: rankKey];
				NSNumber *iCloudRank = [dictionary valueForKey: rankKey];
				NSNumber *localScore = [_scoresAndStats valueForKey: scoreKey];
				NSNumber *iCloudScore = [dictionary valueForKey: scoreKey];
				NSNumber *iCloudSolution = [dictionary valueForKey: solutionKey];
				NSNumber *iCloudHints = [dictionary valueForKey: hintsKey];
				
				if (localScore) {
					if (iCloudScore) {
						if (localRank) {
							if ([localRank integerValue] < [iCloudRank integerValue]) {
								
								[_scoresAndStats setValue: iCloudScore forKey: scoreKey];
								if (iCloudRank) {
									[_scoresAndStats setValue: iCloudRank forKey: rankKey];
								}
								if (iCloudSolution) {
									[_scoresAndStats setValue: iCloudSolution forKey: solutionKey];
								}
								if (iCloudHints) {
									[_scoresAndStats setValue: iCloudHints forKey: hintsKey];
								}
							}
							else if (([localRank integerValue] == [iCloudRank integerValue]) && ([localScore integerValue] > [iCloudScore integerValue])) {
								
								[_scoresAndStats setValue: iCloudScore forKey: scoreKey];
								if (iCloudRank) {
									[_scoresAndStats setValue: iCloudRank forKey: rankKey];
								}
								if (iCloudSolution) {
									[_scoresAndStats setValue: iCloudSolution forKey: solutionKey];
								}
								if (iCloudHints) {
									[_scoresAndStats setValue: iCloudHints forKey: hintsKey];
								}
							}
						}
						else if (iCloudRank) {
							
							[_scoresAndStats setValue: iCloudScore forKey: scoreKey];
							if (iCloudRank) {
								[_scoresAndStats setValue: iCloudRank forKey: rankKey];
							}
							if (iCloudSolution) {
								[_scoresAndStats setValue: iCloudSolution forKey: solutionKey];
							}
							if (iCloudHints) {
								[_scoresAndStats setValue: iCloudHints forKey: hintsKey];
							}
						}
					}
				}
				else if (iCloudScore) {
					
					[_scoresAndStats setValue: iCloudScore forKey: scoreKey];
					if (iCloudRank) {
						[_scoresAndStats setValue: iCloudRank forKey: rankKey];
					}
					if (iCloudSolution) {
						[_scoresAndStats setValue: iCloudSolution forKey: solutionKey];
					}
					if (iCloudHints) {
						[_scoresAndStats setValue: iCloudHints forKey: hintsKey];
					}
				}
			}
		}
		
		NSNumber *completed = (NSNumber *) [dictionary valueForKey: kGameCompletedKey];
		_completed = (_completed || [completed boolValue]);
		
		NSNumber *tpRanking = (NSNumber *) [dictionary valueForKey: kGameTpRankingKey];
		if (_tpRanking < [tpRanking integerValue]) {
			_tpRanking = [tpRanking integerValue];
		}
		
		[self unlockTilehalls];
		
		[self save];
	}
}

-(void) logCloudStore {

	NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
	NSDictionary *cloudDict = [cloudStore dictionaryRepresentation];
	if (cloudDict) {
		NSLog(@"iCloud dictionary contents:%@", [cloudDict description]);
	} else {
		NSLog(@"iCloud dictionary not found.");
	}
}

#pragma mark -
#pragma mark Load and Save

-(void) launch {

	if (_launch != nil) {
		[_launch release];
		_launch = nil;
	}
	
	_launch = [[NSDate date] retain];

	[self load];

	if (_iCloud) {
		
		NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(ubiquitousKeyValueStoreDidChange:)
													 name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
												   object: cloudStore];
		[cloudStore synchronize];
	}
}

-(ccTime) timeSinceLaunch {

	ccTime time = [_launch timeIntervalSinceNow] * (-1);
	//ccTime time = ([NSDate timeIntervalSinceReferenceDate] - _launch) * (-1);
	return time;
}

-(void) load {

	NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey: @"TiliardGame"];
	
	if (dictionary != nil) {
		
		NSNumber *music = (NSNumber *) [dictionary valueForKey: kGameMusicKey];
		_music = [music boolValue];
		NSNumber *sound = (NSNumber *) [dictionary valueForKey: kGameSoundKey];
		_sound = [sound boolValue];
		self.language = (NSString *) [dictionary valueForKey: kGameLanguageKey];
        [Localization setLanguage: _language];
		NSNumber *clothColor = (NSNumber *) [dictionary valueForKey: kGameClothColorKey];
		_clothColor = [clothColor integerValue];
		NSNumber *tileSet = (NSNumber *) [dictionary valueForKey: kGameTileSetKey];
		_tileSet = [tileSet integerValue];
		NSNumber *ranks = (NSNumber *) [dictionary valueForKey: kGameRanksKey];
		_ranks = [ranks boolValue];
		
		NSNumber *tilehall = (NSNumber *) [dictionary valueForKey: kGameTilehallKey];
		_tilehall = [tilehall integerValue];
		NSNumber *table = (NSNumber *) [dictionary valueForKey: kGameTableKey];
		_table = [table integerValue];

		NSDictionary *scoresAndStats = (NSDictionary *) [dictionary valueForKey: kGameScoresAndStatsKey];
		[_scoresAndStats addEntriesFromDictionary: scoresAndStats];

		//self.version = (NSString *) [_scoresAndStats valueForKey: kGameVersionKey];
		
		NSNumber *completed = (NSNumber *) [_scoresAndStats valueForKey: kGameCompletedKey];
		_completed = [completed boolValue];
		
		NSNumber *tpRanking = (NSNumber *) [_scoresAndStats valueForKey: kGameTpRankingKey];
		if (tpRanking != nil) {
			_tpRanking = [tpRanking integerValue];
		}
		
		[self unlockTilehalls];
		[self setTilehall: _tilehall];
		
		//[self logCloudStore];
	}
	else {
		
		NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey: @"AppleLanguages"];
		for (NSString *lang in languages) {
			
			NSString *country = [lang substringToIndex: 2];
            if ([country isEqualToString: kLanguageEnglish]) {
                
				self.language = kLanguageEnglish;
                break;
            }
            if ([country isEqualToString: kLanguageSlovak]) {
                
				self.language = kLanguageSlovak;
                break;
            }
        }
        
        [Localization setLanguage: _language];
		[self save: NO];
	}
}

-(void) save {

	[self save: YES];
}

-(void) save: (BOOL) iCloudSync {

	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity: 10];
	
	[dictionary setValue: [NSNumber numberWithBool: _music] forKey: kGameMusicKey];
	[dictionary setValue: [NSNumber numberWithBool: _sound] forKey: kGameSoundKey];
	[dictionary setValue: _language forKey: kGameLanguageKey];
	[dictionary setValue: [NSNumber numberWithInteger: _clothColor] forKey: kGameClothColorKey];
	[dictionary setValue: [NSNumber numberWithInteger: _tileSet] forKey: kGameTileSetKey];
	[dictionary setValue: [NSNumber numberWithBool: _ranks] forKey: kGameRanksKey];
	[dictionary setValue: [NSNumber numberWithInteger: _tilehall] forKey: kGameTilehallKey];
	[dictionary setValue: [NSNumber numberWithInteger: _table] forKey: kGameTableKey];
	
	//[_scoresAndStats setValue: _version forKey: kGameVersionKey];
	[_scoresAndStats setValue: [NSNumber numberWithBool: _completed] forKey: kGameCompletedKey];
	[_scoresAndStats setValue: [NSNumber numberWithInteger: _tpRanking] forKey: kGameTpRankingKey];
	[dictionary setValue: _scoresAndStats forKey: kGameScoresAndStatsKey];
	
	// save the game dictionary
	[[NSUserDefaults standardUserDefaults] setObject: dictionary forKey: @"TiliardGame"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (iCloudSync && _iCloud) {
		
		NSUbiquitousKeyValueStore *cloudStore = [NSUbiquitousKeyValueStore defaultStore];
		[cloudStore setDictionary: _scoresAndStats forKey: kTiliardScoresAndStatsKey];
		[cloudStore synchronize];
	}
}

-(void) resetProgress {

	// remove previous settings
	[[NSUserDefaults standardUserDefaults] removeObjectForKey: @"TiliardGame"];
	//[[NSUserDefaults standardUserDefaults] synchronize];
	
	_tilehall = kTilehallTraining;
	_table = 0;
	//_skipsLeft = kNumberOfSkips;
	_ranks = NO;
	
	[_scoresAndStats removeAllObjects];
	[_scoresAndStats setValue: [NSNumber numberWithInteger: 0] forKey: @"TH01T01"];
	
	_completed = NO;
	_showEndOfGame = NO;
	
	[self initTilehalls];
	[self unlockTilehalls];

	[self save];
}

-(void) resetHints {
	
	_ranks = NO;
	
	for (NSInteger tilehall = 0; tilehall < kTilehallComingSoon; tilehall++) {
		for (NSInteger table = 0; table < kTablesPerTilehall; table++) {
		
			NSString *key = [NSString stringWithFormat: @"TH%02dT%02dHints", (tilehall + 1), (table + 1)];
			[_scoresAndStats removeObjectForKey: key];
		}
	}
	
	//[self save];
}

#pragma mark -
#pragma mark Settings

-(void) switchSettings: (NSInteger) what {
	
	if (what == kSettingsSound) {
		_sound = !_sound;
	}
	else if (what == kSettingsMusic) {
		_music = !_music;
	}
	else if (what == kSettingsLanguage) {
		if ([_language isEqualToString: kLanguageEnglish]) {
			self.language = kLanguageSlovak;
		}
		else {
			self.language = kLanguageEnglish;
		}
	}
	else if (what == kSettingsClothColor) {
		_clothColor++;
		_clothColor = _clothColor % (kTableColorMAX - 1);
	}
	else if (what == kSettingsTileSet) {
		_tileSet++;
		if (!_tilehalls[_tileSet - 1].unlocked) {
			_tileSet = 0;
		}
		_tileSet = _tileSet % (kTileSetMAX - 1);
	}
	else if (what == kSettingsRanks) {
		_ranks = !_ranks;
	}
}

-(BOOL) isLanguage: (NSString *) language {

	return ([_language isEqualToString: language]);
}

-(void) setColorForTable: (NSInteger) index {

	_tableColor = _colors[index].backgroundColor;
	_lightColor = _colors[index].lightColor;
	_color = index;
}

-(void) setColorsForTable: (ccColor3B) color {

	_tableColor = ccc3(color.r / 1.7f, color.g / 1.7f, color.b / 1.7f);
	_lightColor = color;
}

-(void) setColorForHue {

	// color calculation -> http://www.javascripter.net/faq/rgb2hsv.htm

	NSInteger i;
	float r, g, b;
	float h, s, v;
	float f, p, q, t;
	
	h = _color;
	h /= 60;	// sector 0 to 5
	s = 1.0f;
	v = 1.0f;
	
	i = floor(h);
	f = h - i; // factorial part of h
	p = v * (1 - s);
	q = v * (1 - s * f);
	t = v * (1 - s * (1 - f));
	switch (i) {
		case 0:
			r = v;
			g = t;
			b = p;
			break;
		case 1:
			r = q;
			g = v;
			b = p;
			break;
		case 2:
			r = p;
			g = v;
			b = t;
			break;
		case 3:
			r = p;
			g = q;
			b = v;
			break;
		case 4:
			r = t;
			g = p;
			b = v;
			break;
		default: // case 5:
			r = v;
			g = p;
			b = q;
			break;
	}
	
	[self setColorsForTable: ccc3(round(r * 255), round(g * 255), round(b * 255))];
}

-(void) resetTableColor {
	
	_resetTableColor = YES;
}

-(BOOL) shouldResetTableColor {

	if (_resetTableColor) {
	
		_resetTableColor = NO;
		return YES;
	}
	return NO;
}

-(void) incrementColor {

	_color += 2;
	if (_color >= 360) {
		_color = 0;
	}
	[self setColorForHue];
}

-(void) randomizeColor {

	//_color = (arc4random() % 360);
	//[self setColorForHue];
	
	if (_clothColor == 0) {
		
		NSInteger color = (arc4random() % (kTableColorMAX - 2)); // do not include last 2
		if (color == _color) {
			color++;
		}
		// use _color for storing the selected color's index
		_color = (color % (kTableColorMAX - 2));
	}
	else {
		
		_color = _clothColor - 1;
	}
	
	_tableColor = _colors[_color].backgroundColor;
	_lightColor = _colors[_color].lightColor;
}

-(void) darkenColorWithDuration: (ccTime) duration time: (ccTime) dt {

	_tableColor = _colors[_color].backgroundColor;
	_tableColor = ccc3(_tableColor.r * (1 - (MIN(dt, duration) / duration)),
					   _tableColor.g * (1 - (MIN(dt, duration) / duration)),
					   _tableColor.b * (1 - (MIN(dt, duration) / duration)));
}

-(void) lightenColorWithDuration: (ccTime) duration time: (ccTime) dt {

	_tableColor = _colors[_color].backgroundColor;
	_tableColor = ccc3(_tableColor.r * MIN(dt, duration) / duration,
					   _tableColor.g * MIN(dt, duration) / duration,
					   _tableColor.b * MIN(dt, duration) / duration);
}

-(char) tileSetChar {
	
	if (_tileSet > 0) {
		return ('A' + _tileSet - 1);
	}
	return _tilehalls[_tilehall].tileSet;
}

-(float) moveDuration {

	return 0.2f;
}

-(BOOL) isRotationEnabled {

	return _tilehalls[_tilehall].rotation;
}

-(void) resetSoundFlags {
	
	_soundFlags.collision = NO;
	_soundFlags.move = NO;
	_soundFlags.pot = NO;
	_soundFlags.rebound = NO;
}

-(NSInteger) nextTrack {

	_trackNr = (_trackNr % kMusicTracks);
	_trackNr = _trackNr + 1;
	
	return _trackNr;
}

-(NSInteger) previousPromo {
	
	_promo = _promo - 1;
	if (_promo < 0) {
		_promo = (kPromoMAX - 1);
	}
	
	return _promo;
}

-(NSInteger) nextPromo {
	
	_promo = _promo + 1;
	_promo = (_promo % kPromoMAX);
	
	return _promo;
}

-(ccColor3B) tileColor: (NSInteger) index {

	return _tileColors[index];
}

#pragma mark -
#pragma mark Tilehalls

-(NSInteger) tilehallIndex {

	return _tilehall;
}

-(void) unlockTilehalls {

	for (NSInteger tilehall = 0; tilehall < kTilehallComingSoon; tilehall++) {
	
		NSString *key = [NSString stringWithFormat: @"TH%02dT01", (tilehall + 1)];
		NSNumber *score = [_scoresAndStats valueForKey: key];
		if (score != nil) {
			_tilehalls[tilehall].unlocked = YES;
		}
	}
	
	NSString* key = [NSString stringWithFormat: @"TH04T%02d", kTablesPerTilehall];
	NSString *score = [_scoresAndStats valueForKey: key];
	if (score != nil && ([_scoresAndStats valueForKey: @"TH05T01"] == nil)) {
		_tilehall = kTilehallColor;
		_tilehalls[_tilehall].unlocked = YES;
		[_scoresAndStats setValue: [NSNumber numberWithInteger: 0] forKey: @"TH05T01"];
	}
}

/*-(void) calculateTilehallProgress {

	for (NSInteger tilehall = 0; tilehall < kTilehallComingSoon; tilehall++) {
	
		NSInteger progress = 0;
		if (_tilehalls[tilehall].unlocked) {
		
			for (NSInteger table = 0; table < kTablesPerTilehall; table++) {
			
				NSString *key = [NSString stringWithFormat: @"TH%02dT%02d", (tilehall + 1), (table + 1)];
				NSNumber *score = [_scoresAndStats valueForKey: key];
				if (score != nil) {
					if ([score integerValue] > 0) {
						progress++;
					}
				}
			}
			
			//if (progress == kTablesPerTilehall) {
			//	progress = 100;
			//}
			//else {
			//	progress = progress * (100 / kTablesPerTilehall);
			//}
		}
		_tilehalls[tilehall].progress = progress;
	}
}*/

-(Tilehall) tilehall {

	return [self tilehallAtIndex: _tilehall];
}

-(Tilehall) tilehallAtIndex: (NSInteger) index {

	return _tilehalls[index];
}

-(void) setTilehall: (NSInteger) tilehall {

	_tilehall = tilehall;
	_tableColor = _tilehalls[_tilehall].color.backgroundColor;
	_lightColor = _tilehalls[_tilehall].color.lightColor;
	_color = _tilehall;
	
	[Tile setTrainingMode: (tilehall == kTilehallTraining)];
}

-(ccColor3B) colorForTilehall: (NSInteger) index {

	if (index < kTilehallMAX) {
		return _tilehalls[index].color.backgroundColor;
	}
	return ccc3(255, 255, 255);
}

-(ccColor3B) lightColorForTilehall: (NSInteger) index {

	if (index < kTilehallMAX) {
		return _tilehalls[index].color.lightColor;
	}
	return ccc3(255, 255, 255);
}

#pragma mark -
#pragma mark Tables

-(NSInteger) tableIndex {

	return _table;
}

-(void) loadTablesForTilehall {

	if ([_tables count] > 0) {
		[_tables removeAllObjects];
	}

	NSString *fileName = [NSString stringWithFormat: @"Tilehall%d", (_tilehall + 1)];
	NSString *plistPath = [[NSBundle mainBundle] pathForResource: fileName ofType: @"plist"];
	NSArray *tables = [NSArray arrayWithContentsOfFile: plistPath];
	
	for (NSDictionary *dict in tables) {
	
		Table *table = [Table tableWithDictionary: dict];
		[_tables addObject: table];
	}
	
	for (Table *table in _tables) {
		
		NSString *name = [table name];
		NSNumber *number = (NSNumber *) [_scoresAndStats valueForKey: name];

		if (number != nil) {
			
			NSInteger score = [number integerValue];
			NSNumber *rank = (NSNumber *) [_scoresAndStats valueForKey: [NSString stringWithFormat: @"%@Rank", name]];
			NSString *solution = (NSString *) [_scoresAndStats valueForKey: [NSString stringWithFormat: @"%@Solution", name]];
			NSNumber *hints = (NSNumber *) [_scoresAndStats valueForKey: [NSString stringWithFormat: @"%@Hints", name]];
			
			if (score == 0) { // unlocked
				[table unlock];
			}
			else if (score < 0) { // skipped
				[table skip];
			}
			else if (score > 0) { // cleared
				[table clearedWithRank: [rank intValue] score: score solution: solution];
			}
			
			if (hints != nil) {
				[table setDisplayHints: [hints boolValue]];
			}
		}
	}
}

-(void) setTable: (NSInteger) table {

	_table = table;
}

-(Table *) table {

	return (Table *) [_tables objectAtIndex: _table];
}

-(Table *) tableAtIndex: (NSInteger) index {

	return (Table *) [_tables objectAtIndex: index];
}

-(Table *) previousTable {

	if (_table > 0) {
		return [self tableAtIndex: (_table - 1)];
	}
	
	return nil;
}

-(Table *) nextTable {
	
	if (_table < (kTablesPerTilehall - 1)) {
		return [self tableAtIndex: (_table + 1)];
	}
	
	return nil;
}

-(NSInteger) rankForTable: (NSInteger) index {

	if (index < [_tables count]) {
	
		Table *table = (Table *) [_tables objectAtIndex: index];
		if (table != nil) {
		
			return [table bestRank];
		}
	}
	return 0;
}

-(NSString *) scoreForTable: (NSInteger) index {

	if (index < [_tables count]) {
	
		Table *table = (Table *) [_tables objectAtIndex: index];
		if (table != nil) {
		
			return [table bestScoreString];
		}
	}
	return nil;
}

-(NSString *) solutionForTable: (NSInteger) index {

	if (index < [_tables count]) {
	
		Table *table = (Table *) [_tables objectAtIndex: index];
		if (table != nil) {
		
			return [table bestSolution];
		}
	}
	return nil;
}

/*-(BOOL) wasTableSkipped: (NSInteger) index {

	if (index < [_tables count]) {
	
		Table *table = (Table *) [_tables objectAtIndex: index];
		if (table != nil) {
		
			return [table wasSkipped];
		}
	}
	return NO;
}*/

-(NSInteger) rank {
	
	return _tableStats.rank;
}

-(NSInteger) score {

	_tableStats.score = (_tableStats.shots * _tableStats.moves);
	return _tableStats.score;
}

-(NSString *) scoreString {

	return [NSString stringWithFormat: @"%d", [self score]];
}

-(void) addShot {

	_tableStats.shots = _tableStats.shots + 1;
}

-(NSInteger) shots {
	
	return _tableStats.shots;
}

-(void) addMove {

	_tableStats.moves = _tableStats.moves + 1;
}

-(NSInteger) moves {
	
	return _tableStats.moves;
}

-(NSString *) equationString {

	return [NSString stringWithFormat: @"%d = %d x %d", [self score], _tableStats.shots, _tableStats.moves];
}

#pragma mark -
#pragma mark Gameplay

-(BOOL) canPlayWithoutDelay {

	NSNumber *score = [_scoresAndStats valueForKey: @"TH01T01"];
	if (score != nil) {
		if ([score integerValue] != 0) {
			return NO;
		}
	}
	return YES;
}

-(BOOL) setNextTilehall {
	
	if (_tilehall < (kTilehallComingSoon - 1)) {
		
		[self setTilehall: (_tilehall + 1)];
		[self setTable: 0];
		
		return YES;
	}
	/*else {
		
		[self setTilehall: kTilehallComingSoon];
	}*/
	
	return NO;
}

-(void) setNextTable {
	
	if (_table < (kTablesPerTilehall - 1)) {
		_table = _table + 1;
	}
}

-(BOOL) isLastTable {
	
	if (_tilehall == (kTilehallComingSoon - 1)) {
		if (_table == (kTablesPerTilehall - 1)) {
			return YES;
		}
	}
	return NO;
}

-(BOOL) isLastTableInSpin {
	
	if (_tilehall == kTilehallSpin) {
		if (_table == (kTablesPerTilehall - 1)) {
			return YES;
		}
	}
	return NO;
}

-(void) setPreviousTable {

	if (_table > 0) {
		_table = _table - 1;
	}
}

-(void) unlockTilehall: (NSInteger) tilehallIndex {

	if (tilehallIndex < kTilehallComingSoon) {
		
		if (!_tilehalls[tilehallIndex].unlocked) {
		
			_tilehalls[tilehallIndex].unlocked = YES;
			[_scoresAndStats setValue: [NSNumber numberWithInteger: 0] forKey: [NSString stringWithFormat: @"TH%02dT01", (tilehallIndex + 1)]];
		}
	}
	
	// save game settings
	[self save];
}

-(void) unlockTable: (NSInteger) tableIndex {

	if (tableIndex < [_tables count]) {
		
		Table *table = (Table *) [_tables objectAtIndex: tableIndex];
		if ([table isLocked]) {
		
			[table unlock];
			[_scoresAndStats setValue: [NSNumber numberWithInteger: 0] forKey: [table name]];

		}
	}
	
	// save game settings
	[self save];
}

-(void) unlockNextTableOrTilehall {

	// unlock next table or tilehall
	if ([self nextTable] != nil) {
		[self unlockTable: (_table + 1)];
	}
	else {
		[self unlockTilehall: (_tilehall + 1)];
	}
}

-(void) skipTable {
	
	Table *table = (Table *) [_tables objectAtIndex: _table];
	[table skip];
			
	[_scoresAndStats setValue: [NSNumber numberWithInteger: -1] forKey: [table name]];
	
	[self unlockNextTableOrTilehall];
	
	// save game settings
	[self save];
}

-(BOOL) clearedTableWithShots: (NSInteger) shots score: (NSInteger) score solution: (NSString *) solution {

	Table *table = (Table *) [_tables objectAtIndex: _table];
	
	NSInteger rank = [table rankForShots: shots];
	if (score < [table bestScore]) {
		rank = kRankStar;
	}
	_tableStats.rank = rank;
	
	BOOL newBestScore = NO;
	if ([table isCleared]) { // already cleared
		
		if ((score < [table bestScore]) || ((score == [table score]) && (shots < [table bestShots]))) {
			
			newBestScore = YES;
			
			[table clearedWithRank: rank score: score solution: solution];
			
			// store score for this table
			[_scoresAndStats setValue: [NSNumber numberWithInteger: score] forKey: [table name]];
			[_scoresAndStats setValue: [NSNumber numberWithInteger: rank] forKey: [NSString stringWithFormat: @"%@Rank", [table name]]];
			
			if (solution != nil) {
				[_scoresAndStats setValue: solution forKey: [NSString stringWithFormat: @"%@Solution", [table name]]];
			}
		}
		else if (rank > [table bestRank]) {
			
			[_scoresAndStats setValue: [NSNumber numberWithInteger: rank] forKey: [NSString stringWithFormat: @"%@Rank", [table name]]];
			
			if (solution != nil) {
				[_scoresAndStats setValue: solution forKey: [NSString stringWithFormat: @"%@Solution", [table name]]];
			}
		}
	}
	else { // unlocked or skipped
		
		[table clearedWithRank: rank score: score solution: solution];
		
		// store score for this table
		[_scoresAndStats setValue: [NSNumber numberWithInteger: score] forKey: [table name]];
		[_scoresAndStats setValue: [NSNumber numberWithInteger: rank] forKey: [NSString stringWithFormat: @"%@Rank", [table name]]];

		if (solution != nil) {
			[_scoresAndStats setValue: solution forKey: [NSString stringWithFormat: @"%@Solution", [table name]]];
		}
	}
	
	if (_tilehall < kTilehallComingSoon) {
		NSInteger clearedPercententage = [self tilehallClearedPercentage: _tilehall];
		
		[[DDGameKitHelper sharedGameKitHelper] reportAchievement: [NSString stringWithFormat: @"TileHall%02dCompleted", (_tilehall +1)]
												 percentComplete: clearedPercententage]; //(10 * (_table + 1))];
	}
	
	EndOfGame eog = [self isEndOfGame];
	if (eog != kEndOfGameNotYet) {
		
		if (!_completed && (_tilehall <= kTilehallSpin)) {
			
			_completed = YES;
			_showEndOfGame = YES;
		}
		
		[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"TilehallJunkie"
												 percentComplete: 100];
		if (eog == kEndOfGameAllStar) {
			[[DDGameKitHelper sharedGameKitHelper] reportAchievement: @"AllStar"
													 percentComplete: 100];
		}
	}
	
	[self unlockNextTableOrTilehall];
	
	return newBestScore;
}

-(void) hintsFinished {

	Table *table = (Table *) [_tables objectAtIndex: _table];
	[table setDisplayHints: NO];
	
	[_scoresAndStats setValue: [NSNumber numberWithBool: NO] forKey: [NSString stringWithFormat: @"%@Hints", [table name]]];

	// save game settings
	[self save];
}

-(NSInteger) tilehallClearedPercentage: (NSInteger) tilehall {
	
	NSInteger currentTilehall = _tilehall;
	NSInteger currentTable = _table;
	
	NSInteger clearedPercentage = 0;
	
	if (_tilehalls[tilehall].unlocked) {
		
		_tilehall = tilehall;
		[self loadTablesForTilehall];
		
		for (NSInteger table = 0; table < kTablesPerTilehall; table++) {
			
			Table *t = (Table *) [_tables objectAtIndex: table];
			if ([t isCleared]) {
				clearedPercentage += 10;
			}
		}
	}
	
	_tilehall = currentTilehall;
	[self loadTablesForTilehall];
	_table = currentTable;
	
	return clearedPercentage;
}

-(EndOfGame) isEndOfGame {

	NSInteger currentTilehall = _tilehall;
	NSInteger currentTable = _table;
	
	EndOfGame eog = kEndOfGameAllStar;
	
	//for (NSInteger tilehall = 0; tilehall < kTilehallComingSoon; tilehall++) {
	for (NSInteger tilehall = 0; tilehall <= kTilehallSpin; tilehall++) {
		if ((eog != kEndOfGameNotYet) && _tilehalls[tilehall].unlocked) {
		
			_tilehall = tilehall;
			[self loadTablesForTilehall];
			
			for (NSInteger table = 0; table < kTablesPerTilehall; table++) {
			
				Table *t = (Table *) [_tables objectAtIndex: table];
				if (![t isCleared]) {
					eog = kEndOfGameNotYet;
					break;
				}
				if ((eog == kEndOfGameAllStar) && [t bestRank] != kRankStar) {
					eog = kEndOfGameTilehallJunkie;
				}
			}
		}
		else {
		
			eog = kEndOfGameNotYet;
			break;
		}
	}
	
	_tilehall = currentTilehall;
	[self loadTablesForTilehall];
	_table = currentTable;
	
	return eog;
}

-(NSInteger) totalRanking {
	
	NSInteger currentTilehall = _tilehall;
	NSInteger currentTable = _table;
	
	NSInteger ranking = 0;
	
	//for (NSInteger tilehall = 0; tilehall < kTilehallComingSoon; tilehall++) {
	for (NSInteger tilehall = 0; tilehall <= kTilehallSpin; tilehall++) {
		if (_tilehalls[tilehall].unlocked) {
			
			_tilehall = tilehall;
			[self loadTablesForTilehall];
			
			for (NSInteger table = 0; table < kTablesPerTilehall; table++) {
				
				Table *t = (Table *) [_tables objectAtIndex: table];
				ranking = ranking + [t bestRank];
			}
		}
	}
	
	_tilehall = currentTilehall;
	[self loadTablesForTilehall];
	_table = currentTable;
	
	return ranking;
}

#pragma mark -
#pragma mark States

-(void) mainMenu {
	
	_state = kGameMenu;
}

-(void) start {
	
	_state = kGameStarted;
	_menu = kMenuGame;
}

-(void) aim {
	
	_state = kGameAiming;
}

-(void) pause {
	
	_state = kGamePaused;
	_menu = kMenuPause;
}

-(void) resume {
	
	_state = kGameStarted;
	_menu = kMenuGame;
}

-(void) stop {
	
	_state = kGameStopped;
	
	_tableStats.shots = 0;
	_tableStats.moves = 0;
	_tableStats.score = 0;
	_tableStats.rank = kRankNo;
}

-(void) restart {
	
	_state = kGameStarted;
	_menu = kMenuGame;
	
	_tableStats.shots = 0;
	_tableStats.moves = 0;
	_tableStats.score = 0;
	_tableStats.rank = kRankNo;
}

-(void) abort {
	
	_state = kGameAborted;
}

-(void) end {
	
	_state = kGameEnded;
	_menu = kMenuTableCleared;
}

-(void) edit {
	
	_state = kGameEditor;
}

-(BOOL) isInState: (NSInteger) state {
	
	return (_state == state);
}

-(BOOL) isNotInState: (NSInteger) state {
	
	return (_state != state);
}

#pragma mark -
#pragma mark Dealloc

-(void) dealloc {
	
	//[[NSNotificationCenter defaultCenter] removeObserver: [NSUbiquitousKeyValueStore defaultStore]];

	self.viewController = nil;
	
	_sharedGame = nil;
	
	[_launch release];
	_launch = nil;
	
	self.language = nil;
	
	[_tables release];
	_tables = nil;
	
	[_scoresAndStats release];
	_scoresAndStats = nil;
	
	[super dealloc];
}

@end
