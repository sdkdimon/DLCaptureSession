//
// AVCaptureSession+CameraInput.m
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

#import "AVCaptureSession+CameraInput.h"
#import "AVCaptureSession+IO.h"
#import "NSError+DLCaptureSession.h"

@interface AVCaptureDevice (Preferred)

+ (AVCaptureDevice *)preferredVideoCaptureDeviceWithPosition:(AVCaptureDevicePosition)position;

@end

@implementation AVCaptureDevice (Preferred)

+ (AVCaptureDevice *)preferredVideoCaptureDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray <AVCaptureDevice *> *avaliableVideoCaptureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *captureDevice in avaliableVideoCaptureDevices){
        if ([captureDevice position] == position){
            return captureDevice;
        }
    }
    return [avaliableVideoCaptureDevices firstObject];
}

@end

@implementation AVCaptureSession (CameraInput)

- (void)removeVideoCaptureDevicesInputs{
    
    for(AVCaptureDeviceInput *inputDevice in [self inputs]){
        if([[inputDevice device] hasMediaType:AVMediaTypeVideo]){
            [self beginConfiguration];
            [self removeInput:inputDevice];
            [self commitConfiguration];
        }
    }
    
}

- (AVCaptureDeviceInput *)setCameraInputWithPosition:(AVCaptureDevicePosition)position error:(NSError *__autoreleasing *)error{
    
    AVCaptureDevice *captureVideoDevice = [AVCaptureDevice preferredVideoCaptureDeviceWithPosition:position];
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureVideoDevice error:error];
    
    if(*error != nil){
        return nil;
    }
    
    [self removeVideoCaptureDevicesInputs];
    
    if([self addCaptureInput:captureDeviceInput]){
        return captureDeviceInput;
    } else{
        if (error != NULL){
            *error = [NSError errorWithType:DLCaptureSessionErrorTypeSessionAddInputDevice];
        }
        return nil;
    }
    
}





@end
