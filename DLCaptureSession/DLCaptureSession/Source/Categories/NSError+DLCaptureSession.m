//
// NSError+DLCaptureSession.m
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

#import "NSError+DLCaptureSession.h"

NSString * const ERROR_DOMAIN = @"org.sdkdimon.dlcapturesession";

@implementation NSError (DLCaptureSession)

+ (NSError *)errorWithType:(DLCaptureSessionErrorType)errorType
{
    return [[NSError alloc] initWithDomain:ERROR_DOMAIN code:errorType userInfo:[[self userInfoMap] objectForKey:@(errorType)]];
}


+ (NSDictionary <NSNumber *, NSDictionary <NSString *, NSString *> *> *)userInfoMap
{
    return @{@(DLCaptureSessionErrorTypeUnauthorized) : @{NSLocalizedDescriptionKey : @"Device unautorized"},
             @(DLCaptureSessionErrorTypeSessionAddInputDevice) : @{NSLocalizedDescriptionKey : @"Can't add input device"},
             @(DLCaptureSessionErrorTypeSessionAddOutputDevice) : @{NSLocalizedDescriptionKey : @"Can't add output device"},
             @(DLCaptureSessionErrorTypeDeviceNoFlashLight) : @{NSLocalizedDescriptionKey : @"Device has no flashlight"},
             @(DLCaptureSessionErrorTypeDeviceNoTorch) : @{NSLocalizedDescriptionKey : @"Device has no torch"},
             @(DLCaptureSessionErrorTypeDeviceUnsupportedMetadataObjectType) : @{NSLocalizedDescriptionKey : @"Used metadata object type unsupported"}
             };
}

@end
