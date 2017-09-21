//
// DLCaptureSessionController.h
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVCaptureSession.h>

@interface DLCaptureSessionController : NSObject

@property(strong,nonatomic,readonly) AVCaptureSession *session;
@property(strong,nonatomic,readonly) dispatch_queue_t sessionQueue;

@property(assign,nonatomic,readonly,getter=isSessionLoaded) BOOL sessionLoaded;

- (BOOL)isSesionRunning;
- (void)setSessionRunning:(BOOL)running completion:(void(^)(void))completion;

- (void)setup;

- (void)loadSessionWithCompletion:(void(^)(AVCaptureSession *session))completionHandler error:(void(^)(NSError *error))errorHandler;
- (void)loadSessionWithCompletion:(void(^)(AVCaptureSession *session))completionHandler error:(void(^)(NSError *error))errorHandler runWhenLoaded:(BOOL)runWhenLoaded;

- (void)loadInputsForSession:(AVCaptureSession *)session error:(NSError **)error;
- (void)loadOutputsForSession:(AVCaptureSession *)session error:(NSError **)error;

- (void)sessionDidLoad;

@property(strong,nonatomic,readonly) NSString *sessionPreset;
- (void)setSessionPreset:(NSString *)sessionPreset
       completionHandler:(void (^)(void))completionHandler;


@end
