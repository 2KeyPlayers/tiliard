//
//  Game.h
//  Tiliard
//
//  Created by Patrik & Marek Toth on 12/26/10.
//  Copyright 2010-2011 2 Key Players. All rights reserved.
//


#import "Tile.h"
#import "Table.h"

#define kAppID @"526999566"

#define kActivityIndicator 9999

#define kTiliardScoresAndStatsKey @"TiliardScoresAndStats"

#define kGameMusicKey @"Music"
#define kGameSoundKey @"Sound"
#define kGameLanguageKey @"Language"
#define kGameClothColorKey @"ClothColor"
#define kGameTileSetKey @"TileSet"
#define kGameRanksKey @"Ranks"
#define kGameTilehallKey @"Tilehall"
#define kGameTableKey @"Table"
#define kGameScoresAndStatsKey @"ScoresAndStats"
// stats
#define kGameCompletedKey @"Completed"
#define kGameTpRankingKey @"TpRanking"

#define kLanguageEnglish @"en"
#define kLanguageSlovak @"sk"

#define kTransitionDuration 0.2f

#define kFullTableMovementDuration 0.6f
#define kHalfTableMovementDuration 0.4f //(kFullTableMovementDuration / 2)

#define kTablesPerTilehall 10

#define kTableSpeed 0.1f

#define kFont @"Arial-BoldMT"

/* Music */

#define kMusicTracks 2

/* Sounds */

#define kSoundTableOpenFull		@"Sound07.wav"
#define kSoundTableCloseFull	@"Sound07.wav"
#define kSoundTableOpenHalf		@"Sound06.wav"
#define kSoundTableCloseHalf	@"Sound06.wav"

#define kSoundMenuTap			@"Sound01.wav"
#define kSoundMenuSlide			@"Sound01.wav"

//#define kSoundTileShot		@"Sound02.wav"
#define kSoundTileMove			@"Sound01.wav"
#define kSoundTileRebound		@"Sound03.wav"
#define kSoundTileCollision		@"Sound02.wav"
#define kSoundTilePot			@"Sound04.wav"

#define kSoundRackUp			@"Sound05.wav"
#define kSoundUndo				@"Sound05.wav"
#define kSoundReset				@"Sound05.wav"
#define kSoundRank				@"Sound08.wav"
#define kSoundError				@"Sound09.wav"
#define kSoundInfo				@"Sound10.wav"
#define kSoundEndOfGame			@"Sound11.wav"


typedef struct _SoundFlags {
	BOOL move;
	BOOL pot;
	BOOL collision;
	BOOL rebound;
} SoundFlags;

typedef struct _Colors {
	ccColor3B backgroundColor;
	ccColor3B lightColor;
} Colors;

enum {
	kTableColorGreen = 0,
	kTableColorRed,
	kTableColorBlue,
	kTableColorPurple,
	kTableColorOrange,
	/*kTableColorBrown,
	kTableColorYellow,
	kTableColorViolet,
	kTableColorLightOrange,
	kTableColorLightRed,
	kTableColorLightGreen,*/
	kTableColorGray,
	kTableColorFinal,
	kTableColorMAX
};

/*typedef enum _GameStats {
	kGameStatsShots = 0;
	kGameStatsMoves;
	kGameStatsScore;
	kGameStatsPots;
	kGameStatsBankShots;
	kGameStatsCorners;
	kGameStatsCollisions;
	kGameStatsPowerUps;
	kGameStatsUndos;
	kGameStatsRestarts;
} GameStats;*/

typedef enum _GameState {
	kGameMenu = 0,
	kGameInfo,
	kGameStopped,
	kGameStarted,
	kGameAiming,
	kGamePaused,
	kGameAborted,
	kGameEnded,
	kGameEditor,
	kGameTesting
} GameState;

typedef enum _Settings {
	kSettingsMusic,
	kSettingsSound,
	kSettingsLanguage,
	kSettingsClothColor,
	kSettingsTileSet,
	kSettingsRanks,
	kSettingsCloud
} Settings;

enum _Tilehalls {
	kTilehallTraining = 0,
	kTilehallPower,
	kTilehallDirection,
	kTilehallSpin,
	kTilehallColor,
	kTilehallComingSoon,
	kTilehallMAX
} Tilehalls;

typedef struct _Tilehall {
	NSInteger numberOfTables;
	Colors color;
	char tileSet;
	BOOL rotation;
	BOOL unlocked;
} Tilehall;

typedef struct _TableStats {
	NSInteger shots;
	NSInteger moves;
	NSInteger score;
	NSInteger rank;
} TableStats;

typedef enum _MenuMain {
	kMenuOptions = 0,
	kMenuMain,
	kMenuCredits,
	kMenuTilehallTableSelect,
	kMenuPromo
} MenuMain;

typedef enum _MenuGameplay {
	kMenuGame = 0,
	kMenuPause,
	kMenuTableCleared
} MenuGameplay;

typedef enum _EndOfGame {
	kEndOfGameNotYet = 0,
	kEndOfGameTilehallJunkie,
	kEndOfGameAllStar
} EndOfGame;

typedef enum _Promo {
	kPromoInfo = 0,
	kPromoWhereToJump,
	kPromoLums,
	kPromoWoozzle,
	kPromoPunchAHole,
	kPromoMAX
} Promo;

@interface Game : NSObject {

	UIViewController *_viewController;
	
	Colors _colors[kTableColorMAX];

	ccColor3B _tileColors[kTileColorMAX];
	
	NSDate *_launch;
	
	/* Menu */
	
	NSInteger _menu;
	
	/* Settings */
	
	BOOL _music;
	
