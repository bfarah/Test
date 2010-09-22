//
//  BaseObject.h
//  GameName
//
//  Created by Bassem Farah on 6/06/10.
//  Copyright 2010 Bludger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Image.h"

@interface BaseObject : NSObject {

	CGRect windowBounds;
	Image *objectImage;
	CGPoint position;
	CGPoint velocity;
	CGRect objectBounds;
}

- (id)initObject:(NSString *)textureName position:(CGPoint)position velocity:(CGPoint)velocity scale:(float) scale colorFilterRed:(float) red green:(float) green blue:(float) blue alpha:(float) alpha;
- (void)renderCenterOfImage:(BOOL) centerOfImage;
- (void)setPosition:(CGPoint) inPosition;
- (void)setVelocity:(CGPoint) inVelocity;
- (void)setVelocity:(float) inVelocityX :(float) inVelocityY;
- (void)setVelocityX:(float) inVelocityX;
- (void)setVelocityY:(float) inVelocityY;
- (void)resetBounds;
- (void)shutdown;

- (float)getVelocityY;
- (CGPoint)getPosition;
- (CGRect)getBounds;

- (void)update:(float)dTime;
@end
