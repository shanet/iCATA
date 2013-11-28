//
//  SPTUtils.m
//  iCATA
//
//  Created by shane on 11/27/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTImageUtils.h"

@implementation SPTImageUtils

+ (UIColor*) UIColorFromHexString:(NSString*) hexString {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    NSUInteger hexInt;
    [scanner scanHexInt:&hexInt];
    return [SPTImageUtils UIColorFromHexInt:hexInt];
}

// http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
+ (UIColor*) UIColorFromHexInt:(NSInteger)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0
                            blue:((float)(rgbValue & 0xFF)) / 255.0
                           alpha:1.0];
}


+ (UIImage*) scaleImage:(UIImage*)image toScaleFactor:(float)scaleFactor {
    return [UIImage imageWithCGImage:image.CGImage scale:(image.scale * 1/scaleFactor) orientation:image.imageOrientation];
}

// http://stackoverflow.com/questions/3514066/how-to-tint-a-transparent-png-image-in-iphone
+ (UIImage *) tintImage:(UIImage*)image withColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions (image.size, NO, [[UIScreen mainScreen] scale]);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [image drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0f];
    
    // Tint the image (looses alpha)
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    // Mask by alpha values of original image
    [image drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

@end
