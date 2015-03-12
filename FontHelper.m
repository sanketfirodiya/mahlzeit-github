//
//  FontHelper.m
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 7/19/14.
//  Copyright (c) 2014 com.webawesome. All rights reserved.
//

#import "FontHelper.h"

@implementation FontHelper

+ (UIFont *)getCustomFontWithSize:(int)size bold:(BOOL)isBold {
    if (isBold) {
            return [UIFont fontWithName:@"Montserrat-Bold" size:size];
    } else {
         return [UIFont fontWithName:@"Montserrat-Regular" size:size];
    }
}

@end
