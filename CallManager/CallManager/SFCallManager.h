//
//  RLCallManager.h
//  SFCallManager
//
//  Created by Jakey on 2018/9/10.
//  Copyright © 2018年 Jakey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import <CallKit/CXCallObserver.h>
#import <CallKit/CXCall.h>


typedef NS_ENUM(NSUInteger, SFCallState) {
    SFCallStateNone, //未拨打
    SFCallStateError, //出错
    SFCallStateDialing, //用户触发的通话
    SFCallStateConnected, //接通了
    SFCallStateDisconnected, //挂断了
    SFCallStateCancle //取消通话
};


@interface SFCallInfo : NSObject
@property(nonatomic,assign) BOOL isTrueCall;
@property(nonatomic,assign) BOOL isContactSuccess;
@property(nonatomic,assign) BOOL isIncoming;

@property(nonatomic,strong) NSDate *startDate;
@property(nonatomic,strong) NSDate *endDate;
@property(nonatomic,strong) id extInfo;
@end


typedef void(^CallManagerStateDidChanged)(SFCallState state);
typedef void(^CallManagerCallDidDone)(NSDate *startDate,NSDate *endDate,NSTimeInterval seconds);
@interface SFCallManager : NSObject<CXCallObserverDelegate>
{
    CallManagerStateDidChanged _stateDidChanged;
    CallManagerCallDidDone _callDidDone;
}

@property (nonatomic, strong) SFCallInfo *callInfo;
+ (SFCallManager *)sharedManager;
- (void)callPhone:(NSString*)phone
  stateDidChanged:(CallManagerStateDidChanged)stateDidChanged
      callDidDone:(CallManagerCallDidDone)callDidDone;
@end
