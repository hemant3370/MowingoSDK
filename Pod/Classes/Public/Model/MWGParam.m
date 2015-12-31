//
//  MWGParam.m
//
// Author:   Ranjan Patra
// Created:  17/7/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGParam.h"
#import "MWGConstants.h"


@interface MWGParam ()
{
    //sdk version value
    NSString *SDKVersion;
}
@end

/**
 *  Provides SDK parameters
 */
@implementation MWGParam

@synthesize SDKVersion;

- (id) init
{
    if (self = [super init]) {
        SDKVersion = SDK_VERSION;// set sdk version from macro of MWGConstant
    }
    
    return self;
}

@end
