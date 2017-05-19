//
//  WYTestLayout.m
//  WaterFlowLayout
//
//  Created by saucymqin on 2017/5/19.
//  Copyright © 2017年 neutron. All rights reserved.
//

#define TICK   __block NSDate *startTime = [NSDate date]; __block NSDate *endTime = nil;
#define TOCK   endTime = [NSDate date];NSLog(@"\n\n[%s][Line %d]  duration:%.3f(ms)\n\n", __PRETTY_FUNCTION__, __LINE__, [endTime timeIntervalSinceDate:startTime]*1000);startTime = endTime

#import "WYTestLayout.h"

@implementation WYTestLayout

- (void)prepareLayout {
    TICK;
    [super prepareLayout];
    TOCK;
}

@end
