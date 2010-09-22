//
//  GameEngine.m
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


#import "GameEngine.h"
#import <AudioToolbox/AudioToolbox.h>
#include <stdlib.h>

#define appID @"59a13f6941760ce388113ea67d26e981"

@implementation GameEngine


@synthesize touchPoint, isPaused;

- (id)init {
	
	self = [super init];
	
	if( self )
	{		
		
		gravity = 9.8f;
		
		didVibrate = FALSE;
		didPlaySound = FALSE;
		inputUpdated = FALSE;

		masterMusicOn = TRUE;
		masterSoundOn = TRUE;
		
		playerShip = [[Player alloc] init];
		[playerShip setMasterSoundOn:masterSoundOn];
		
		backGround = [[Image alloc] initWithImage:[UIImage imageNamed:@"Background.png"] filter: GL_LINEAR];
		moon = [[Image alloc] initWithImage:[UIImage imageNamed:@"Moon.png"] filter:GL_LINEAR];
				
		emptyFuelBar = [[Image alloc] initWithImage:[UIImage imageNamed:@"EmptyFuelBar.png"] filter:GL_LINEAR];
		
		fuelBar = [[Image alloc] initWithImage:[UIImage imageNamed:@"FuelBar.png"] filter:GL_LINEAR];
		[fuelBar setScaleY:[playerShip fuel]];
		
		CGPoint platformPos = CGPointMake(  ( arc4random() % 280 ) + 20, 15.0f);
		platform = [[BaseObject alloc] initObject:@"Platform.png" position:platformPos velocity:CGPointMake(0.0f, 0.0f) scale:1.0f colorFilterRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
		
		explosion = [[Image alloc] initWithImage:[UIImage imageNamed:@"Explosion.png"] filter:GL_LINEAR];
		
		win = [[Image alloc] initWithImage:[UIImage imageNamed:@"Win.png"] filter:GL_LINEAR];
		
		lose = [[Image alloc] initWithImage:[UIImage imageNamed:@"Lose.png"] filter:GL_LINEAR];
				
		play = [[Image alloc] initWithImage:[UIImage imageNamed:@"PlayButton.png"] filter:GL_LINEAR];
		
		options = [[Image alloc] initWithImage:[UIImage imageNamed:@"OptionsButton.png"] filter:GL_LINEAR];
		
		font = [[AngelCodeFont alloc] initWithFontImageNamed:@"MenloFont24.png" controlFile:@"MenloFont24" scale:1.0f filter:GL_LINEAR];
		
		popUpFrame = [[Image alloc] initWithImage:[UIImage imageNamed:@"PopUpFrame.png"] filter:GL_LINEAR];
		retryButton = [[Image alloc] initWithImage:[UIImage imageNamed:@"RetryButton.png"] filter:GL_LINEAR];
		menuButton = [[Image alloc] initWithImage:[UIImage imageNamed:@"MenuButton.png"] filter:GL_LINEAR];
		faceBookLogo = [[Image alloc] initWithImage:[UIImage imageNamed:@"FaceBookLogo.png"] scale: 0.75f filter:GL_LINEAR];
		openFeintLogo = [[Image alloc] initWithImage:[UIImage imageNamed:@"OpenFeintLogo.png"] filter:GL_LINEAR];
		
		soundText = [[Image alloc] initWithImage:[UIImage imageNamed:@"SoundText.png"] filter:GL_LINEAR];
		musicText = [[Image alloc] initWithImage:[UIImage imageNamed:@"MusicText.png"] filter:GL_LINEAR];
		soundOnButton = [[Image alloc] initWithImage:[UIImage imageNamed:@"OnButton.png"] filter:GL_LINEAR];
		soundOffButton = [[Image alloc] initWithImage:[UIImage imageNamed:@"OffButton.png"] filter:GL_LINEAR];
		musicOnButton = [[Image alloc] initWithImage:[UIImage imageNamed:@"OnButton.png"] filter:GL_LINEAR];
		musicOffButton = [[Image alloc] initWithImage:[UIImage imageNamed:@"OffButton.png"] filter:GL_LINEAR];
		
		NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Start" ofType:@"caf"];
		CFURLRef soundFileURL = (CFURLRef )[NSURL fileURLWithPath:soundFilePath];
		AudioServicesCreateSystemSoundID (soundFileURL, &startSound );
			
		soundFilePath = [[NSBundle mainBundle] pathForResource:@"Failure" ofType:@"caf"];
		soundFileURL = (CFURLRef )[NSURL fileURLWithPath:soundFilePath];
		AudioServicesCreateSystemSoundID (soundFileURL, &failureSound );
		
		soundFilePath = [[NSBundle mainBundle] pathForResource:@"Success" ofType:@"caf"];
		soundFileURL = (CFURLRef )[NSURL fileURLWithPath:soundFilePath];
		AudioServicesCreateSystemSoundID (soundFileURL, &successSound );
				
		
		// FaceBook set up
		fbPermissions = [[NSArray arrayWithObjects:@"read_stream", @"offline_access", nil] retain];
		faceBook = [[Facebook alloc] init];
		fbLoggedIn = FALSE;
		fbPublished = FALSE;
		
		
		timer = 0.0f;
		bestTime = 0.0f;
		popUpTimer = 0.0f;		
		
		NSString *dateKey = @"dateKey";
		NSDate *lastRead = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];
		
		if( lastRead == nil )
		{
			NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
			
			[[NSUserDefaults standardUserDefaults] setFloat:bestTime forKey:@"bestTime"];
			
			[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];
		bestTime = [[NSUserDefaults standardUserDefaults] floatForKey:@"bestTime"];
		
		prevGameState = MAIN_MENU;
		gameState = MAIN_MENU;

	}
	return self;
}

- (void)doPauseLogicIsPaused:(BOOL) paused {
	
	if( paused )
	{
		prevGameState = gameState;
		gameState = PAUSED;
	}
	else {
		gameState = prevGameState;
		prevGameState = PAUSED;
	}
}

- (void)update:(float)dTime {

	[backGround renderAtPoint:CGPointMake(0.0f, 0.0f) centerOfImage:FALSE];
	[moon renderAtPoint:CGPointMake(0.0f, 0.0f) centerOfImage:FALSE];

	switch (gameState) {
			
		case MAIN_MENU:
		{			
			[play renderAtPoint:CGPointMake(10.0f, 300.0f) centerOfImage:FALSE];
			[options renderAtPoint:CGPointMake(10.0f, 200.0f) centerOfImage:FALSE];
		
			if( [self doButtonLogicButtonImage:play ButtonRect:CGRectMake(10.0f, 300.0f, 128.0f + 10.0f, 64.0f + 300.0f)] )
			{
				if( masterSoundOn )
					AudioServicesPlaySystemSound(startSound);
				
				gameState = RUNNING;
			}
			if( [self doButtonLogicButtonImage:options ButtonRect:CGRectMake(10.0f, 200.0f, 128.0f + 10.0f, 64.0f + 200.0f)] )
			{
				gameState = OPTIONS;
			}
		}
			break;
			
		case OPTIONS:
		{
			[menuButton renderAtPoint:CGPointMake(230.0f, 20.0f) centerOfImage:NO];
			[soundText renderAtPoint:CGPointMake(35.0f, 370.0f) centerOfImage:NO];
			[musicText renderAtPoint:CGPointMake(35.0f, 300.0f) centerOfImage:NO];
			
			if( masterSoundOn )
			{
				[soundOnButton renderAtPoint:CGPointMake(170.0f, 370.0f) centerOfImage:NO];
				
				if( [self doButtonLogicButtonImage:soundOnButton ButtonRect:CGRectMake(170.0f, 370.0f, 170.0f + 64.0f, 370.0f + 64.0f)] )
				{
					masterSoundOn = FALSE;
				}
			}
			else
			{
				[soundOffButton renderAtPoint:CGPointMake(170.0f, 370.0f) centerOfImage:NO];
				
				if( [self doButtonLogicButtonImage:soundOffButton ButtonRect:CGRectMake(170.0f, 370.0f, 170.0f + 64.0f, 370.0f + 64.0f)] )
				{
					masterSoundOn = TRUE;
				}
			}
			
			if( masterMusicOn )
			{
				[musicOnButton renderAtPoint:CGPointMake(170.0f, 300.0f) centerOfImage:NO];
				
				if( [self doButtonLogicButtonImage:musicOnButton ButtonRect:CGRectMake(170.0f, 300.0f, 170.0f + 64.0f, 300.0f + 64.0f)] )
				{
					masterMusicOn = FALSE;
				}
			}
			else
			{
				[musicOffButton renderAtPoint:CGPointMake(170.0f, 300.0f) centerOfImage:NO];
				
				if( [self doButtonLogicButtonImage:musicOffButton ButtonRect:CGRectMake(170.0f, 300.0f, 170.0f + 64.0f, 300.0f + 64.0f)] )
				{
					masterMusicOn = TRUE;
				}
			}
			
			if( [self doButtonLogicButtonImage:menuButton ButtonRect:CGRectMake(230.0f, 20.0f, 64.0f + 250.0f, 32.0f + 20.0f)] )
			{
				gameState = MAIN_MENU;
			}
			
			[playerShip setMasterSoundOn:masterSoundOn];
		}
			break;
			
		case RUNNING:
			
			if( prevGameState == PAUSED )
				prevGameState = RUNNING;
			else
				timer += dTime;
			
			[playerShip update:dTime];
			
			[fuelBar setScaleY:[playerShip fuel]];
			[fuelBar renderAtPoint:CGPointMake(16.0f, 320.0f) centerOfImage:NO];
			[emptyFuelBar renderAtPoint:CGPointMake(15.0f, 320.0f) centerOfImage:NO];
			
			if( CGRectIntersectsRect([platform getBounds], [playerShip getBounds]) )
			{
				if( [playerShip getVelocityY] < -0.5f )
				{
					[playerShip setVelocity:CGPointMake(0.0f, 0.0f)];
					
					gameState = LOSE;
				}
				else {
					// Safe landing. Player wins
					gameState = WIN;
				}

			}
			else if( [playerShip getBounds].origin.y <= 0.0f )
			{
				gameState = LOSE;
			}
			
			[platform renderCenterOfImage:TRUE];
			
			timeString = [NSString stringWithFormat:@"%.2f", timer];
			
			[font drawStringAt:CGPointMake(230.0f, 420.0f) text:timeString];
			
			break;
			
		case PAUSED:
		{
			
		}
			break;
			
		case WIN:
		{
			if( masterSoundOn )
			{
				if( !didPlaySound )
				{
					AudioServicesPlaySystemSound(successSound);
					didPlaySound = TRUE;
				}
			}
			
			[playerShip renderCenterOfImage:YES];
			
			[fuelBar renderAtPoint:CGPointMake(16.0f, 320.0f) centerOfImage:NO];
			[emptyFuelBar renderAtPoint:CGPointMake(15.0f, 320.0f) centerOfImage:NO];
			
			[platform renderCenterOfImage:TRUE];
			
			if( bestTime == 0.0f )
			{
				bestTime = timer;
				[[NSUserDefaults standardUserDefaults] setFloat:bestTime forKey:@"bestTime"];
			}
			else if( timer < bestTime )
			{
				bestTime = timer;
				[[NSUserDefaults standardUserDefaults] setFloat:bestTime forKey:@"bestTime"];
			}
						
			[win renderAtPoint:CGPointMake(160.0f, 400.0f) centerOfImage:YES];
			
			popUpTimer += dTime;

			[self renderRetryFrame];

		}
			break;
			
		case LOSE:
		{
			
			if( masterSoundOn )
			{
				if( !didPlaySound )
				{
					AudioServicesPlaySystemSound(failureSound);
					didPlaySound = TRUE;
				}
			}

			[playerShip renderCenterOfImage:YES];
			
			[fuelBar renderAtPoint:CGPointMake(16.0f, 320.0f) centerOfImage:NO];
			[emptyFuelBar renderAtPoint:CGPointMake(15.0f, 320.0f) centerOfImage:NO];
			[platform renderCenterOfImage:TRUE];
			
			[explosion renderAtPoint:[playerShip getPosition] centerOfImage:YES];
			
			if( !didVibrate )
			{
				AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
				didVibrate = TRUE;
			}
			
			// Render the lose text "FAIL"
			[lose setColourFilterRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
			[lose renderAtPoint:CGPointMake(160.0f, 400.0f) centerOfImage:YES];
			
			popUpTimer += dTime;
			
 
			
			[self renderRetryFrame];
		}
			break;
			
		case EXIT:
			// Call the ShutDown method and clean up all allocated data
			break;
		default:
			break;
	}
	
	touchPoint = CGPointMake(0.0f, 0.0f);
}
		   
- (void)reset {
	[playerShip resetPlayer];
	CGPoint platformPos = CGPointMake(  ( arc4random() % 280 ) + 20, 15.0f);
	[platform setPosition:platformPos];
	[platform resetBounds];
	timer = 0.0f;
	popUpTimer = 0.0f;
	touchPoint = CGPointMake(0.0f, 0.0f);
	didPlaySound = FALSE;
	didVibrate = FALSE;
	fbPublished = FALSE;
}

- (void)renderRetryFrame {
	[popUpFrame renderAtPoint:CGPointMake(160.0f, 240.0f) centerOfImage:YES];
	
	timeString = [NSString stringWithFormat:@"%.2f", timer];
	bestTimeString = [NSString stringWithFormat:@"%.2f", bestTime];

	[font drawStringAt:CGPointMake(95.0f, 280.0f) text:timeString];
	[font drawStringAt:CGPointMake(210.0f, 272.0f) text:bestTimeString];

	[openFeintLogo renderAtPoint:CGPointMake(200.0f, 200.0f) centerOfImage:NO];
	[faceBookLogo renderAtPoint:CGPointMake(150.0f, 207.0f) centerOfImage:NO];
	[menuButton renderAtPoint:CGPointMake(200.0f, 135.0f) centerOfImage:NO];
	[retryButton renderAtPoint:CGPointMake(55.0f, 135.0f) centerOfImage:NO];

	
	// Limits the player from tapping any buttons for 1 second
	if( popUpTimer <= 1.0f )
		return;
	
	// Open Feint button was touched
	if( [self doButtonLogicButtonImage:openFeintLogo ButtonRect:CGRectMake(200.0f + 12.0f, 200.0f + 12.0f, 42.0f + 212.0f, 35.0f + 212.0f)] )
	{
		// Access OpenFeint code goes here
	}  
	
	// Face Book button was touched
	if( [self doButtonLogicButtonImage:faceBookLogo ButtonRect:CGRectMake(150.0f + 10.0f, 207.0f + 10.0f, 42.0f + 150.0f, 35.0f + 207.0f)] )
	{
		// Post score to face book code goes here
		[self faceBookAccess];
	}
		
	// Menu button was touched
	if( [self doButtonLogicButtonImage:menuButton ButtonRect:CGRectMake(200.0f, 135.0f, 64.0f + 200.0f, 32.0f + 135.0f)] )
	{
		[self reset];
		gameState = MAIN_MENU;
	}
	
	// Retry button was touched
	
	if( [self doButtonLogicButtonImage:retryButton ButtonRect:CGRectMake(55.0f, 135.0f, 128.0f + 55.0f, 64.0f + 135.0f)] )
	{
		[self reset];
		gameState = RUNNING;
	}
}

- (void)faceBookAccess {
	// login to face book
	if( !fbLoggedIn )
	{
		[faceBook authorize:appID permissions:fbPermissions delegate:self];
	}

	if( !fbPublished )
	{
		// Publish story to users wall
		SBJSON *jsonWriter = [[SBJSON new] autorelease];
		
		NSDictionary *actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Crash Attack", @"text", @"http://google.com", @"href", nil], nil];
		
		timeString = [NSString stringWithFormat:@"%.2f", timer];

		NSString *scoreDescription = [NSString stringWithFormat:@"I just got a time of %.2f playing this game Bassem Farah developed :)", timer];
		NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
		NSDictionary *attachment = [NSDictionary dictionaryWithObjectsAndKeys:
									@"Crash Attack", @"name",
									@"A game that you have to land a space ship safely in the fastest time posible", @"caption",
									scoreDescription, @"description",
									@"http://google.com", @"href", nil];
		NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   appID, @"api_key",
									   @"Share on Facebook", @"user_message_prompt",
									   actionLinksStr, @"action_links",
									   attachmentStr, @"attachment",
									   nil];
		
		[faceBook dialog:@"stream.publish" andParams:params andDelegate:self];
	}
	
	// TODO: logout the user when finished
}
-(void) fbDidLogin {
	fbLoggedIn = TRUE;
}

-(void) fbDidLogout {
	fbLoggedIn = FALSE;
}

- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response{
	NSLog(@"received response");
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error{

}

- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0]; 
	}
	if ([result objectForKey:@"owner"]) {

	} else {

	}
}

