//
// DLPhotoCaptureSessionController.m
// Copyright (c) 2015 Dmitry Lizin (sdkdimon@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DLPhotoCaptureSessionController.h"

#import "AVCaptureSession+IO.h"
#include <CGImageTools/CGImageTools.h>
#import "NSError+DLCaptureSession.h"

@interface DLPhotoCaptureSessionController () <AVCapturePhotoCaptureDelegate>

@property (strong, nonatomic, readonly) AVCapturePhotoOutput *capturePhotoOutput;
@property (strong, nonatomic, readonly) AVCaptureConnection *videoConnection;
@property (strong, nonatomic, readonly) AVCapturePhotoSettings *capturePhotoSettings;

@end

@implementation DLPhotoCaptureSessionController

- (void)setup {
    [super setup];
    self.flashMode = AVCaptureFlashModeOff;
}

- (AVCaptureConnection*)videoConnection {
    return [self.capturePhotoOutput connectionWithMediaType:AVMediaTypeVideo];
}

- (AVCapturePhotoSettings*)capturePhotoSettings {
    AVCapturePhotoSettings* capturePhotoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey : AVVideoCodecTypeJPEG}];
    if ([self.capturePhotoOutput.supportedFlashModes containsObject:@(self.flashMode)]){
        capturePhotoSettings.flashMode = self.flashMode;
    }
    return capturePhotoSettings;
}

#pragma mark Configuration

- (void)loadOutputsForSession:(AVCaptureSession *)session error:(NSError *__autoreleasing *)error{
    AVCapturePhotoOutput *capturePhotoOutput = [[AVCapturePhotoOutput alloc] init];
    if(![session addCaptureOutput:capturePhotoOutput]){
        if (error != NULL){
            *error = [NSError errorWithType:DLCaptureSessionErrorTypeSessionAddOutputDevice];
        }
        return;
    }
    self->_capturePhotoOutput = capturePhotoOutput;
}


#pragma mark StillImageSnap

- (void)capturePhotoForOrientation:(AVCaptureVideoOrientation)orientation {
    if([self isSessionLoaded] && [self isSesionRunning])  {
        dispatch_async([self sessionQueue], ^{
            self.videoConnection.videoOrientation = orientation;
            [self.capturePhotoOutput capturePhotoWithSettings:self.capturePhotoSettings
                                                     delegate:self];
        });
    }
}

#pragma mark RotationFixDegree

- (CGFloat)rotateRadiansForVideoOrientation:(AVCaptureVideoOrientation)orientation{
    
    CGFloat resultRadians = .0f;
    
    const CGFloat fromRadians =  M_PI_2;
    
    CGFloat toRadians = 0;
    switch (orientation) {
        case AVCaptureVideoOrientationLandscapeRight:
            toRadians = M_PI_2;
            break;
            
        case AVCaptureVideoOrientationPortrait:
            toRadians = 0;
            break;
            
        case AVCaptureVideoOrientationLandscapeLeft:
            toRadians = - M_PI_2;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            toRadians = M_PI;
            break;
        default:
            break;
    }
    
    resultRadians = toRadians - fromRadians;
    return resultRadians;
    
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    UIImage* image = nil;
    if (error == nil) {
        CGImageRef sourceImage = photo.CGImageRepresentation;
        CGImageRef fixRotationimage = CGImageRotateToRadians(sourceImage, [self rotateRadiansForVideoOrientation:self.videoConnection.videoOrientation]);
        CGImageRef outImage = fixRotationimage;
        if([self cameraPosition] == AVCaptureDevicePositionFront){
            CGImageFlipDirection imageFlipDirection = CGImageFlipDirectionNone;
            switch (self.videoConnection.videoOrientation) {
                case AVCaptureVideoOrientationLandscapeLeft:
                case AVCaptureVideoOrientationLandscapeRight:
                    imageFlipDirection = CGImageFlipDirectionVertical;
                    break;
                case AVCaptureVideoOrientationPortrait:
                case AVCaptureVideoOrientationPortraitUpsideDown:
                    imageFlipDirection = CGImageFlipDirectionHorizontal;
                    break;
                default:
                    NSAssert(NO, @"%s Unknown orientation",__PRETTY_FUNCTION__);
                    break;
            }
            outImage = CGImageFlip(fixRotationimage, imageFlipDirection);
            CGImageRelease(fixRotationimage);
        }
        
        image = [UIImage imageWithCGImage:outImage scale:1.0f orientation:UIImageOrientationUp];
    }
    [self.delegate photoCaptureSessionController:self didCapturePhoto:image error:error];
}

@end
