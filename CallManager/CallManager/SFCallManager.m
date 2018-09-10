//
//  RLCallManager.m
//  SFCallManager
//
//  Created by Jakey on 2018/9/10.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import "SFCallManager.h"
#import <UIKit/UIKit.h>

@interface SFCallManager()
@property (nonatomic, strong) CXCallObserver *callObserver;
@property (nonatomic, strong) CTCallCenter *callCenter;
@end
@implementation SFCallManager
+ (SFCallManager *)sharedManager
{
    static SFCallManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SFCallManager alloc] init];
    });
    return sharedManager;
}
- (void)callPhone:(NSString*)phone
  stateDidChanged:(CallManagerStateDidChanged)stateDidChanged
      callDidDone:(CallManagerCallDidDone)callDidDone{
    _stateDidChanged = [stateDidChanged copy];
    _callDidDone = [callDidDone copy];
    
    if (phone.length==0) {
        _stateDidChanged(SFCallStateError);
        return;
    }
    [self detectCall];
    self.callInfo = [[SFCallInfo alloc] init];
    NSLog(@"打电话给：%@",phone);
    [[[UIApplication sharedApplication].keyWindow viewWithTag:1999] removeFromSuperview];
    UIWebView *phoneCallWebView = nil;
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]];
    if ( !phoneCallWebView ) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    phoneCallWebView.tag = 1999;
    [[UIApplication sharedApplication].keyWindow addSubview:phoneCallWebView];
}

- (void)detectCall{
    if (@available(iOS 10.0, *)) {
        if (!self.callObserver) {
            self.callObserver = [[CXCallObserver alloc]init];
            [self.callObserver setDelegate:self queue:dispatch_get_main_queue()];
        }
    } else {
        if (!self.callCenter) {
            self.callCenter = [[CTCallCenter alloc] init];
        }
        __weak typeof(self)weakSelf = self;
        self.callCenter.callEventHandler=^(CTCall* call)
        {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (call.callState == CTCallStateDisconnected)
            {
                strongSelf->_stateDidChanged(SFCallStateDisconnected);
                if(strongSelf.callInfo.isTrueCall && strongSelf.callInfo.startDate && strongSelf.callInfo.isContactSuccess){
                    strongSelf.callInfo.endDate = [NSDate date];
                    strongSelf->_callDidDone(strongSelf.callInfo.startDate,strongSelf.callInfo.endDate,[strongSelf.callInfo.endDate timeIntervalSinceDate:strongSelf.callInfo.startDate]);
                }else{
                    strongSelf.callInfo.isTrueCall = NO;
                    strongSelf.callInfo.isContactSuccess = NO;
                    strongSelf->_stateDidChanged(SFCallStateCancle);
                }
            }
            else if (call.callState == CTCallStateConnected)
            {
                if (strongSelf.callInfo.isTrueCall) {
                    strongSelf.callInfo.startDate = [NSDate date];
                    strongSelf.callInfo.isContactSuccess = YES;
                    strongSelf->_stateDidChanged(SFCallStateConnected);
                }
            } else if (call.callState  == CTCallStateDialing)
            {
                strongSelf.callInfo.isTrueCall = YES;
                strongSelf->_stateDidChanged(SFCallStateDialing);
            }else if (call.callState  == CTCallStateIncoming)
            {
                strongSelf.callInfo.isIncoming = YES;
            }
        };
        // Fallback on earlier versions
        NSLog(@"iOS10暂不支持callkit,使用callCenter");
    }
}

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call{
    
    NSLog(@"outgoing :%d onHold :%d hasConnected :%d hasEnded :%d",call.outgoing,call.onHold,call.hasConnected,call.hasEnded);
    
    /** 以下为我手动测试 如有错误欢迎指出
     拨通: outgoing :1 onHold :0 hasConnected :0 hasEnded :0
     拒绝: outgoing :1 onHold :0 hasConnected :0 hasEnded :1
     链接: outgoing :1 onHold :0 hasConnected :1 hasEnded :0
     挂断: outgoing :1 onHold :0 hasConnected :1 hasEnded :1
     新来电话: outgoing :0 onHold :0 hasConnected :0 hasEnded :0
     保留并接听: outgoing :1 onHold :1 hasConnected :1 hasEnded :0
     另一个挂掉: outgoing :0 onHold :0 hasConnected :1 hasEnded :0 保
     持链接: outgoing :1 onHold :0 hasConnected :1 hasEnded :1
     对方挂掉: outgoing :0 onHold :0 hasConnected :1 hasEnded :1 */
    //来电
    if (!call.outgoing) {
        self.callInfo.isIncoming = YES;
    }
    //拨打中
    if (!call.hasConnected && !call.hasEnded) {
        _stateDidChanged(SFCallStateDialing);
    }
    //接通
    if (call.hasConnected && !call.hasEnded) {
        _stateDidChanged(SFCallStateConnected);
        self.callInfo.startDate = [NSDate date];
    }
    //挂断
    if (call.hasConnected && call.hasEnded) {
        _stateDidChanged(SFCallStateDisconnected);
        self.callInfo.endDate = [NSDate date];
        _callDidDone(self.callInfo.startDate,self.callInfo.endDate,[self.callInfo.endDate timeIntervalSinceDate:self.callInfo.startDate]);
    }
    //取消通话
    if (!call.hasConnected && call.hasEnded) {
        _stateDidChanged(SFCallStateCancle);
    }
}
@end

@implementation SFCallInfo

@end
