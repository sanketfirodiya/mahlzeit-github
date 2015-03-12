//
//  MainViewController.m
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 6/28/14.
//  Copyright (c) 2014 com.webawesome. All rights reserved.
//

#import "MainViewController.h"
#import "GlobalConstants.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "NSMutableArray+Mahlzeit.h"
#import <AudioToolbox/AudioToolbox.h>
#import "FontHelper.h"
#import "ParseHelper.h"

@interface MainViewController ()
@property (nonatomic) SystemSoundID soundId;

@end

@implementation MainViewController {
    NSMutableArray *arTableViewDataSource;
    NSMutableArray *arTableViewBackgroundColors;
    NSString *usernameBeingSearched;
    NSString *sendingMessageToUser;
    NSIndexPath *sendingMessageToUserIndexPath;
    BOOL initialState;
    MBProgressHUD *HUD;
    PFFile *imageFile;
    NSIndexPath *indexPathForPhoto;
    UIView *overlayView;
    UIView *sharedPhotoView;
    UIImageView *sharedPhotoImageView;
    UIImage *noSharedImage;
}

#pragma mark - Helper methods

- (void)populateTableViewBackgroundColors {
    [arTableViewBackgroundColors addObject:COLOR_BLUE1];
    [arTableViewBackgroundColors addObject:COLOR_WHATSAPP];
    [arTableViewBackgroundColors addObject:COLOR_FACEBOOK];
    [arTableViewBackgroundColors addObject:COLOR_BLUESEA];
    [arTableViewBackgroundColors addObject:COLOR_PURPLE1];
    [arTableViewBackgroundColors addObject:COLOR_PINK1];
    [arTableViewBackgroundColors addObject:COLOR_BLUE2];
}

- (id)userIpse {
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
}

- (NSInteger)indexOfLastRow {
    return [self.uiTableView numberOfRowsInSection:0] - 1;
}

- (NSIndexPath *)indexPathOfLastRow {
    return [NSIndexPath indexPathForRow:self.indexOfLastRow inSection:0];
}

- (SystemSoundID)soundId {
    if (!_soundId) {
        NSString *path = [NSString stringWithFormat: @"%@/%@",
                          [[NSBundle mainBundle] resourcePath], @"Mahlzeit.wav"];
        
        
        NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &_soundId);
        return _soundId;
    } else {
        return _soundId;
    }
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    arTableViewDataSource = [[NSMutableArray alloc] init];
    arTableViewBackgroundColors = [[NSMutableArray alloc] init];
    sharedPhotoView = [[UIView alloc] initWithFrame:self.view.frame];
    sharedPhotoView.backgroundColor = [UIColor yellowColor];
    sharedPhotoImageView = [[UIImageView alloc] init];
    [sharedPhotoView addSubview:sharedPhotoImageView];
    noSharedImage = [UIImage imageNamed:@"NO_PIC_SHARED"];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UITextField appearance] setTintColor:[UIColor colorWithRed:0.000 green:0.478 blue:1.000 alpha:1.000]];
    }
    
    // fetch data
    [self populateTableViewBackgroundColors];
    [self refreshDataOnScreen];
    
    // fetch new data everytime app comes to foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataOnScreen) name:APPLICATION_WILL_ENTER_FOREGROUND object:nil];
    
    // show fake push banner when app receives notification in foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotificationInApp:) name:NEW_MESSAGE object:nil];
}

