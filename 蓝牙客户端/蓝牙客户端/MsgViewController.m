//
//  MsgViewController.m
//  蓝牙客户端
//
//  Created by sam on 15/7/6.
//  Copyright © 2015年 sam. All rights reserved.
//

#import "MsgViewController.h"

@interface MsgViewController ()
@property (strong, nonatomic) IBOutlet UITextField *msgTextField;
- (IBAction)sendMsg:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITextView *msgTextView;
- (IBAction)backHome:(UIButton *)sender;
- (IBAction)getInfo:(UIButton *)sender;

@end

@implementation MsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.bluetooth setNotificationForCharacteristicWithServiceUUID:@"1C85D7B7-17FA-4362-82CF-85DD0B76A9A5" CharacteristicUUID:@"7D887E40-95DE-40D6-9AA0-36EDE2BAE253" enable:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ValueChange:) name:SNNotiValueChange object:nil];
}
-(void)ValueChange:(NSNotification *)noti{
    NSString *string=[[NSString alloc] initWithData:noti.object encoding:NSUTF8StringEncoding];
    self.msgTextView.text=[NSString stringWithFormat:@"%@\n%@",string,self.msgTextView.text];
}
- (IBAction)sendMsg:(UIButton *)sender {
    NSData *data = [self.msgTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    self.msgTextView.text=[NSString stringWithFormat:@"%@\n%@",self.msgTextField.text,self.msgTextView.text];
    self.msgTextField.text=@"";
    if (_bluetooth.isConnection) {
        [_bluetooth writeCharacteristicWithServiceUUID:@"1C85D7B7-17FA-4362-82CF-85DD0B76A9A5" CharacteristicUUID:@"7E887E40-95DE-40D6-9AA0-36EDE2BAE253" data:data];
    }
    else {
        [_bluetooth connectionWithDeviceUUID:self.UUID TimeOut:2 CompleteBlock: ^(CBPeripheral *device, NSError *err) {
            [_bluetooth discoverServiceAndCharacteristicWithInterval:2 CompleteBlock: ^(NSArray *serviceArray, NSArray *characteristicArray, NSError *err) {
                [_bluetooth writeCharacteristicWithServiceUUID:@"1C85D7B7-17FA-4362-82CF-85DD0B76A9A5" CharacteristicUUID:@"7E887E40-95DE-40D6-9AA0-36EDE2BAE253" data:data];
            }];
        }];
    }
}
- (IBAction)backHome:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getInfo:(UIButton *)sender {
    if (_bluetooth.isConnection) {
        [_bluetooth readCharacteristicWithServiceUUID:@"1C85D7B7-17FA-4362-82CF-85DD0B76A9A5" CharacteristicUUID:@"7F887E40-95DE-40D6-9AA0-36EDE2BAE253"];
    }
    else {
        [_bluetooth connectionWithDeviceUUID:self.UUID TimeOut:2 CompleteBlock: ^(CBPeripheral *device, NSError *err) {
            [_bluetooth discoverServiceAndCharacteristicWithInterval:2 CompleteBlock: ^(NSArray *serviceArray, NSArray *characteristicArray, NSError *err) {
                [_bluetooth readCharacteristicWithServiceUUID:@"1C85D7B7-17FA-4362-82CF-85DD0B76A9A5" CharacteristicUUID:@"7F887E40-95DE-40D6-9AA0-36EDE2BAE253"];
            }];
        }];
    }
    
}
@end
