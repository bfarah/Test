//
//  BaseObject.m
//  GameName
//
//  Created by Bassem Farah on 6/06/10.
//  Copyright 2010 Bludger. All rights reserved.
//

#import "BaseObject.h"


@implementation BaseObject


- (id)init
{
	self = [super init];
	
	if( self )
	{
		objectImage = nil;
		position = CGPointMake(0.0f, 0.0f);
		velocity = CGPointMake(0.0f, 0.0f);
		windowBounds = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
	}
	
	return self;
}

- (id)initObject:(NSString *)textureName position:(CGPoint)inPosition velocity:(CGPoint)inVelocity scale:(float) scale colorFilterRed:(float) red green:(float) green blue:(float) blue alpha:(float) alpha
{
	self = [super init];
	
	if( self )
	{
		objectImage = [[Image alloc] initWithImage:[UIImage imageNamed:textureName] filter:GL_LINEAR];
		[objectImage setScale:scale];
		[objectImage setColourFilterRed:red green:green blue:blue alpha:alpha];
		
		position = inPosition;
		velocity = inVelocity;
		
		objectBounds.size.width = objectImage.imageWidth / 2;
		objectBounds.size.height = objectImage.imageHeight / 2;
		objectBounds.origin.x = position.x - objectBounds.size.width;
		objectBounds.origin.y = position.y - objectBounds.size.height;
	}
	
	return self;
}

- (void)update:(float) dTime
{
	if( position.x - objectBounds.size.width > 0.0f && position.x + objectBounds.size.width < 320 )
		position.x += velocity.x;
	else if( position.x - objectBounds.size.width <= 0.0f )
		position.x += 0.5f;
	else if( position.x + objectBounds.size.width >= 320.0f )
		position.x -= 0.5f;
	
	if( position.y - objectBounds.size.height > 0.0f && position.y + objectBounds.size.height < 480 )
		position.y += velocity.y;
	else if( position.y - objectBounds.size.height <= 0.0f )
		position.y += 0.05f;
	else if( position.y + objectBounds.size.height >= 480.0f )
		position.y -= 0.05f;
	
	objectBounds.origin = position;
}

- (void)renderCenterOfImage:(BOOL) centerOfImage
{
	[objectImage renderAtPoint:position centerOfImage:centerOfImage];
}

- (void)setPosition:(CGPoint)inPosition
{
	position = inPosition;
}

- (void)setVelocity:(CGPoint)inVelocity
{
	velocity = inVelocity;
}

- (void)setVelocity:(float) inVelocityX :(float) inVelocityY {
	velocity.x = inVelocityX;
	velocity.y = inVelocityY;
}

- (void)setVelocityX:(float) inVelocityX {
	velocity.x = inVelocityX;
}

- (void)setVelocityY:(float) inVelocityY {
	velocity.y = inVelocityY;
}

- (float)getVelocityY {
	return velocity.y;
}

- (CGPoint)getPosition {
	return position;
}

- (CGRect)getBounds {
	return objectBounds;
}

- (void)resetBounds {
	objectBounds.origin.x = position.x - objectBounds.size.width;
	objectBounds.origin.y = position.y - objectBounds.size.height;
}

- (void)shutdown {
	
	if( objectImage )
	{
		[objectImage release];
		objectImage = nil;
	}
}

- (void)dealloc {
	
	if( objectImage )
		[objectImage release];
	[super dealloc];
}
@end