	BOOL _sound;
	
	NSString *_language;
	
	NSInteger _clothColor;
	
	NSInteger _tileSet;
	
	BOOL _ranks;
	
	NSInteger _trackNr;
	
	BOOL _completed;
	
	NSInteger _tpRanking;
	
	NSInteger _promo;
	
	/* Tilehalls */
	
	Tilehall _tilehalls[kTilehallMAX];
	
	NSInteger _tilehall;
	
	NSInteger _color;
	
	ccColor3B _tableColor;
	
	ccColor3B _lightColor;
	
	BOOL _resetTableColor;
	
	NSInteger _shot;
	
	/* Tables */
	
	NSInteger _table;
	
	NSMutableArray *_tables;
	
	TableStats _tableStats;
	
	/* Gameplay */
	
	SoundFlags _soundFlags;
	
	NSInteger _state;
	
	NSMutableDictionary *_scoresAndStats;
	
	BOOL _showEndOfGame;
	
	/* Retina */
	
	BOOL _retina;
		
	BOOL _iPad;
	
	BOOL _iPhone5;
	
	BOOL _iCloud;
}

@property (nonatomic, retain) UIViewController *viewController;

@property (nonatomic, assign) NSInteger menu;
@property (nonatomic, assign) BOOL music;
@property (nonatomic, assign) BOOL sound;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, assign) NSInteger clothColor;
@property (nonatomic, assign) NSInteger tileSet;
@property (nonatomic, assign) BOOL ranks;
@property (nonatomic, assign) NSInteger trackNr;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, assign) NSInteger tpRanking;
@property (nonatomic, assign) NSInteger promo;

@property (nonatomic, readonly) ccColor3B tableColor;
@property (nonatomic, readonly) ccColor3B lightColor;
@property (nonatomic, assign) NSInteger color;

@property (nonatomic, assign) TableStats tableStats;
@property (nonatomic, assign) NSInteger shot;

@property (nonatomic, assign) SoundFlags soundFlags;
@property (nonatomic, assign) BOOL showEndOfGame;

@property (nonatomic, assign) BOOL retina;
@property (nonatomic, assign) BOOL iPad;
@property (nonatomic, assign) BOOL iPhone5;
@property (nonatomic, assign) BOOL iCloud;

+(Game *) sharedGame;

-(void) initColors;

-(void) initTileColors;

-(void) initTilehalls;

-(void) setColorForTable: (NSInteger) index;

#pragma mark -
#pragma mark Load and Save

-(void) launch;

-(ccTime) timeSinceLaunch;

-(void) mergeScoresAndStats: (NSDictionary *) dictionary;

-(void) load;

-(void) save;

-(void) save: (BOOL) iCloudSync;

-(void) resetProgress;

-(void) resetHints;

#pragma mark -
#pragma mark Settings

-(void) switchSettings: (NSInteger) what;

-(BOOL) isLanguage: (NSString *) language;

-(void) setColorForTable: (NSInteger) index;

-(void) setColorsForTable: (ccColor3B) color;

-(void) setColorForHue;

-(void) incrementColor;

-(void) randomizeColor;

-(void) resetTableColor;

-(BOOL) shouldResetTableColor;

-(void) darkenColorWithDuration: (ccTime) duration time: (ccTime) dt;

-(void) lightenColorWithDuration: (ccTime) duration time: (ccTime) dt;

-(char) tileSetChar;

-(float) moveDuration;

-(BOOL) isRotationEnabled;

-(void) resetSoundFlags;

-(NSInteger) nextTrack;

-(NSInteger) previousPromo;

-(NSInteger) nextPromo;

-(ccColor3B) tileColor: (NSInteger) index;

#pragma mark -
#pragma mark Tilehalls

-(NSInteger) tilehallIndex;

-(void) unlockTilehalls;

-(Tilehall) tilehall;

-(Tilehall) tilehallAtIndex: (NSInteger) index;

-(void) setTilehall: (NSInteger) tilehall;

-(ccColor3B) colorForTilehall: (NSInteger) index;

-(ccColor3B) lightColorForTilehall: (NSInteger) index;

#pragma mark -
#pragma mark Tables

-(NSInteger) tableIndex;

-(void) loadTablesForTilehall;

-(void) setTable: (NSInteger) table;

-(Table *) table;

-(Table *) tableAtIndex: (NSInteger) index;

-(Table *) previousTable;

-(Table *) nextTable;

-(NSInteger) rank;

-(NSInteger) score;

-(NSString *) scoreString;

-(void) addShot;

-(NSInteger) shots;

-(void) addMove;

-(NSInteger) moves;

-(NSString *) equationString;

#pragma mark -
#pragma mark Gameplay

-(BOOL) canPlayWithoutDelay;

-(BOOL) setNextTilehall;

-(void) setNextTable;

-(BOOL) isLastTable;

-(BOOL) isLastTableInSpin;

-(void) setPreviousTable;

-(void) skipTable;

-(BOOL) clearedTableWithShots: (NSInteger) shots score: (NSInteger) score solution: (NSString *) solution;

-(void) hintsFinished;

-(NSInteger) tilehallClearedPercentage: (NSInteger) tilehall;

-(EndOfGame) isEndOfGame;

-(NSInteger) totalRanking;

#pragma mark -
#pragma mark States

-(void) mainMenu;

-(void) start;

-(void) aim;

-(void) pause;

-(void) resume;

-(void) stop;

-(void) restart;

-(void) abort;

-(void) end;

-(void) edit;

-(BOOL) isInState: (NSInteger) state;

-(BOOL) isNotInState: (NSInteger) state;

@end
