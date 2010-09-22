//
//  Player.h
//  GameName
//
//  Created by Bassem Farah on 26/08/10.
//  Copyright 2010 Bludger. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "BaseObject.h"
#import "Image.h"

@interface Player : BaseObject {
	
	Image *thrustLeft;
	CGPoint thrustLeftPos;
	
	Image *thrustMiddle;
	CGPoint thrustMiddlePos;
	
	Image *thrustRight;
	CGPoint thrustRightPos;
	
	BOOL thrustersActivated;
	BOOL didVibrate;

	float fuel;
	
	float mass;
	float gravity;
	CGPoint force;
	float mainThrust;
	
	
	float shipFall;
	
	float rotation;
	SystemSoundID thrustSound;
	
	BOOL masterSoundOn;

}

@property(nonatomic) CGPoint thrustLeftPos;
@property(nonatomic) BOOL masterSoundOn;
@property(nonatomic) BOOL thrustersActivated;
@property(nonatomic) float fuel;

- (id) init;
- (void) update:(float)dTime;
- (void)renderCenterOfImage:(BOOL)centerOfImage;
- (void)shutdown;

- (void)resetPlayer;
@end
