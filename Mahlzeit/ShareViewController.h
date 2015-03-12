//
//  ShareViewController.h
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 7/5/14.
//  Copyright (c) 2014 com.webawesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ShareViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *uiTableView;

@end
