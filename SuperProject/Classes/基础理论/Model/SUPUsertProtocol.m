//
//  SUPUsertProtocol.m
//  SuperProject
//
//  Created by NShunJian on 2018/1/20.
//  Copyright © 2018年 superMan. All rights reserved.
//

#import "SUPUsertProtocol.h"

@implementation SUPUsertProtocol
//todo@yz 优化这里的协议示例 完整应该是持有一个weak 的 delegate 这个delegate实现协议方法


- (void)connectDataBase:(id<SUPDataBaseConnectionProtocol>)dataBase withIndentifier:(NSString *)Indentifier
{
    
    NSLog(@"%s", __func__);
    
    if ([dataBase respondsToSelector:@selector(start)]) {
        [dataBase start];
    }
    
    
    NSLog(@"%s", __func__);
    
}


@end
