//
//  ViewController.m
//  CallManager
//
//  Created by Jakey on 2018/9/10.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import "ViewController.h"
#import "SFCallManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)callTouched:(id)sender {
    SFCallManager *manager = [SFCallManager sharedManager];
    [manager callPhone:self.phoneTextField.text stateDidChanged:^(SFCallState state) {
        NSString *stateString = nil;
        if (state == SFCallStateError) {
            stateString = @"出错";
        }else if (state == SFCallStateDialing) {
            stateString = @"用户触发通话";
        }else if (state == SFCallStateConnected) {
            stateString = @"接通了";
        }else if (state == SFCallStateDisconnected) {
            stateString = @"挂断了";
        }else if (state == SFCallStateCancle) {
            stateString = @"取消";
        }
        self.stateLabel.text = stateString;
        
        
        NSLog(@"状态:%@",stateString);
    } callDidDone:^(NSDate *startDate, NSDate *endDate, NSTimeInterval seconds) {
        self.secondsLabel.text = [@(seconds) stringValue];
    }];
}
@end
