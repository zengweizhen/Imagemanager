//
//  SCPictureItem.m
//  SCPictureBrowser
//
//  Created by sichenwang on 16/4/5.
//  Copyright © 2016年 sichenwang. All rights reserved.
//

#import "SCPictureItem.h"

@implementation SCPictureItem

- (instancetype)init
{
    self = [super init];
    if(self){
        self.isThumblenail = YES;
    }
    return self;
}

- (void)makeAbolished
{
    self.isAbolished = YES;
}
@end