- (void)dialogDidComplete:(FBDialog*)dialog{
	fbPublished = TRUE;
}

- (BOOL)doButtonLogicButtonImage:(Image *)buttonImage ButtonRect:(CGRect) buttonRect {
	
	if( [self PointWithinBounds:oldTouchPoint :buttonRect] )
		[buttonImage setColourFilterRed:0.3f green:0.3f blue:0.3f alpha:1.0f];
	else 
		[buttonImage setColourFilterRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
	
	if( [self PointWithinBounds:touchPoint :buttonRect] )
	{
		[buttonImage setColourFilterRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
		return TRUE;
	}
	else
		return FALSE;
}

- (BOOL)PointWithinBounds:(CGPoint)inPoint :(CGRect)inRect {
	
	if (inPoint.x > inRect.origin.x && 
		inPoint.x < inRect.size.width &&
		inPoint.y > inRect.origin.y &&
		inPoint.y < inRect.size.height) 
	{
		return TRUE;
	}
	
	return FALSE;
}

- (void)setGameState:(unsigned int)inState {
	gameState = inState;
}

- (void)updateInputInPoint:(CGPoint) inPoint InputPressed:(BOOL) inputPressedIn InputReleased:(BOOL) inputReleasedIn {
	
	if( inputPressedIn )
	{
		oldTouchPoint = inPoint;
		[playerShip setThrustersActivated:TRUE];

	} 
	else if( inputReleasedIn )
	{
		if (touchPoint.x != oldTouchPoint.x)
		{
			touchPoint.x = oldTouchPoint.x;
			oldTouchPoint.x = 0.0f;
		}
		
		if( touchPoint.y != oldTouchPoint.y )
		{
			touchPoint.y = oldTouchPoint.y;
			oldTouchPoint.y = 0.0f;
		}
		
		[playerShip setThrustersActivated:FALSE];
	}

}

- (void)updateAccelerometer:(CGPoint) inAccel {
	[playerShip setVelocityX:inAccel.x];

}

- (void)shutdown {
	if( playerShip )
	{
		[playerShip shutdown];
		[playerShip release];
	}
	
	if( backGround )
		[backGround release];
	
	if( moon )
		[moon release];
	
	if( emptyFuelBar )
		[emptyFuelBar release];
	
	if( fuelBar )
		[fuelBar release];
	
	if( platform )
		[platform release];
	
	if( explosion )
		[explosion release];
	
	if( win )
		[win release];
	
	if( lose )
		[lose release];
	
	if( play )
		[play release];
	
	if( options )
		[options release];
	
	if( font )
		[font release];
	
	if( popUpFrame )
		[popUpFrame release];
	
	if( retryButton )
		[retryButton release];
	
	if( menuButton )
		[menuButton release];
	
	if( faceBookLogo )
		[faceBookLogo release];
	
	if( openFeintLogo )
		[openFeintLogo release];
	
	if( soundText )
		[soundText release];
	
	if( musicText )
		[musicText release];
	
	if( soundOnButton )
		[soundOnButton release];
	
	if( soundOffButton )
		[soundOffButton release];
	
	if( musicOnButton )
		[musicOnButton release];
	
	if( musicOffButton )
		[musicOffButton release];
	
	if( faceBook )
		[faceBook release];
	
}

- (void)dealloc {
	
	if( playerShip )
	{
		[playerShip shutdown];
		[playerShip release];
	}
	
	if( backGround )
		[backGround release];
	
	if( moon )
		[moon release];
	
	if( emptyFuelBar )
		[emptyFuelBar release];
	
	if( fuelBar )
		[fuelBar release];
	
	if( platform )
		[platform release];
	
	if( explosion )
		[explosion release];
	
	if( win )
		[win release];
	
	if( lose )
		[lose release];
	
	if( play )
		[play release];

	if( options )
		[options release];
	
	if( font )
		[font release];
	
	if( popUpFrame )
		[popUpFrame release];

	if( retryButton )
		[retryButton release];

	if( menuButton )
		[menuButton release];

	if( faceBookLogo )
		[faceBookLogo release];

	if( openFeintLogo )
		[openFeintLogo release];
	
	if( soundText )
		[soundText release];

	if( musicText )
		[musicText release];

	if( soundOnButton )
		[soundOnButton release];
	
	if( soundOffButton )
		[soundOffButton release];

	if( musicOnButton )
		[musicOnButton release];
	
	if( musicOffButton )
		[musicOffButton release];
	
	if( faceBook )
		[faceBook release];
	
	[super dealloc];
}

@end
