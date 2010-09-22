//
//  Player.m
//  GameName
//
//  Created by Bassem Farah on 26/08/10.
//  Copyright 2010 Bludger. All rights reserved.
//

#import "Player.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation Player

@synthesize thrustLeftPos, masterSoundOn, thrustersActivated, fuel;

- (id) init {
	
		self = [super init];
		
		if( self )
		{
			objectImage = nil;
			position = CGPointMake(0.0f, 0.0f);
			velocity = CGPointMake(0.0f, 0.0f);
			
			fuel = 18.65f;
			didVibrate = FALSE;
			
			mass = 5.0f;
			gravity = 2.0f;
			mainThrust = 15.0f;
			force = CGPointMake(0.0f, 0.0f);
			
			thrustersActivated = FALSE;
			
			[self initObject:@"Ship.png" position:CGPointMake(160.0f, 400.0f) velocity:CGPointMake(0.0f, -2.0f) scale:1.0f colorFilterRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
			
			thrustLeft = [[Image alloc] initWithImage:[UIImage imageNamed:@"ThrustLeft.png"] filter:GL_LINEAR];
			thrustLeftPos = CGPointMake(150.0f, 400.0f);
			
			thrustMiddle = [[Image alloc] initWithImage:[UIImage imageNamed:@"ThrustMiddle.png"] filter:GL_LINEAR];
			thrustMiddlePos = CGPointMake(160.0f, 400.0f);
			
			thrustRight = [[Image alloc] initWithImage:[UIImage imageNamed:@"ThrustRight.png"] filter:GL_LINEAR];	
			thrustRightPos = CGPointMake(170.0f, 400.0f);
			
			objectBounds.size.width = 38.5f;
			objectBounds.size.height = 45.0f;
						
			NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Thrust" ofType:@"caf"];
			CFURLRef soundFileURL = (CFURLRef )[NSURL fileURLWithPath:soundFilePath];
			AudioServicesCreateSystemSoundID (soundFileURL, &thrustSound );
		}
		
		return self;
}

- (void)resetPlayer {
	
	fuel = 18.65f;
	shipFall = 0.0f;
	didVibrate = FALSE;
	
	mass = 5.0f;
	gravity = 2.0f;
	mainThrust = 15.0f;
	
	thrustersActivated = FALSE;
	
	position = CGPointMake(160.0f, 400.0f);
	velocity = CGPointMake(0.0f, -2.0f);
		
	thrustLeftPos = CGPointMake(150.0f, 400.0f);
	
	thrustMiddlePos = CGPointMake(160.0f, 400.0f);
	
	thrustRightPos = CGPointMake(170.0f, 400.0f);
	
	objectBounds.size.width = 38.5f;
	objectBounds.size.height = 45.0f;
}

- (void) update:(float)dTime {
	
	position.x += velocity.x;
	position.y += velocity.y;
	rotation += velocity.x;
	
	if( position.x - objectBounds.size.width <= 0.0f )
	{
		position.x = 0.0f + objectBounds.size.width;
		velocity.x = 0.0f;
	}
	else if( position.x + objectBounds.size.width >= windowBounds.size.width )
	{
		position.x = windowBounds.size.width - objectBounds.size.width;
		velocity.x = 0.0f;
	}
	
	if( position.y + objectBounds.size.height >= windowBounds.size.height )
	{
		position.y = windowBounds.size.height - objectBounds.size.height;
		velocity.y = 0.0f;
	}
	
	[objectImage setRotation:velocity.x * 3.0f];
	
	thrustLeftPos.x = position.x - 35 - (velocity.x * 3); thrustLeftPos.y = position.y - 49 + (velocity.x * 3);
	thrustMiddlePos.x = position.x; thrustMiddlePos.y = position.y - 57;
	thrustRightPos.x = position.x + 35 - (velocity.x * 3.15f); thrustRightPos.y = position.y - 49 - (velocity.x * 3);
	
	force.x = 0.0f;
	force.y = -mass * gravity;
	
	// If the user touches the screen activate the thrusters
	// When the user takes their finger off, deactivate thrusters and let the gravity do all the pulling
	if( thrustersActivated && fuel > 0.0f)
	{
		CGPoint upVector = CGPointMake(0.0f, 1.0f);
		
		force.y = upVector.y * mainThrust;
		
		fuel -= dTime * 2.0f;
		
		if( fuel < 0.0f )
			fuel = 0.0f;
				
		if( !didVibrate )
		{
			if( masterSoundOn )
				AudioServicesPlaySystemSound(thrustSound);
			
			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
			didVibrate = TRUE;
		}
	}
	else {
		didVibrate = FALSE;
	}

	
	velocity.y += force.y / mass * dTime;
	
	objectBounds.origin.x = position.x - objectBounds.size.width;
	objectBounds.origin.y = position.y - objectBounds.size.height;
	
	// Render Player
	[objectImage renderAtPoint:position centerOfImage:YES];
	
	if( thrustersActivated && fuel > 0.0f )
		[thrustMiddle renderAtPoint:thrustMiddlePos centerOfImage:YES];
	if( velocity.x > 0.0f )
		[thrustLeft renderAtPoint:thrustLeftPos centerOfImage:YES];
	if( velocity.x < 0.0f )
		[thrustRight renderAtPoint:thrustRightPos centerOfImage:YES];
}

- (void)renderCenterOfImage:(BOOL) centerOfImage {
	[objectImage renderAtPoint:position centerOfImage:centerOfImage];

}

- (void)shutdown {
	[thrustLeft release]; //= [[Image alloc] initWithImage:[UIImage imageNamed:@"ThrustLeft.png"] filter:GL_LINEAR];
	
	[thrustMiddle release]; //= [[Image alloc] initWithImage:[UIImage imageNamed:@"ThrustMiddle.png"] filter:GL_LINEAR];
	
	[thrustRight release]; //= [[Image alloc] initWithImage:[UIImage imageNamed:@"ThrustRight.png"] filter:GL_LINEAR];
	
	[objectImage release];
}

- (void)dealloc {
	
	if( thrustLeft )
		[thrustLeft release];
	
	if( thrustRight )
		[thrustRight release];
	
	if( thrustMiddle )
		[thrustMiddle release];
	
	[super dealloc];
}

@end
