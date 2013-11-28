//
//  SPTUtils.h
//  iCATA
//
//  Created by shane on 11/27/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPTImageUtils : NSObject
+ (UIColor*) UIColorFromHexString:(NSString*) hexString;
+ (UIColor*) UIColorFromHexInt:(NSInteger)rgbValue;
+ (UIImage*) scaleImage:(UIImage*)image toScaleFactor:(float)scaleFactor;
+ (UIImage *) tintImage:(UIImage*)image withColor:(UIColor *)tintColor;
@end
