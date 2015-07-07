//
//  MsgViewController.h
//  蓝牙客户端
//
//  Created by sam on 15/7/6.
//  Copyright © 2015年 sam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNBluetooth.h"

@interface MsgViewController : UIViewController
@property(nonatomic,strong) SNBluetooth *bluetooth;
@property(nonatomic,strong) NSString *UUID;
@end
