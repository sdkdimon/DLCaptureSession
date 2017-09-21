//
// DLQRCodeCaptureSessionController.m
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

#import "DLMetadataCaptureSessionController.h"
#import "AVCaptureSession+IO.h"
#import "AVCaptureSession+CameraInput.h"
#import "AVCaptureDevice+FlashMode.h"
#import "NSError+DLCaptureSession.h"
#import <UIKit/UIDevice.h>

#define MEDIA_TYPE_METADATA (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) ? AVMediaTypeMetadataObject : AVMediaTypeMetadata)

@interface DLMetadataCaptureSessionController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic, readwrite) AVCaptureOutput *outputDevice;

@end

@implementation DLMetadataCaptureSessionController

- (void)setup
{
    [super setup];
    _captureEnabled = YES;
}

- (void)loadOutputsForSession:(AVCaptureSession *)session error:(NSError *__autoreleasing *)error
{
    AVCaptureMetadataOutput *metadataOuput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOuput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if (![session addCaptureOutput:metadataOuput])
    {
        if (error != NULL)
        {
            *error = [NSError errorWithType:DLCaptureSessionErrorTypeSessionAddOutputDevice];
        }
        return;
    }
    
    NSArray <NSString *> *availableMetadataObjectTypes = metadataOuput.availableMetadataObjectTypes;
    for (NSString *metadataObjectType in _metadataObjectTypes)
    {
        if (![availableMetadataObjectTypes containsObject:metadataObjectType])
        {
            *error = [NSError errorWithType:DLCaptureSessionErrorTypeDeviceUnsupportedMetadataObjectType];
            return;
        }
    }
    
    [metadataOuput setMetadataObjectTypes:_metadataObjectTypes];
    [self setOutputDevice:metadataOuput];
}

- (AVCaptureConnection *)metadataConnection
{
    return [_outputDevice connectionWithMediaType:MEDIA_TYPE_METADATA];
}

- (void)sessionDidLoad
{
    [super sessionDidLoad];
    AVCaptureConnection *metadataCaptureConnection = [self metadataConnection];
    [metadataCaptureConnection setEnabled:_captureEnabled];
}

- (void)setCaptureEnabled:(BOOL)captureEnabled
{
    _captureEnabled = captureEnabled;
    if ([self isSessionLoaded]){
        AVCaptureConnection *metadataCaptureConnection = [self metadataConnection];
        [metadataCaptureConnection setEnabled:captureEnabled];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (_delegate != nil && [_delegate conformsToProtocol:@protocol(DLMetadataCaptureSessionControllerDelegate)])
    {
        [_delegate metadataCaptureSessionController:self didReceiveMetadataObjects:metadataObjects];
    }
}

@end
