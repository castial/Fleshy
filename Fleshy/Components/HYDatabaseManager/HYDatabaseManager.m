//
//  HYDatabaseManager.m
//  Fleshy
//
//  Created by Hyyy on 2017/11/10.
//  Copyright © 2017年 Hyyy. All rights reserved.
//

#import "HYDatabaseManager.h"

NSString *const HYDatabaseName = @"fleshy.sqlite";

@interface HYDatabaseManager ()

@end

@implementation HYDatabaseManager

+ (instancetype)sharedInstance {
    static HYDatabaseManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HYDatabaseManager alloc] init];
    });
    return manager;
}

- (void)openDatabase {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *databasePath = [documentPath stringByAppendingPathComponent:HYDatabaseName];
    
    NSLog(@"数据库地址：%@", databasePath);
    
    self.dateBase = [FMDatabase databaseWithPath:databasePath];
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    
    if ([self.dateBase open]) {
        NSLog(@"数据库打开成功");
    }else{
        NSLog(@"数据库打开失败");
    }
}

- (void)closeDatabase {
    if ([self.dateBase close]) {
        NSLog(@"数据库关闭成功");
    }else {
        NSLog(@"数据库关闭失败");
    }
}

@end
