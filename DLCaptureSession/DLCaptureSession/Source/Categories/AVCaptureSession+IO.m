//
// AVCaptureSession+IO.m
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

#import "AVCaptureSession+IO.h"

@implementation AVCaptureSession (IO)

- (BOOL)setCaptureSessionPreset:(NSString *)sessionPreset{
    BOOL canSetSessionPreset = [self canSetSessionPreset:sessionPreset];
    if (canSetSessionPreset){
        [self beginConfiguration];
        [self setSessionPreset:sessionPreset];
        [self commitConfiguration];
    }
    return canSetSessionPreset;
}

- (BOOL)addCaptureInput:(AVCaptureInput *)input{
    BOOL canAddInput = [self canAddInput:input];
    if(canAddInput){
        [self beginConfiguration];
        [self addInput:input];
        [self commitConfiguration];
    }
    return canAddInput;
}

- (BOOL)addCaptureOutput:(AVCaptureOutput *)output{
    BOOL canAddOutput = [self canAddOutput:output];
    if(canAddOutput){
        [self beginConfiguration];
        [self addOutput:output];
        [self commitConfiguration];
    }
    return canAddOutput;
}

@end
