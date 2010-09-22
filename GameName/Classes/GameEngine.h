//
//  GameEngine.h
//  GameName
//
//  Created by Bassem Farah on 22/08/10.
//  Copyright 2010 Bludger. All rights reserved.
//

/*
 * Copyright 2010 Bassem Farah
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import "BaseObject.h"
#import "Player.h"
#import "SpriteSheet.h"
#import "AngelCodeFont.h"
#import "FBConnect.h"

@interface GameEngine : NSObject <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate> {
	
	CGPoint touchPoint;
	CGPoint oldTouchPoint;
	BOOL inputUpdated;

	
	Player *playerShip;
	
	float timer;
	float bestTime;
	float popUpTimer;	// This timer is used to pause input on the buttons when the player wins or loses.
	
	float gravity;
	Image *backGround;
	Image *moon;
	Image *emptyFuelBar;
	Image *fuelBar;
	BaseObject *platform;
	Image *explosion;
	Image *win;
	Image *lose;
	
	Image *play;
	Image *options;
	
	Image *soundText;
	Image *musicText;
	Image *soundOnButton;
	Image *soundOffButton;
	Image *musicOnButton;
	Image *musicOffButton;
	
	Image *popUpFrame;
	Image *retryButton;
	Image *menuButton;
	Image *faceBookLogo;
	Image *openFeintLogo;
	
	AngelCodeFont *font;
	
	NSString *timeString;
	NSString *bestTimeString;
	
	SystemSoundID startSound;
	SystemSoundID successSound;
	SystemSoundID failureSound;
	
	Facebook *faceBook;
	NSArray* fbPermissions;
	BOOL fbLoggedIn;
	BOOL fbPublished;
	
	BOOL didPlaySound;
	
	BOOL didVibrate;
	
	BOOL masterSoundOn;
	BOOL masterMusicOn;

	unsigned int gameState;
	unsigned int prevGameState;
	
	enum gameStates {
		MAIN_MENU = 0, OPTIONS, RUNNING, PAUSED, WIN, LOSE, EXIT };
}

@property CGPoint touchPoint;
@property BOOL isPaused;

- (void)update:(float) dTime;
- (void)shutdown;
- (void)updateInputInPoint:(CGPoint) inPoint InputPressed:(BOOL) inputPressedIn InputReleased:(BOOL) inputReleasedIn;
- (void)updateAccelerometer:(CGPoint) inAccel;
- (BOOL)PointWithinBounds:(CGPoint) inPoint :(CGRect) inRect;
- (void)reset;
- (void)faceBookAccess;

- (BOOL)doButtonLogicButtonImage:(Image *)buttonImage ButtonRect:(CGRect) buttonRect;
- (void)doPauseLogicIsPaused:(BOOL) paused;
- (void)renderRetryFrame;
@end
