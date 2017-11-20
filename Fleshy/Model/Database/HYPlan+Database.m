//
//  HYPlan+Database.m
//  Fleshy
//
//  Created by Hyyy on 2017/11/14.
//  Copyright © 2017年 Hyyy. All rights reserved.
//

#import "HYPlan+Database.h"
#import "HYDBManager.h"

@implementation HYPlan (Database)

+ (void)databasae_insertPlan:(HYPlan *)plan block:(void (^)(BOOL, NSString *))block {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO fleshy_plan (plan_name, plan_start_time, plan_end_time, plan_create_time, plan_duration_time, plan_duration_days) VALUES ('%@', '%@', '%@', '%@', %ld , %ld);", plan.planName, [plan.startTime stringWithFormat:@"yyyy-MM-dd HH:mm:ss"], [plan.endTime stringWithFormat:@"yyyy-MM-dd HH:mm:ss"], [[NSDate new] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"], plan.durationTime, plan.durationDays];
    
    [[HYDBManager sharedInstance] executeInsetSQL:insertSql block:^(BOOL isSuccess, NSString *message) {
        block(isSuccess, message);
    }];
}

+ (void)database_queryPlan:(NSString *)planName block:(void (^)(BOOL, HYPlan *, NSString *))block {
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM fleshy_plan WHERE plan_name = '%@'", planName];
    [[HYDBManager sharedInstance] executeQuerySQL:querySql block:^(BOOL isSuccess, FMResultSet *rs, NSString *message) {
        while(rs.next) {
            HYPlan *plan = [[HYPlan alloc] init];
            plan.planId = [rs intForColumn:@"plan_id"];
            plan.planName = [rs stringForColumn:@"plan_name"];
            plan.startTime = [NSDate dateWithString:[rs stringForColumn:@"plan_start_time"] format:@"yyyy-MM-dd HH:mm:ss"];
            plan.endTime = [NSDate dateWithString:[rs stringForColumn:@"plan_end_time"] format:@"yyyy-MM-dd HH:mm:ss"];
            plan.createDate = [NSDate dateWithString:[rs stringForColumn:@"plan_create_time"] format:@"yyyy-MM-dd HH:mm:ss"];
            plan.durationTime = [rs intForColumn:@"plan_duration_time"];
            plan.durationDays = [rs intForColumn:@"plan_duration_days"];
            
            block(isSuccess, plan, message);
        }
    }];
}

+ (void)database_queryPlanWithPerformanceId:(NSInteger)performanceId block:(void (^)(BOOL, HYPlan *, NSString *))block {
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM fleshy_plan WHERE plan_id = (SELECT plan_id FROM fleshy_performance WHERE perform_id = %ld);", performanceId];
    [[HYDBManager sharedInstance] executeQuerySQL:querySql block:^(BOOL isSuccess, FMResultSet *rs, NSString *message) {
        while(rs.next) {
            HYPlan *plan = [[HYPlan alloc] init];
            plan.planId = [rs intForColumn:@"plan_id"];
            plan.planName = [rs stringForColumn:@"plan_name"];
            plan.startTime = [NSDate dateWithString:[rs stringForColumn:@"plan_start_time"] format:@"yyyy-MM-dd HH:mm:ss"];
            plan.endTime = [NSDate dateWithString:[rs stringForColumn:@"plan_end_time"] format:@"yyyy-MM-dd HH:mm:ss"];
            plan.createDate = [NSDate dateWithString:[rs stringForColumn:@"plan_create_time"] format:@"yyyy-MM-dd HH:mm:ss"];
            plan.durationTime = [rs intForColumn:@"plan_duration_time"];
            plan.durationDays = [rs intForColumn:@"plan_duration_days"];
            
            block(isSuccess, plan, message);
        }
    }];
}

+ (void)database_queryAllPlan:(void (^)(BOOL, NSArray<HYPlan *> *, NSString *))block {
    NSString *querySql = @"SELECT * FROM fleshy_plan;";
    [[HYDBManager sharedInstance] executeQuerySQL:querySql block:^(BOOL isSuccess, FMResultSet *rs, NSString *message) {
        NSMutableArray *tempArrray = [NSMutableArray array];
        while (rs.next) {
            HYPlan *plan = [[HYPlan alloc] init];
            plan.planId = [rs intForColumn:@"plan_id"];
            plan.planName = [rs stringForColumn:@"plan_name"];
            plan.startTime = [NSDate dateWithString:[rs stringForColumn:@"plan_start_time"] format:@"yyyy-MM-dd HH:mm:ss"];
            plan.endTime = [NSDate dateWithString:[rs stringForColumn:@"plan_end_time"] format:@"yyyy-MM-dd HH:mm:ss"];
            plan.createDate = [NSDate dateWithString:[rs stringForColumn:@"plan_create_time"] format:@"yyyy-MM-dd HH:mm:ss"];
            plan.durationTime = [rs intForColumn:@"plan_duration_time"];
            plan.durationDays = [rs intForColumn:@"plan_duration_days"];
            [tempArrray addObject:plan];
        }
        block(isSuccess, tempArrray, message);
    }];
}

@end
