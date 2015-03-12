//
//  MainViewController.h
//  Mahlzeit
//
//  Created by Firodiya, Sanket on 6/28/14.
//  Copyright (c) 2014 com.webawesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *uiTableView;

@end
