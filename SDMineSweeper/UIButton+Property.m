//
//  UIButton+Property.m
//  SDMineSweeper
//
//  Created by sdong on 2/12/15.
//  Copyright (c) 2015 SD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIButton+Property.h"
#import <objc/runtime.h>


@implementation UIButton(Property)

static char UIB_PROPERTY_KEY;

@dynamic status;

-(void)setStatus:(NSObject *)status
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, status, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSObject*)status
{
    return (NSObject*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}


@end