//
//  ParseHelper.h
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 1/30/15.
//  Copyright (c) 2015 com.webawesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParseHelper : NSObject

+ (NSString *)otherUserInPFObject:(PFObject *)pfObject;
+ (void)sendMahlzeitPushToUser:(NSString *)user;
+ (void)sendPhotoPushToUser:(NSString *)user;
@end
