//
//  TestModel.m
//  HDCommon_Example
//
//  Created by bailun on 2024/2/27.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import "TestModel.h"

@interface TestModel()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation TestModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataArray = NSMutableArray.array;
        [_dataArray removeObjectAtIndex:1];
    }
    return self;
}
@end
