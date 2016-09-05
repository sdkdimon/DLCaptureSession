//
// PhotoPreviewViewController.m
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

#import "PhotoPreviewViewController.h"

@interface PhotoPreviewViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation PhotoPreviewViewController



- (void)setupControls{
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_imageView setImage:_image];
    [_cancelButton addTarget:self action:@selector(cancelButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [_confirmButton addTarget:self action:@selector(confirmButtonTap) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupControls];
    // Do any additional setup after loading the view.
}

- (void)setImage:(UIImage *)image{
    _image = image;
    if(_imageView != nil){
        [_imageView setImage:image];
    }
}



- (void)cancelButtonTap{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(previewViewControllerDidCancel:)]){
        [_delegate previewViewControllerDidCancel:self];
    }
}

- (void)confirmButtonTap{
    if(_delegate != nil && [_delegate respondsToSelector:@selector(previewViewControllerDidConfirm:)]){
        [_delegate previewViewControllerDidConfirm:self];
    }
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAll;
}



@end
