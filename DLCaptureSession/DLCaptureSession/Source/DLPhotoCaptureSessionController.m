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
#import "AVCaptureDevice+Preferred.h"
#import "AVCaptureSession+IO.h"
#import "AVCaptureSession+CameraInput.h"
#import "AVCaptureDevice+FlashMode.h"

#include <CGImageTools/CGImageTools.h>

@interface DLPhotoCaptureSessionController ()
@property(strong,nonatomic,readwrite) AVCaptureStillImageOutput *stillCaptureImageOutput;
@property(strong,nonatomic,readwrite) AVCaptureDeviceInput *captureDeviceInput;

@end

@implementation DLPhotoCaptureSessionController

-(void)setup{
    [super setup];
    _cameraPosition = AVCaptureDevicePositionBack;
    _sessionPreset = AVCaptureSessionPresetHigh;
    _flashMode = AVCaptureFlashModeOff;
}



#pragma mark Configuration

-(void)configurePreloadedSession:(AVCaptureSession *)session error:(NSError *__autoreleasing *)error{
    
    AVCaptureDeviceInput *cameraDeviceInput = [session setCameraInputWithPosition:_cameraPosition error:error];
    if(*error != nil){
        return;
    }
    [[cameraDeviceInput device] setFlashMode:_flashMode error:nil];

    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
    if(![session addCaptureOutput:stillImageOutput]){
        *error = [[NSError alloc] initWithDomain:@"org.dlcamerasession" code:-2 userInfo:@{NSLocalizedDescriptionKey : @"CanAddCaptureDeviceOutput"}];
        return;
    }
    [session setupSessionPreset:_sessionPreset];
    [self setCaptureDeviceInput:cameraDeviceInput];
    [self setStillCaptureImageOutput:stillImageOutput];

}


#pragma mark StillImageSnap

-(void)snapStillImageForOrientation:(AVCaptureVideoOrientation)orientation completion:(void (^)(UIImage *))completionHandler error:(void (^)(NSError *))errorHandler{
    if([self isLoaded] && [self isRunning])  {
        dispatch_async([self sessionQueue], ^{
            AVCaptureStillImageOutput *stillCaptureImageOutput = [self stillCaptureImageOutput];
            AVCaptureConnection *connection = [stillCaptureImageOutput connectionWithMediaType:AVMediaTypeVideo];
            [stillCaptureImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^( CMSampleBufferRef imageDataSampleBuffer, NSError *error ) {
                if (imageDataSampleBuffer != nil) {
                    // The sample buffer is not retained. Create image data before saving the still image.
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    
                    CGImageRef sourceImage = CGImageCreateWithJPEGData((__bridge CFDataRef)imageData);
                    //Rotate image
                    CGImageRef fixRotationimage = CGImageRotateToRadians(sourceImage, [self rotateRadiansForVideoOrientation:orientation]);
                    CGImageRef outImage = fixRotationimage;
                    if([self cameraPosition] == AVCaptureDevicePositionFront){
                        CGImageFlipDirection imageFlipDirection = CGImageFlipDirectionNone;
                        switch (orientation) {
                            case AVCaptureVideoOrientationLandscapeLeft:
                            case AVCaptureVideoOrientationLandscapeRight:
                                imageFlipDirection = CGImageFlipDirectionVertical;
                                break;
                            case AVCaptureVideoOrientationPortrait:
                            case AVCaptureVideoOrientationPortraitUpsideDown:
                                imageFlipDirection = CGImageFlipDirectionHorizontal;
                                break;
                            default:
                                [NSException raise:NSInvalidArgumentException format:@"%s Unknown orientation",__PRETTY_FUNCTION__];
                                break;
                        }
                        outImage = CGImageFlip(fixRotationimage, imageFlipDirection);
                        CGImageRelease(fixRotationimage);
                    }
                    
                    
                    UIImage *image = [UIImage imageWithCGImage:outImage scale:1.0f orientation:UIImageOrientationUp];
                    CGImageRelease(sourceImage);
                    CGImageRelease(outImage);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(image);
                    });
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorHandler(error);
                    });
                }
            }];
        } );
    }
}



#pragma mark CameraPositionSetter

-(void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition
          successHandler:(void (^)())successHandler
            errorHandler:(void (^)(NSError *))errorHandler{
    _cameraPosition = cameraPosition;
    if([self isLoaded]){
        dispatch_async([self sessionQueue], ^{
            NSError *error = nil;
            AVCaptureDeviceInput *cameraDeviceInput = [[self session] setCameraInputWithPosition:cameraPosition error:&error];
            if(error == nil){
                [self setCaptureDeviceInput:cameraDeviceInput];
                [[cameraDeviceInput device] setFlashMode:[self flashMode] error:nil];
                if(successHandler != NULL){
                    successHandler();
                }
            } else{
                if(errorHandler != NULL){
                    errorHandler(error);
                }
            }
        });
        
    } else{
        if(successHandler != NULL){
            successHandler();
        }
    }
    
}



#pragma mark FlashModeSetter

-(void)setFlashMode:(AVCaptureFlashMode)flashMode
     successHandler:(void (^)())successHandler
       errorHandler:(void (^)(NSError *))errorHandler{
    _flashMode = flashMode;
    if([self isLoaded]){
        dispatch_async([self sessionQueue], ^{
            AVCaptureDeviceInput *captureDeviceInput = [self captureDeviceInput];
            NSError *error = nil;
            [[captureDeviceInput device] setFlashMode:flashMode error:&error];
            if(error == nil){
                if(successHandler != NULL){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successHandler();
                    });
                }
            } else{
                if(errorHandler != NULL){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorHandler(error);
                    });
                }
            }
        });
    }else{
        if(successHandler != NULL){
            successHandler();
        }
    }
}



#pragma mark PresetSetter

-(void)setSessionPreset:(NSString *)sessionPreset
      completionHandler:(void (^)())completionHandler{
    
    _sessionPreset = sessionPreset;
    if([self isLoaded]){
        dispatch_async([self sessionQueue], ^{
            [[self session] setupSessionPreset:sessionPreset];
            if(completionHandler != NULL){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler();
                });
            }
        });
    } else{
        if(completionHandler != NULL){
            completionHandler();
        }
    }
}




#pragma mark RotationFixDegree

-(CGFloat)rotateRadiansForVideoOrientation:(AVCaptureVideoOrientation)orientation{
    
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



@end
