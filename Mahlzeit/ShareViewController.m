//
//  ShareViewController.m
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 7/5/14.
//  Copyright (c) 2014 com.webawesome. All rights reserved.
//

#import "ShareViewController.h"
#import "GlobalConstants.h"
#import <Social/Social.h>
#import "FontHelper.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)shareText {
    return [NSString stringWithFormat:@"Hey, join me on Mahlzeit! Its a super fun way to say Mahlzeit to friends. My userid is: \"%@\". Get the app here - webaweso.me/mahlzeit", [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME]];
}

- (NSString *)shareTextForWhatsApp {
    NSString *unencodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)[self shareText],
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8 ));

    NSString *encodedString = [NSString stringWithFormat:@"whatsapp://send?text=%@", unencodedString];
    
    return encodedString;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 5;
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}

#define HEADER_HEIGHT 36.0
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else if (section == 1) {
        return HEADER_HEIGHT;
    } else {
        return 7.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, HEADER_HEIGHT)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, HEADER_HEIGHT/4, tableView.frame.size.width, HEADER_HEIGHT/2)];
    headerLabel.textColor = [UIColor darkGrayColor];
    [headerView addSubview:headerLabel];
    headerView.backgroundColor = [UIColor clearColor];
    
    if (section == 1) {
        headerLabel.text = @"INVITE FRIENDS";
        headerLabel.font = [FontHelper getCustomFontWithSize:16 bold:NO];
    } else {
        headerLabel.text = @"";
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.font = [FontHelper getCustomFontWithSize:28 bold:NO];
    if (indexPath.section == 0) {
        label.text = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
        cell.backgroundColor = COLOR_BLUE1;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            label.text = @"WHATSAPP";
            cell.backgroundColor = COLOR_WHATSAPP;
        } else if (indexPath.row == 1) {
            label.text = @"EMAIL";
            cell.backgroundColor = COLOR_EMAIL;
        } else if (indexPath.row == 2) {
            label.text = @"FACEBOOK";
            cell.backgroundColor = COLOR_FACEBOOK;
        } else if (indexPath.row == 3) {
            label.text = @"TWITTER";
            cell.backgroundColor = COLOR_TWITTER;
        } else if (indexPath.row == 4) {
            label.text = @"MESSAGE";
            cell.backgroundColor = COLOR_MESSAGE;
        }
    } else {
        label.text = @"DONE";
        cell.backgroundColor = [UIColor colorWithRed:0.310 green:0.741 blue:0.682 alpha:1.000];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) { //WHATSAPP
            NSString *whatsappURLString = [self shareTextForWhatsApp];
            NSURL *whatsappURL = [NSURL URLWithString:whatsappURLString];
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication] openURL: whatsappURL];
            }
            
        } else if (indexPath.row == 1) { //EMAIL
            NSString *emailTitle = @"Get Mahlzeit";
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            mailComposeViewController.mailComposeDelegate = self;
            [mailComposeViewController setSubject:emailTitle];
            [mailComposeViewController setMessageBody:[self shareText] isHTML:YES];
            [self presentViewController:mailComposeViewController animated:YES completion:NULL];
            
            
        } else if (indexPath.row == 2) { //FACEBOOK
            
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [facebookSheet setInitialText:[self shareText]];
                [self presentViewController:facebookSheet animated:YES completion:Nil];
            }
            
        } else if (indexPath.row == 3) { //TWITTER
            
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                SLComposeViewController *tweetSheet = [SLComposeViewController
                                                       composeViewControllerForServiceType:SLServiceTypeTwitter];
                [tweetSheet setInitialText:[self shareText]];
                [self presentViewController:tweetSheet animated:YES completion:nil];
            }
        } else if (indexPath.row == 4) { //MESSAGE
            
            if ([MFMessageComposeViewController canSendText]) {
                [self displaySMSComposerSheet];
            } else {
                NSLog(@"Device not configured to send SMS.");
            }
            
        }
    } else if (indexPath.section == 2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)displaySMSComposerSheet {
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
    picker.body = [self shareText];
	[self presentViewController:picker animated:YES completion:NULL];
}

// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	switch (result) {
		case MFMailComposeResultCancelled:
			NSLog(@"Result: Mail sending canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: Mail saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: Mail sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: Mail sending failed");
			break;
		default:
			NSLog(@"Result: Mail not sent");
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:NULL];
}

// -------------------------------------------------------------------------------
//	messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Result: SMS sending canceled");
			break;
		case MessageComposeResultSent:
			NSLog(@"Result: SMS sent");
			break;
		case MessageComposeResultFailed:
			NSLog(@"Result: SMS sending failed");
			break;
		default:
			NSLog(@"Result: SMS not sent");
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
