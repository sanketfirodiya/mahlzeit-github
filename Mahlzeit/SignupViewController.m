//
//  SignupViewController.m
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 6/28/14.
//  Copyright (c) 2014 com.webawesome. All rights reserved.
//

#import "SignupViewController.h"
#import "GlobalConstants.h"
#import <Parse/Parse.h>
#import "FontHelper.h"

@interface SignupViewController ()

@end

@implementation SignupViewController {
    NSString *username;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.uiUSERNAMETextField becomeFirstResponder];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User signup methods

- (IBAction)goTapped:(id)sender {
    username = self.uiUSERNAMETextField.text;
    if (username.length == 0) {
        [self showAlertView:@"Choose Username" withMessage:nil];
        return;
    } else if (username.length > 20) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"That's very long for username" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    UIActivityIndicatorView *uiSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    uiSpinner.frame = CGRectMake(135.0, 12.0, 50.0, 50.0);
    uiSpinner.tag = 10;
    [uiSpinner startAnimating];
    [self.uiGOButton setTitle:@"" forState:UIControlStateNormal];
    [self.uiGOButton addSubview:uiSpinner];
    
    username = [username uppercaseString];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"USERNAME == %@", username];
    PFQuery *pfQuery = [PFQuery queryWithClassName:USER predicate:predicate];
    [pfQuery findObjectsInBackgroundWithTarget:self selector:@selector(usernameCheckComplete:error:)];
}

- (void)usernameCheckComplete:(NSArray *)array error:(NSError *)error {
    
    // username specified by user is available, sign up the user with this username
    if (array.count == 0 || array == nil) {
        NSString *deviceToken = [NSString stringWithFormat:@"%@", [[PFInstallation currentInstallation] deviceToken]];
        NSDictionary *signupDictionary = [NSDictionary dictionaryWithObjectsAndKeys:deviceToken, DEVICETOKEN, username, USERNAME, nil];
        
        PFObject *pfObject = [PFObject objectWithClassName:USER dictionary:signupDictionary];
        [pfObject saveInBackgroundWithTarget:self selector:@selector(storeUserOnDeviceAfterSuccessfulSignup)];
        
    } else {
        PFObject *pfObject = [array objectAtIndex:0];
        NSLog(@"pfObject = %@", pfObject);
        
        for (UIView *subView in self.uiGOButton.subviews) {
            if (subView.tag == 10) {
                [subView removeFromSuperview];
            }
        }
        [self.uiGOButton setTitle:@"GO" forState:UIControlStateNormal];
        [self showAlertView:@"Username taken" withMessage:@"Please choose another one"];
    }
}

- (void)storeUserOnDeviceAfterSuccessfulSignup {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERNAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // required for push. ensures relation between installation and user object
    [[PFInstallation currentInstallation] setObject:username forKey:USERNAME];
    [[PFInstallation currentInstallation] saveInBackground];
    
    [self performSegueWithIdentifier:@"pushMainViewController" sender:self];
}

- (void)showAlertView:(NSString *)alertTitle withMessage:(NSString*)alertMessage {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
}

@end
