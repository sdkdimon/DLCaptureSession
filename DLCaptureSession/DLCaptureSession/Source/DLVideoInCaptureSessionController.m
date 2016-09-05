//
// DLVideoInCaptureSessionController.m
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

#import "DLVideoInCaptureSessionController.h"
#import "AVCaptureSession+IO.h"
#import "AVCaptureSession+CameraInput.h"
#import "AVCaptureDevice+FlashMode.h"

@interface DLVideoInCaptureSessionController ()

@property(strong,nonatomic,readwrite) AVCaptureDeviceInput *captureDeviceInput;

@end

@implementation DLVideoInCaptureSessionController

- (void)setup{
    [super setup];
    _cameraPosition = AVCaptureDevicePositionBack;
    
}

- (void)loadInputsForSession:(AVCaptureSession *)session error:(NSError *__autoreleasing *)error{
   AVCaptureDeviceInput *cameraDeviceInput = [session setCameraInputWithPosition:_cameraPosition error:error];
    if(*error != nil){
        return;
    }
    [[cameraDeviceInput device] setFlashMode:_flashMode error:nil];
    [self setCaptureDeviceInput:cameraDeviceInput];
}


#pragma mark CameraPositionSetter

- (void)setCameraPosition:(AVCaptureDevicePosition)cameraPosition
           successHandler:(void (^)())successHandler
             errorHandler:(void (^)(NSError *))errorHandler{
    _cameraPosition = cameraPosition;
    if([self isSessionLoaded]){
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

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
      successHandler:(void (^)())successHandler
        errorHandler:(void (^)(NSError *))errorHandler{
    _flashMode = flashMode;
    if([self isSessionLoaded]){
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

@end
