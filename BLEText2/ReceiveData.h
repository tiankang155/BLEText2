//
//  ReceiveData.h
//  BLEText2
//
//  Created by yarui on 2017/11/14.
//  Copyright © 2017年 Tiankang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ReceiveData : NSObject
+(NSInteger)receiceDataForCharacteristic:(CBCharacteristic*)characteristic;

@end
