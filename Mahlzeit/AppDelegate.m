//
//  AppDelegate.m
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 6/28/14.
//  Copyright (c) 2014 com.webawesome. All rights reserved.
//

#import "AppDelegate.h"
#import "GlobalConstants.h"
#import <Parse/Parse.h>
#import "SignupViewController.h"
#import "MainViewController.h"

// Include your own ParseConstants file which stores kParseApplicationId and kParseClientKey.
// To signup on Parse and get create an account for your app, check out https://parse.com
#import "ParseConstants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:kParseApplicationId
                  clientKey:kParseClientKey];
    
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self registerForPushNotifications];
    return YES;
}

- (void)layoutApp {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    
    if ([self userHasSignedUp]) {
        MainViewController *mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        [self.window setRootViewController:mainViewController];
    } else {
        SignupViewController *signupViewController = [storyboard instantiateViewControllerWithIdentifier:@"SignupViewController"];
        [self.window setRootViewController:signupViewController];
    }
}

- (void)registerForPushNotifications {
    
    if ([[UIApplication sharedApplication] currentUserNotificationSettings] == UIUserNotificationTypeNone) {
        
        NSLog(@"Starting app without push on iOS8 because UIUserNotificationTypeNone. [[UIApplication sharedApplication] currentUserNotificationSettings] = %@", [[UIApplication sharedApplication] currentUserNotificationSettings]);
        
        [self layoutApp];
        
    } else {
        
        NSLog(@"Registering for APNS on iOS8");
        
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)registerForNotification {
    
    NSString * const NotificationCategoryIdent  = @"ACTIONABLE";
    NSString * const NotificationActionOneIdent = @"ACTION_ONE";
    NSString * const NotificationActionTwoIdent = @"ACTION_TWO";
    
    UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
    [action1 setTitle:@"Action 1"];
    [action1 setIdentifier:NotificationActionOneIdent];
    [action1 setDestructive:NO];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
    [action2 setTitle:@"Action 2"];
    [action2 setIdentifier:NotificationActionTwoIdent];
    [action2 setDestructive:NO];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:NotificationCategoryIdent];
    [actionCategory setActions:@[action1, action2]
                    forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    NSLog(@"handleActionWithIdentifier - %@", identifier);
    
    if (completionHandler) {
        
        completionHandler();
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self userHasSignedUp]) {
        NSString *userName = url.absoluteString.lastPathComponent;
        if (userName != nil && userName.length > 0) {
            self.addUserNameReceivedFromURLScheme = userName;
            [[NSNotificationCenter defaultCenter] postNotificationName:APPLICATION_WILL_ENTER_FOREGROUND object:nil];
        }
    }
    return TRUE;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken - %@", deviceToken);
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    [self layoutApp];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_MESSAGE object:userInfo];
    //[PFPush handlePush:userInfo]; // Not using Parse's notification system since we are managing our own views to imitate notification
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APPLICATION_WILL_ENTER_FOREGROUND object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)userHasSignedUp {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USERNAME]) {
        return YES;
    } else {
        return NO;
    }
}

@end
