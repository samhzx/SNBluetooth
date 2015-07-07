//
//  ViewController.m
//  蓝牙客户端
//
//  Created by sam on 15/7/6.
//  Copyright © 2015年 sam. All rights reserved.
//

#import "ViewController.h"
#import "SNBluetooth.h"
#import "MsgViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic) NSMutableArray *dataSource;
- (IBAction)scanDevice:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UITableView *deviceTable;

@property(strong,nonatomic) SNBluetooth *bluetooth;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initUI];
}

//初始化数据
- (void)initData {
    self.bluetooth=[SNBluetooth sharedInstance];
    self.dataSource=[[NSMutableArray alloc] init];
}
//初始化界面
- (void)initUI {
    self.deviceTable.dataSource=self;
    self.deviceTable.delegate=self;
}
#pragma mark 表格里面必须实现的方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.detailTextLabel.text=[((CBPeripheral *)self.dataSource[indexPath.row]).identifier UUIDString];
    cell.textLabel.text=((CBPeripheral *)self.dataSource[indexPath.row]).name;
    return cell;
}
//点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //点击之后取消高亮
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"连接设备中...");
    [self.bluetooth connectionWithDeviceUUID:[((CBPeripheral *)self.dataSource[indexPath.row]).identifier UUIDString] TimeOut:3 CompleteBlock:^(CBPeripheral *device, NSError *err) {
        if (device) {
            NSLog(@"查找设备的服务和特征...");
            [self.bluetooth discoverServiceAndCharacteristicWithInterval:3 CompleteBlock:^(NSArray *serviceArray, NSArray *characteristicArray, NSError *err) {
                
                NSLog(@"查找服务和特征成功 %ld",serviceArray.count);
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MsgViewController *msgVC = [storyBoard instantiateViewControllerWithIdentifier:@"MsgViewController"];
                msgVC.bluetooth=self.bluetooth;
                msgVC.UUID=[((CBPeripheral *)self.dataSource[indexPath.row]).identifier UUIDString];
                [self presentViewController:msgVC animated:YES completion:nil];
            }];
        }else{
            NSLog(@"连接设备失败");
        }

    }];
}
- (IBAction)scanDevice:(UIBarButtonItem *)sender {
    __weak typeof(self) WeakSelf=self;
    [self.bluetooth startScanDevicesWithInterval:5 CompleteBlock:^(NSArray *devices) {
        [WeakSelf.dataSource removeAllObjects];
        for (CBPeripheral *per in devices) {
            [WeakSelf.dataSource addObject:per];
        }
        [WeakSelf.deviceTable reloadData];
    }];
}
@end
