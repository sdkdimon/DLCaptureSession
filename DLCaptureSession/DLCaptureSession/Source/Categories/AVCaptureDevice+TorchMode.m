//
//  AVCaptureDevice+TorchMode.m
//  DLCaptureSession
//
//  Created by Ivan on 10/05/2019.
//  Copyright © 2019 Dmitry Lizin. All rights reserved.
//

#import "AVCaptureDevice+TorchMode.h"
#import "NSError+DLCaptureSession.h"

@implementation AVCaptureDevice (TorchMode)

- (void)setTorchMode:(AVCaptureTorchMode)torchMode error:(NSError *__autoreleasing *)error{
    if([self hasTorch] && [self isTorchModeSupported:torchMode]) {
        if([self lockForConfiguration:error]) {
            [self setTorchMode:torchMode];
            [self unlockForConfiguration];
        }
    }else{
        if(error != NULL){
            *error = [NSError errorWithType:DLCaptureSessionErrorTypeDeviceNoTorch];
        }
    }
}

@end
