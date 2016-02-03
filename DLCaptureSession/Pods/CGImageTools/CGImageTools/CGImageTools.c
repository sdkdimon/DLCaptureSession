//
// CGImageTools.c
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

#include "CGImageTools.h"

CGImageRef CGImageCreateWithJPEGData(CFDataRef jpegImageData){
    CGDataProviderRef imgageDataProvider = CGDataProviderCreateWithCFData(jpegImageData);
    CGImageRef imageRef = CGImageCreateWithJPEGDataProvider(imgageDataProvider, NULL, true, kCGRenderingIntentDefault);
    CFRelease(imgageDataProvider);
    return imageRef;
}

CGImageRef CGImageRotateToRadians(CGImageRef image, CGFloat radians){
    
    CGFloat imageWidth = CGImageGetWidth(image);
    CGFloat imageHeight = CGImageGetHeight(image);
    
    CGRect rotatedRect = CGRectApplyAffineTransform(CGRectMake(.0f,.0f, imageWidth, imageHeight), CGAffineTransformMakeRotation(radians));
    
    CGSize rotatedRectSize = rotatedRect.size;
    
    CGContextRef bmContext = CGBitmapContextCreate(NULL, rotatedRectSize.width,rotatedRectSize.height, CGImageGetBitsPerComponent(image), CGImageGetBytesPerRow(image), CGImageGetColorSpace(image), CGImageGetAlphaInfo(image));
    
    /// Image quality
    CGContextSetShouldAntialias(bmContext, true);
    CGContextSetAllowsAntialiasing(bmContext, true);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
   
    
    /// Rotation happen here (around the center)
    CGContextTranslateCTM(bmContext, +(rotatedRect.size.width / 2.0f), +(rotatedRect.size.height / 2.0f));
    CGContextRotateCTM(bmContext, radians);
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(bmContext, CGRectMake(-(imageWidth / 2.0f), -(imageHeight / 2.0f), imageWidth, imageHeight), image);
    
    /// Create an image object from the context
    CGImageRef resultImageRef = CGBitmapContextCreateImage(bmContext);
    CGContextRelease(bmContext);
    return resultImageRef;
}

CGImageRef CGImageFlip(CGImageRef image, CGImageFlipDirection flipDirection){
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect rect = CGRectZero;
    
    CGFloat imageWidth = CGImageGetWidth(image);
    CGFloat imageHeight = CGImageGetHeight(image);
    
    switch (flipDirection) {
        case CGImageFlipDirectionNone:
            return image;
        case CGImageFlipDirectionHorizontal:
            transform = CGAffineTransformMakeScale(- 1.0f, 1.0f);
            rect = CGRectMake(- imageWidth, .0f, imageWidth, imageHeight);
            break;
            
        case CGImageFlipDirectionVertical:
            transform = CGAffineTransformMakeScale(1.0f, - 1.0f);
            rect = CGRectMake(.0f, - imageHeight, imageWidth, imageHeight);
            break;
    }
    
     CGContextRef bmContext = CGBitmapContextCreate(NULL, imageWidth,imageHeight, CGImageGetBitsPerComponent(image), CGImageGetBytesPerRow(image), CGImageGetColorSpace(image), CGImageGetAlphaInfo(image));
    /// Image quality
    CGContextSetShouldAntialias(bmContext, true);
    CGContextSetAllowsAntialiasing(bmContext, true);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
    CGContextConcatCTM(bmContext, transform);
    CGContextDrawImage(bmContext, rect, image);
    
    CGImageRef flippedImageRef = CGBitmapContextCreateImage(bmContext);
    CGContextRelease(bmContext);
    return flippedImageRef;
}


