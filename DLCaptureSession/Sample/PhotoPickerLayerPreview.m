//
// PhotoPicker.m
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

#import "PhotoPickerLayerPreview.h"
#import "CameraCaptureVideoView.h"
#import "PhotoPreviewViewController.h"
#import "DLPhotoCaptureSessionController.h"
#import "UIDevice+AVCaptureVideoOrientation.h"
#import "CGSizeAspectRatioTool/CGSizeAspectRatioTool.h"

#import "DLMetadataCaptureSessionController.h"



@interface PhotoPickerLayerPreview () <PhotoPreviewViewControllerDelegate>
@property (weak, nonatomic) IBOutlet CameraCaptureVideoView *preview;
@property(strong,nonatomic,readwrite) DLPhotoCaptureSessionController *captureSession;


@end

@implementation PhotoPickerLayerPreview

- (void)viewDidLoad{
    [super viewDidLoad];
    [_preview setVideoOrientation:[[UIDevice currentDevice] videoOrientation]];
    
    NSDictionary *devOrientations = @{@(UIDeviceOrientationUnknown) : @"UIDeviceOrientationUnknown",
                                      @(UIDeviceOrientationPortrait) : @"UIDeviceOrientationPortrait",
                                      @(UIDeviceOrientationPortraitUpsideDown) : @"UIDeviceOrientationPortraitUpsideDown",
                                      @(UIDeviceOrientationLandscapeLeft) : @"UIDeviceOrientationLandscapeLeft",
                                      @(UIDeviceOrientationLandscapeRight) : @"UIDeviceOrientationLandscapeRight",
                                      @(UIDeviceOrientationFaceUp) : @"UIDeviceOrientationFaceUp",
                                      @(UIDeviceOrientationFaceDown) : @"UIDeviceOrientationFaceDown"};
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@",devOrientations[@([[UIDevice currentDevice] orientation])]);
    });
    

    
    _captureSession = [[DLPhotoCaptureSessionController alloc] init];
    [_captureSession loadSessionWithCompletion:^(AVCaptureSession *session) {
        [[[self preview] layer] setSession:session];
    } error:^(NSError *error) {
        
    } runWhenLoaded:YES];
}

- (IBAction)updateFlashState:(id)sender {
    
    AVCaptureFlashMode currentFlashMode;
    
    switch ([_captureSession flashMode]) {
        case AVCaptureFlashModeOff:
            
            currentFlashMode = AVCaptureFlashModeOn;
            break;
        case AVCaptureFlashModeOn:
            currentFlashMode = AVCaptureFlashModeOff;
            break;
            
        default:
            break;
    }
    
    [_captureSession setFlashMode:currentFlashMode successHandler:nil errorHandler:nil];
    
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    [sender setEnabled:NO];
    [_captureSession snapStillImageForOrientation:[_preview videoOrientation] completion:^(UIImage *image) {
        [sender setEnabled:YES];
        PhotoPreviewViewController *previewViewController = [[PhotoPreviewViewController alloc] initWithNibName:@"PhotoPreviewView" bundle:nil];
        [previewViewController setImage:[self cropImage:image toSize:[[self preview] bounds].size]];
        [previewViewController setDelegate:self];
        [self presentViewController:previewViewController animated:YES completion:nil];
    } error:^(NSError *error) {
        
    }];
    


}
- (IBAction)updateCamPosition:(id)sender {
    AVCaptureDevicePosition currentPosition = AVCaptureDevicePositionUnspecified;
    
    switch ([_captureSession cameraPosition]) {
        case AVCaptureDevicePositionBack:
            currentPosition = AVCaptureDevicePositionFront;
            break;
        case AVCaptureDevicePositionFront:
            currentPosition = AVCaptureDevicePositionBack;
            break;
        default:
            break;
    }
    
    [_captureSession setCameraPosition:currentPosition successHandler:^{
       
    } errorHandler:^(NSError *error) {
      
    }];
    
    
    
}

- (void)didStartCapturingStillImage{
    NSLog(@"didStartCapturingStillImage");
}

- (void)didFinishCapturingStillImage{
    NSLog(@"didFinishCapturingStillImage");
}



- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [_preview setVideoOrientation:[[UIDevice currentDevice] videoOrientation]];
}


- (void)previewViewControllerDidConfirm:(PhotoPreviewViewController *)previewViewController{
    [previewViewController dismissViewControllerAnimated:NO completion:^{
         [self dismissViewControllerAnimated:YES completion:nil];
    }];
   
}

- (void)previewViewControllerDidCancel:(PhotoPreviewViewController *)previewViewController{
   // [self startRunningCaptureSession];
    [previewViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)cropImage:(UIImage *)sourceImage toSize:(CGSize)size{
    
    CGImageRef imageRef = [sourceImage CGImage];

    
    CGFloat imageWidth = CGImageGetWidth(imageRef);
    CGFloat imageHeight = CGImageGetHeight(imageRef);
    

    
    CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
    
    CGSize newImageSize = CGSizeMakeWithAspectRatioScaledToMaxSize(size, imageSize);
    
    double x = (imageWidth - newImageSize.width) / 2.0;
    double y = (imageHeight - newImageSize.height) / 2.0;
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(imageRef, CGRectMake(x,y,newImageSize.width, newImageSize.height));
    UIImage *resultImage = [UIImage imageWithCGImage:croppedImage];
    NSLog(@"image size %@",NSStringFromCGSize([resultImage size]));
    CFRelease(croppedImage);
    return resultImage;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAll;
}


- (void)dealloc{
    
}

@end
