//
//  ParseHelper.m
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 1/30/15.
//  Copyright (c) 2015 com.webawesome. All rights reserved.
//

#import "ParseHelper.h"
#import "GlobalConstants.h"

@implementation ParseHelper

#pragma mark - PFObject Helper methods

+ (id)userIpse {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
}

+ (NSString *)otherUserInPFObject:(PFObject *)pfObject {
    NSString *fromUser = [pfObject objectForKey:FROMUSER];
    NSString *toUser = [pfObject objectForKey:TOUSER];
    if ([fromUser isEqualToString:[self userIpse]]) {
        return toUser;
    } else if ([toUser isEqualToString:[self userIpse]]) {
        return fromUser;
    }
    return nil;
}

+ (void)sendMahlzeitPushToUser:(NSString *)user {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"USERNAME == %@", user];
    PFQuery *pushQuery = [PFQuery queryWithClassName:USER predicate:predicate];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    NSString *message = [NSString stringWithFormat:@"From %@", [self userIpse]];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"alert",
                          @"Increment", @"badge",
                          @"Mahlzeit.wav", @"sound",
                          nil];
    [push setData:data];
    [push sendPushInBackground];
}

+ (void)sendPhotoPushToUser:(NSString *)user {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"USERNAME == %@", user];
    PFQuery *pushQuery = [PFQuery queryWithClassName:USER predicate:predicate];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    NSString *message = [NSString stringWithFormat:@"%@ shared a photo", [self userIpse]];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"alert",
                          @"Increment", @"badge",
                          @"Mahlzeit.wav", @"sound",
                          nil];
    [push setData:data];
    [push sendPushInBackground];
}

@end
