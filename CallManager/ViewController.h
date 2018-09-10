//
//  ViewController.h
//  CallManager
//
//  Created by Jakey on 2018/9/10.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
- (IBAction)callTouched:(id)sender;

@end

