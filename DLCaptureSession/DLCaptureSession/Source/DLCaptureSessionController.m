//
// DLCaptureSessionController.m
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

#import "DLCaptureSessionController.h"

#import "AVCaptureDevice+Authorization.h"
#import "AVCaptureSession+IO.h"
#import "NSError+DLCaptureSession.h"

@interface DLCaptureSessionController()

@property(assign,nonatomic,readwrite,getter=isSessionLoaded) BOOL sessionLoaded;

@property(strong,nonatomic,readwrite) AVCaptureSession *session;
@property(strong,nonatomic,readwrite) dispatch_queue_t sessionQueue;

@end


@implementation DLCaptureSessionController

- (instancetype)init{
    self = [super init];
    if(self != nil){
        [self setup];
    }
    return self;
}

- (void)setup{
    _sessionPreset = AVCaptureSessionPresetHigh;
    _sessionLoaded = NO;
}

- (void)loadSessionWithCompletion:(void (^)(AVCaptureSession *))completionHandler error:(void (^)(NSError *))errorHandler{
    [self loadSessionWithCompletion:completionHandler error:errorHandler runWhenLoaded:NO];
}

- (void)loadSessionWithCompletion:(void (^)(AVCaptureSession *))completionHandler error:(void (^)(NSError *))errorHandler runWhenLoaded:(BOOL)runWhenLoaded{
    
    [AVCaptureDevice authorizeCameraCompletionHandler:^(BOOL granted) {
        if(granted){
            dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_queue", DISPATCH_QUEUE_SERIAL);
            dispatch_async(captureSessionQueue, ^{
                AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
                [captureSession setCaptureSessionPreset:[self sessionPreset]];
                NSError *error = nil;
                [self loadInputsForSession:captureSession error:&error];
                if (error != nil){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorHandler(error);
                    });
                    return;
                }
                [self loadOutputsForSession:captureSession error:&error];
                if (error != nil){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorHandler(error);
                    });
                    return;
                }
                if(error == nil){
                    [self setSession:captureSession];
                    [self setSessionQueue:captureSessionQueue];
                    [self setSessionLoaded:YES];
                    
                    void (^completeLoadingHandler)(void) = ^{
                        completionHandler(captureSession);
                        [self sessionDidLoad];
                    };
                    
                    if (runWhenLoaded){
                        [self setSessionRunning:YES completion:completeLoadingHandler];
                        
                    } else{
                        dispatch_async(dispatch_get_main_queue(), completeLoadingHandler);
                    }

                } else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorHandler(error);
                    });
                    return;
                }
            });
        } else{
            if (errorHandler != NULL){
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorHandler([NSError errorWithType:DLCaptureSessionErrorTypeUnauthorized]);
                });
                return;
            }
        }
    }];

    
}

- (void)loadInputsForSession:(AVCaptureSession *)session error:(NSError *__autoreleasing *)error{
    
}
    

- (void)loadOutputsForSession:(AVCaptureSession *)session error:(NSError *__autoreleasing *)error{
    
}

- (void)sessionDidLoad{
    
}


- (void)startRunningCaptureSessionWithCompletion:(void (^)(void))completion{
    if(_sessionLoaded){
        dispatch_async(_sessionQueue, ^{
            [[self session] startRunning];
            if (completion != NULL){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    } else{
        if (completion != NULL){
            completion();
        }
    }
}

- (void)stopRunningCaptureSessionWithCompletion:(void (^)(void))completion{
    if(_sessionLoaded){
        dispatch_async(_sessionQueue, ^{
            [[self session] stopRunning];
            if (completion != NULL){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    } else{
        if (completion != NULL){
            completion();
        }
    }
}

- (BOOL)isSesionRunning{
    return [_session isRunning];
}

- (void)setSessionRunning:(BOOL)running completion:(void (^)(void))completion{
    if ([self isSesionRunning] != running){
        running ? [self startRunningCaptureSessionWithCompletion:completion] : [self stopRunningCaptureSessionWithCompletion:completion];
    } else{
        if (completion != NULL){
            completion();
        }
    }
    
    
    
}

#pragma mark PresetSetter

- (void)setSessionPreset:(NSString *)sessionPreset
       completionHandler:(void (^)(void))completionHandler{
    _sessionPreset = sessionPreset;
    if(_sessionLoaded){
        dispatch_async([self sessionQueue], ^{
            [[self session] setCaptureSessionPreset:sessionPreset];
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



@end
