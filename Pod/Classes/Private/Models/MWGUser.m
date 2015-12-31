//  MWGUser.m
//
// Author:   Ranjan Patra
// Created:  30/3/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

/**
 * Model for MWGUser Details
 */

#import "MWGUser.h"

@interface MWGUser ()
{
    NSString *userId;           // MWGUser Id
    NSString *userName;         // MWGUser Name
    NSString *access_token;     // MWGUser Access Token
}
@end

@implementation MWGUser

@synthesize userId, userName;

@end
