//
// QRCodeCaptureViewController.m
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

#import "QRCodeCaptureViewController.h"
#import "DLQRCodeCaptureSessionController.h"
#import "CameraCaptureVideoView.h"

@interface QRCodeCaptureViewController()

@property (strong, nonatomic, readwrite) DLQRCodeCaptureSessionController *captureSession;
@property (weak, nonatomic) IBOutlet CameraCaptureVideoView *previewView;

@end

@implementation QRCodeCaptureViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    _captureSession = [[DLQRCodeCaptureSessionController alloc] init];
    [_captureSession setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    [_captureSession loadSessionWithCompletion:^(AVCaptureSession *session) {
        [[[self previewView] layer] setSession:session];
        [[self captureSession] setRunning:YES];
    } error:^(NSError *error) {
        
    }];
    
    [_captureSession setOutputMetadataBlock:^(NSArray<AVMetadataObject *> *metadataObjects, BOOL *stopScanning) {
        
        for (AVMetadataObject *metadataObject in metadataObjects){
            if ([[metadataObject type]isEqualToString:AVMetadataObjectTypeQRCode] && [metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
                AVMetadataMachineReadableCodeObject *readableMetadata = (AVMetadataMachineReadableCodeObject *)metadataObject;
                NSLog(@"%@",[readableMetadata stringValue]);
                *stopScanning = YES;
            }
        }
        
    }];
    

}

@end