- (void)setInitialState {
    if (arTableViewDataSource.count == 0) {
        initialState = YES;
        [self.uiTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arTableViewDataSource.count > 0) {
        return arTableViewDataSource.count + 1;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (arTableViewDataSource.count > 0 || indexPath.row == 1) {
        return 75.0;
    } else {
        return 200.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row < self.indexOfLastRow) {
        if (arTableViewDataSource.count > 0) {
            PFObject *pfObject = (PFObject *)[arTableViewDataSource objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            cell.backgroundColor = [arTableViewBackgroundColors objectAtIndex:(indexPath.row % arTableViewBackgroundColors.count)];
            UILabel *label = (UILabel *)[cell viewWithTag:4];
            label.font = [FontHelper getCustomFontWithSize:28 bold:NO];
            if ([indexPath isEqual:sendingMessageToUserIndexPath]) {
                label.text = @"MAHLZEIT";
            } else {
                label.text = [ParseHelper otherUserInPFObject:pfObject];
                
                UIView *cameraButtonView = (UIView *)[cell viewWithTag:2];
                UILongPressGestureRecognizer *longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cameraButtonLongTapped:)];
                [longTapGesture setMinimumPressDuration:0.1];
                [longTapGesture setDelegate:self];
                [cameraButtonView addGestureRecognizer:longTapGesture];
                
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraButtonTapped:)];
                [tapGesture setDelegate:self];
                [cameraButtonView addGestureRecognizer:tapGesture];
                
                if ([[pfObject objectForKey:UNREAD]  isEqual: @YES]) {
                    if (![[pfObject objectForKey:FROMUSER] isEqualToString:[self userIpse]] && cell.tag == 0) {
                        cell.tag = 1;
                        [self indicateNewImage:cell];
                    }
                }
            }
        } else {
            if (initialState) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"InitialCell"];
                UILabel *label = (UILabel *)[cell viewWithTag:1];
                label.font = [FontHelper getCustomFontWithSize:48 bold:YES];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
                UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:1];
                [spinner startAnimating];
            }
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
    }
    
    return cell;
}

- (void)overlayTapped:(UISwipeGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.view];
    if (CGRectContainsPoint(CGRectMake(95.0, 120.0, 120.0, 30.0), location)) {
        [overlayView removeFromSuperview];
    } else {
        //NSLog(@"tapped outside dismiss");
    }
}

- (void)displayHelpOverlay {
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 20.0, 250.0, 150.0)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Help_Overlay"]];
    [overlayView addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    overlayView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureOnOverlay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTapped:)];
    [tapGestureOnOverlay setDelegate:self];
    [overlayView addGestureRecognizer:tapGestureOnOverlay];
    [self.view addSubview:overlayView];
}

- (void)indicateNewImage:(UITableViewCell *)cell {
    if (cell.tag == 1) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:HELP_OVERLAY_SHOWN_RECEIVE_PHOTO] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:HELP_OVERLAY_SHOWN_RECEIVE_PHOTO];
            [self displayHelpOverlay];
        }
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
        UIImage * image2 = [UIImage imageNamed:@"photo-32_filled"];
        UIImage * image1 = [UIImage imageNamed:@"photo-32"];
        
        [UIView transitionWithView:imageView
                          duration:0.6f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            imageView.image = image2;
                        } completion:^(BOOL finished) {
                            [UIView transitionWithView:imageView
                                              duration:0.6f
                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                            animations:^{
                                                imageView.image = image1;
                                            } completion:^(BOOL finished){
                                                [self indicateNewImage:cell];
                                            }];
                        }];
    }
}

