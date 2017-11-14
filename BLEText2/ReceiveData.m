//
//  ReceiveData.m
//  BLEText2
//
//  Created by yarui on 2017/11/14.
//  Copyright © 2017年 Tiankang. All rights reserved.
//

#import "ReceiveData.h"

@implementation ReceiveData
+(NSInteger)receiceDataForCharacteristic:(CBCharacteristic*)characteristic{
    NSData *data = [characteristic value];
    const uint8_t *reportData = [data bytes]; //转换一个字节对应一个整数的序列
    NSInteger receiceData = reportData[3];  //读第三位的数据
    return receiceData;
}
@end
