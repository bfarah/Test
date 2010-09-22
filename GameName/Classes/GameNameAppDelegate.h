//
//  GameNameAppDelegate.h
//  GameName
//
//  Created by Bassem Farah on 25/05/10.
//  Copyright Bludger 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface GameNameAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
	int currentTexture;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, assign) int currentTexture;

@end