- (void)cameraButtonTapped:(UISwipeGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.uiTableView];
    indexPathForPhoto = [self.uiTableView indexPathForRowAtPoint:location];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing Photo", nil];
    actionSheet.tag = 103;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if (buttonIndex == 1) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)cameraButtonLongTapped:(UISwipeGestureRecognizer *)gesture {
    
    if (UIGestureRecognizerStateBegan == gesture.state) {
        
        CGPoint location = [gesture locationInView:self.uiTableView];
        NSIndexPath *indexPath = [self.uiTableView indexPathForRowAtPoint:location];
        
        UITableViewCell *cell = [self.uiTableView cellForRowAtIndexPath:indexPath];
        cell.tag = 0;
        
        PFObject *pfObjectExisting = (PFObject *)[arTableViewDataSource objectAtIndex:indexPath.row];
        PFFile *pfFile = (PFFile *)[pfObjectExisting objectForKey:PHOTO];
        
        if (pfFile) {
            NSData *imageData = [pfFile getData];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
                //NSLog(@"sharedImageView = %f, sharedImageView = %f", sharedPhotoImageView.frame.size.width, sharedPhotoImageView.frame.size.height);
                //NSLog(@"image.width = %f, image.height = %f", image.size.width, image.size.height);
                CGRect frame = sharedPhotoImageView.frame;
                if (image.size.height > image.size.width) {
                    frame.size.height = 568.0;
                    frame.size.width = frame.size.height/image.size.height * image.size.width;
                } else {
                    frame.size.width = 320.0;
                    frame.size.height = frame.size.width/image.size.width * image.size.height;
                }
                sharedPhotoImageView.frame = frame;
                //NSLog(@"sharedImageView = %f, sharedImageView = %f", sharedPhotoImageView.frame.size.width, sharedPhotoImageView.frame.size.height);
                sharedPhotoImageView.image = image;
            } else {
                CGRect frame = sharedPhotoImageView.frame;
                frame.size.width = 320.0;
                frame.size.height = 568.0;
                sharedPhotoImageView.frame = frame;
                sharedPhotoImageView.image = noSharedImage;
            }
            [self.view addSubview:sharedPhotoView];
            [pfObjectExisting setObject:@NO forKey:UNREAD];
            [pfObjectExisting saveInBackground];
        } else {
            CGRect frame = sharedPhotoImageView.frame;
            frame.size.width = 320.0;
            frame.size.height = 568.0;
            sharedPhotoImageView.frame = frame;
            sharedPhotoImageView.image = noSharedImage;
            [self.view addSubview:sharedPhotoView];
        }
    } else if (UIGestureRecognizerStateEnded == gesture.state) {
        [sharedPhotoView removeFromSuperview];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (arTableViewDataSource.count == 0 || indexPath.row == self.indexOfLastRow)  {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add friend" message:@"Type in a username" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        alertView.tag = 101;
        [alertView show];
    }
    
    else if (indexPath.row < self.indexOfLastRow) {
        
        if (sendingMessageToUserIndexPath == nil) {
            
            // animate cell
            sendingMessageToUserIndexPath = indexPath;
            [self animateCell:indexPath];
            
            // Network activity
            PFObject *pfObject = (PFObject *)[arTableViewDataSource objectAtIndex:indexPath.row];
            NSString *username = [ParseHelper otherUserInPFObject:pfObject];
            [self checkForExistingMessageToUser:username];
            
        } else {
            //NSLog(@"Wait for earlier animation to finish");
        }
        
    }
}

#pragma mark - Table cell animation when sending message

// STEP 1: Change cell text to Mahlzeit
- (void)animateCell:(NSIndexPath *)indexPath {
    
    sendingMessageToUserIndexPath = indexPath;
    
    [self.uiTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self performSelector:@selector(changeTextBackToOriginal:) withObject:indexPath afterDelay:1.0];
}

// STEP 2: Change cell text back to original
- (void)changeTextBackToOriginal:(NSIndexPath *)indexPath {
    
    [self.uiTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self moveCellToTop:indexPath];
}

// STEP 3: Move cell text to the top
- (void)moveCellToTop:(NSIndexPath *)indexPath {
    
    [CATransaction begin];
    
    [self.uiTableView beginUpdates];
    
    [self.uiTableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [arTableViewDataSource moveObjectAtIndex:indexPath.row toIndex:0];
    
    [CATransaction setCompletionBlock: ^{
        sendingMessageToUserIndexPath = nil;
        [self.uiTableView reloadData];
    }];
    
    [self.uiTableView endUpdates];
    
    [CATransaction commit];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101 && buttonIndex == 1) {
        NSString *username = [alertView textFieldAtIndex:0].text;
        if (username.length > 0) {
            if ([[username uppercaseString] isEqualToString:[self userIpse]]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"That's your own username" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                alertView.tag = 100;
                [alertView show];
            } else {
                [self checkForUsername:username];
            }
        }
    }
}

#pragma mark - TableView data API

- (void)getAllActivityAndUpdateTableViewDataSource {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"FROMUSER == %@ OR TOUSER == %@", [self userIpse], [self userIpse]];
    PFQuery *pfQuery = [PFQuery queryWithClassName:ACTIVITY predicate:predicate];
    [pfQuery orderByDescending:UPDATEDAT];
    [pfQuery findObjectsInBackgroundWithTarget:self selector:@selector(reloadTableViewDataSource:error:)];
}

