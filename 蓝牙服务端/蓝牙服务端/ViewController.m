//
//  ViewController.m
//  蓝牙服务端
//
//  Created by sam on 15/7/6.
//  Copyright (c) 2015年 sam. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString *const kServiceUUID = @"1C85D7B7-17FA-4362-82CF-85DD0B76A9A5";
static NSString *const kCharacteristicUUID = @"7E887E40-95DE-40D6-9AA0-36EDE2BAE253";
static NSString *const kCharacteristicUUID1 = @"7F887E40-95DE-40D6-9AA0-36EDE2BAE253";
static NSString *const kCharacteristicUUID2 = @"7D887E40-95DE-40D6-9AA0-36EDE2BAE253";


@interface ViewController () <CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableCharacteristic *customWriteCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *customReadCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *customNotiCharacteristic;
@property (nonatomic, strong) CBMutableService *customService;

@property (strong, nonatomic) IBOutlet UITextField *sendMsgTextField;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet UITextView *InfoTextView;
- (IBAction)sendMsg:(UIButton *)sender;
- (IBAction)changeValue:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	_peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
	switch (peripheral.state) {
		case CBPeripheralManagerStatePoweredOn:
		{
			NSLog(@"安装服务");
			[self setupService];
		}
		break;

		default:
		{
			NSLog(@"Peripheral Manager did change state");
		}
		break;
	}
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
	NSMutableData *data = [NSMutableData data];
	for (CBATTRequest *request in requests) {
		[data appendData:request.value];
	}
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.InfoTextView.text=[NSString stringWithFormat:@"%@\n%@",string,self.InfoTextView.text];
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if (error == nil) {
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey : @"MyBLEService", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kServiceUUID]] }];
    }
}
- (void)setupService {
	CBUUID *characteristicUUID = [CBUUID UUIDWithString:kCharacteristicUUID];
	CBUUID *characteristicUUID1 = [CBUUID UUIDWithString:kCharacteristicUUID1];
	CBUUID *characteristicUUID2 = [CBUUID UUIDWithString:kCharacteristicUUID2];


    //写的特征
	self.customWriteCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];

	NSString *string = @"欢迎连接";
    //读的特征
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	self.customReadCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID1 properties:CBCharacteristicPropertyRead value:data permissions:CBAttributePermissionsReadable];


    //通知的特诊
	self.customNotiCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID2 properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadEncryptionRequired];

    
	CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    //初始化一个服务
	self.customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    //把特征添加到服务里面去
	[self.customService setCharacteristics:@[self.customWriteCharacteristic, self.customReadCharacteristic, self.customNotiCharacteristic]];
    //把服务添加到设备上面取
	[self.peripheralManager addService:self.customService];
}

- (IBAction)sendMsg:(UIButton *)sender {
    NSData *data=[_sendMsgTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    self.InfoTextView.text=[NSString stringWithFormat:@"%@\n%@",_sendMsgTextField.text,self.InfoTextView.text];
    [self.peripheralManager updateValue:data forCharacteristic:self.customNotiCharacteristic onSubscribedCentrals:nil];
    self.sendMsgTextField.text=@"";
}

- (IBAction)changeValue:(UIButton *)sender {
    NSData *data=[_locationTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.customReadCharacteristic setValue:data];
}

@end
