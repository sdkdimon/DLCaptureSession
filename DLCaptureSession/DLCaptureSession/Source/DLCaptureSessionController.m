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

@interface DLCaptureSessionController()
@property(assign,nonatomic,readwrite,getter=isLoaded) BOOL loaded;

@property(strong,nonatomic,readwrite) AVCaptureSession *session;
@property(strong,nonatomic,readwrite) dispatch_queue_t sessionQueue;

@end


@implementation DLCaptureSessionController


-(instancetype)init{
    self = [super init];
    if(self != nil){
        [self setup];
    }
    return self;
}

-(void)setup{
    _running = NO;
    _loaded = NO;
}

-(void)loadSessionWithCompletion:(void (^)(AVCaptureSession *))completionHandler error:(void (^)(NSError *))errorHandler{
    
    [AVCaptureDevice authorizeCameraCompletionHandler:^(BOOL granted) {
        if(granted){
            dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_queue", DISPATCH_QUEUE_SERIAL);
            
            dispatch_async(captureSessionQueue, ^{
                AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
                
                [self configurePreloadedSession:captureSession completionHandler:^{
                    [self setSession:captureSession];
                    [self setSessionQueue:captureSessionQueue];
                    dispatch_async( dispatch_get_main_queue(), ^{
                        [self setLoaded:YES];
                        completionHandler(captureSession);
                    });
                } errorHandler:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        errorHandler(error);
                    });
                    
                }];
            });
        } else{
            errorHandler(nil);
        }
    }];

    
}

-(void)startRunningCaptureSession{
    if(![self isRunning]){
        dispatch_async(_sessionQueue, ^{
            [[self session] startRunning];
        });
    }
}

-(void)stopRunningCaptureSession{
    if([self isRunning]){
        dispatch_async(_sessionQueue, ^{
            [[self session] stopRunning];
        });
    }
}


-(void)setRunning:(BOOL)running{
    running ? [self startRunningCaptureSession] : [self stopRunningCaptureSession];
    _running = running;
}

-(void)configurePreloadedSession:(AVCaptureSession *)session completionHandler:(void(^)())completionHandler errorHandler:(void (^)(NSError *))errorHandler{
    completionHandler();
}



@end