- (void)getAllActivityAndUpdateTableViewUI {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"FROMUSER == %@ OR TOUSER == %@", [self userIpse], [self userIpse]];
    PFQuery *pfQuery = [PFQuery queryWithClassName:ACTIVITY predicate:predicate];
    [pfQuery orderByDescending:UPDATEDAT];
    [pfQuery findObjectsInBackgroundWithTarget:self selector:@selector(reloadTableViewUI:error:)];
}

- (void)reloadTableViewUI:(NSArray *)result error:(NSError *)error {
    arTableViewDataSource = [NSMutableArray arrayWithArray:result];
    if (result.count == 0) {
        [self setInitialState];
    } else {
        [self.uiTableView reloadData];
    }
}

- (void)reloadTableViewDataSource:(NSArray *)result error:(NSError *)error {
    arTableViewDataSource = [NSMutableArray arrayWithArray:result];
}

#pragma mark - PFObject API methods

- (void)checkForUsername:(NSString *)username {
    usernameBeingSearched = username;
    usernameBeingSearched = [usernameBeingSearched uppercaseString];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"USERNAME == %@", usernameBeingSearched];
    PFQuery *pfQuery = [PFQuery queryWithClassName:USER predicate:predicate];
    [pfQuery findObjectsInBackgroundWithTarget:self selector:@selector(usernameCheckComplete:error:)];
}

- (void)usernameCheckComplete:(NSArray *)array error:(NSError *)error {
    if (array.count > 0) {
        [self checkForExistingMessageToUser:usernameBeingSearched];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Username not found" message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        alertView.tag = 102;
        [alertView show];
    }
}

- (void)checkForExistingMessageToUser:(NSString *)username {
    sendingMessageToUser = username;
    sendingMessageToUser = [sendingMessageToUser uppercaseString];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(FROMUSER == %@ AND TOUSER == %@) OR (FROMUSER == %@ AND TOUSER == %@)", [self userIpse], sendingMessageToUser,sendingMessageToUser, [self userIpse]];
    
    PFQuery *pfQuery = [PFQuery queryWithClassName:ACTIVITY predicate:predicate];
    
    [pfQuery findObjectsInBackgroundWithTarget:self selector:@selector(sendMessageToUser:error:)];
}

- (void)sendMessageToUser:(NSArray *)result completionHandler:(void (^)())completionHandler {
    
    completionHandler();
}

- (void)sendMessageToUser:(NSArray *)result error:(NSError *)error {
    
    // MESSAGE ALREADY EXISTS BETWEEN THESE TWO USERS
    if (result.count > 0) {
        
        PFObject *pfObjectExisting = (PFObject *)[result objectAtIndex:0];
        
        NSNumber *countNUM = (NSNumber *)[pfObjectExisting objectForKey:COUNT];
        
        NSInteger countINT = [countNUM integerValue];
        
        NSInteger countINTIncremented = ++countINT;
        
        NSNumber *countNUMIncremented = [NSNumber numberWithInteger:countINTIncremented];
        
        [pfObjectExisting setObject:countNUMIncremented forKey:COUNT];
        
        [pfObjectExisting saveInBackground];
        
        
    // FIRST MESSAGE BETWEEN THESE TWO USERS
    } else {
        NSDictionary *activityDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[self userIpse], FROMUSER, sendingMessageToUser, TOUSER, nil];
        
        PFObject *pfObjectNew = [PFObject objectWithClassName:ACTIVITY dictionary:activityDictionary];
        
        [pfObjectNew saveInBackgroundWithTarget:self selector:@selector(getAllActivityAndUpdateTableViewUI)];
    }
    
    [ParseHelper sendMahlzeitPushToUser:sendingMessageToUser];
}


#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Resize image
    CGSize size;
    
    if (image.size.height > image.size.width) {
        size.width = 640;
        size.height = image.size.height/image.size.width * size.width;
    } else {
        size.height = 1136;
        size.width = image.size.width/image.size.height * size.height;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [image drawInRect: CGRectMake(0, 0, size.width, size.height)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.40f);
    [self uploadImage:imageData];
}

