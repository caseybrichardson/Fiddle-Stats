//
//  BlitFeedback.h
//  BlitFeedback
//
//  Created by jorge cabezas garcia on 26/04/13.
//  Copyright (c) 2013 blit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//----------------------------------
// Dependencies: AVFoundation, CoreVideo, CoreMedia, libz.dylib, MediaPlayer, QuartzCore, MessageUI, SystemConfiguration, CoreFoundation, CoreMotion
//

typedef enum                // integration type
{
    kBFFloatingButton,
    kBFShake
} BFIntegration;

@protocol BlitFeedbackDelegate <NSObject>
- (void) reportSent;
- (void) reportFailed;
- (void) reportCancelled;
@end

@interface BlitFeedback : NSObject
{
    
}

+ (BlitFeedback *) sharedInstance;

@property (nonatomic, weak) id<BlitFeedbackDelegate> delegate;

- (void) start:(NSString *)_key;
- (void) attachWithIntegrationType:(BFIntegration)_integration;
- (void) attach:(UIWindow *)_window withIntegrationType:(BFIntegration)_integration;
- (void) detach;
- (BOOL)redirectNSLog:(BOOL)_redirect;

#pragma mark custom integration methods

- (BOOL) enterFeedbackScreen;
- (BOOL) enterFeedbackScreenWithImage:(UIImage *)_image;
- (BOOL) captureScreenshot;
- (BOOL) startScreencast;
- (BOOL) stopScreencast;
- (BOOL) startLivecast;
- (BOOL) stopLivecast;

#pragma mark -

@end