- (void)uploadImage:(NSData *)imageData {
    imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    // Set determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.delegate = self;
    HUD.labelText = @"Uploading";
    [HUD show:YES];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //Hide determinate HUD
            [HUD hide:YES];
            
            // Show checkmark
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            
            HUD.delegate = self;
            
            UITableViewCell *cell = [self.uiTableView cellForRowAtIndexPath:indexPathForPhoto];
            cell.tag = 0;
            
            PFObject *pfObjectExisting = (PFObject *)[arTableViewDataSource objectAtIndex:indexPathForPhoto.row];
            NSString *username = [ParseHelper otherUserInPFObject:pfObjectExisting];
            [pfObjectExisting setObject:imageFile forKey:PHOTO];
            [pfObjectExisting setObject:[self userIpse] forKey:FROMUSER];
            [pfObjectExisting setObject:username forKey:TOUSER];
            [pfObjectExisting setObject:@YES forKey:UNREAD];
            
            [pfObjectExisting saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"Photo saved successfully");
                    [self getAllActivityAndUpdateTableViewUI];
                    [ParseHelper sendPhotoPushToUser:username];
                }
                else{
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else{
            [HUD hide:YES];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        HUD.progress = (float)percentDone/100;
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:HELP_OVERLAY_SHOWN_SEND_PHOTO] == nil) {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:HELP_OVERLAY_SHOWN_SEND_PHOTO];
            [self displayHelpOverlay];
        }
    }];
}

#pragma mark - imitate iOS push notification view from top

- (void)handlePushNotificationInApp:(NSNotification *)notification {
    [self getAllActivityAndUpdateTableViewUI];
    [self showFakePushNotificationAnimation:notification];
}

#pragma mark - check if app opened through URL scheme, if yes then perform required activity, if not then refresh data on screen

- (void)refreshDataOnScreen {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.addUserNameReceivedFromURLScheme && appDelegate.addUserNameReceivedFromURLScheme.length > 0) {
        NSString *username = appDelegate.addUserNameReceivedFromURLScheme;
        appDelegate.addUserNameReceivedFromURLScheme = nil;
        [self checkForUsername:username];
    } else {
        [self getAllActivityAndUpdateTableViewUI];
    }
}


#define BANNER_HEIGHT 50.0

- (void)showFakePushNotificationAnimation:(NSNotification *)notification {
    AudioServicesPlaySystemSound(self.soundId);
    if (notification) {
        NSString *message = [NSString stringWithFormat:@"%@", [[[notification object] objectForKey:@"aps"] objectForKey:@"alert"]];
        
        UIToolbar *newmessageBannerView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -BANNER_HEIGHT, self.view.frame.size.width, BANNER_HEIGHT)];
        newmessageBannerView.translucent = YES;
        newmessageBannerView.barTintColor = [UIColor colorWithWhite:0.074 alpha:0.550];
        
        UILabel *bannerLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0, 10.0, 320.0, 22.0)];
        bannerLabel.textAlignment =  NSTextAlignmentLeft;
        bannerLabel.textColor = [UIColor whiteColor];
        bannerLabel.font = [UIFont systemFontOfSize:17.0];
        bannerLabel.text = message;
        [newmessageBannerView addSubview:bannerLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 13.0, 16.0, 16.0)];
        imageView.image = [UIImage imageNamed:@"AppIcon_24"];
        [newmessageBannerView addSubview:imageView];
        
        [self.view addSubview:newmessageBannerView];
        
        [UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             newmessageBannerView.frame = CGRectMake(0, 0, self.view.frame.size.width, BANNER_HEIGHT);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.25 delay:2.0 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  newmessageBannerView.frame = CGRectMake(0, -BANNER_HEIGHT, self.view.frame.size.width, BANNER_HEIGHT);
                                              }completion:^(BOOL finished) {
                                                  [newmessageBannerView removeFromSuperview];
                                              }];
                         }];
    }
    
}

@end
