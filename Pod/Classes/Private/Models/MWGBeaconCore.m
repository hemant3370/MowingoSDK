//
// MWGBeacon.m
// Author:   Ranjan Patra
// Created:  01/4/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGBeaconCore.h"
#import "MWGConstants.h"

@implementation MWGBeaconCore

@synthesize bid, budid, major, minor, proximity, type, pid, did, inTxt, outText;


-(NSDictionary *)beaconDictionary
{
    return @{beacon_id : bid,
             beacon_uuid : budid,
             beacon_major : major ? major : @"0",
             beacon_minor : minor ? minor : @"0",
             beacon_proximity : proximity,
             beacon_type : type,
             beacon_pid : pid,
             beacon_did : did,
             beacon_intxt : inTxt,
             beacon_outtxt : outText};
}

-(id) initWithDictionary:(NSDictionary *)beacon
{
    if (self = [super init])
    {
        bid = beacon[beacon_id];
        budid = beacon[beacon_uuid];
        
        major = beacon[beacon_major];
        minor = beacon[beacon_minor];
        
        proximity = beacon[beacon_proximity];
        type = beacon[beacon_type];
        
        pid = beacon[beacon_pid];
        did = beacon[beacon_did];
        
        inTxt = beacon[beacon_intxt];
        outText = beacon[beacon_outtxt];
        
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:bid forKey:beacon_id];
    [aCoder encodeObject:budid forKey:beacon_uuid];
    [aCoder encodeObject:major forKey:beacon_major];
    
    [aCoder encodeObject:minor forKey:beacon_minor];
    [aCoder encodeObject:proximity forKey:beacon_proximity];
    [aCoder encodeObject:type forKey:beacon_type];
    
    [aCoder encodeObject:pid forKey:beacon_pid];
    [aCoder encodeObject:did forKey:beacon_did];
    [aCoder encodeObject:inTxt forKey:beacon_intxt];
    
    [aCoder encodeObject:outText forKey:beacon_outtxt];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        bid = [aDecoder decodeObjectForKey:beacon_id];
        budid = [aDecoder decodeObjectForKey:beacon_uuid];
        major = [aDecoder decodeObjectForKey:beacon_major];
        
        minor = [aDecoder decodeObjectForKey:beacon_minor];
        proximity = [aDecoder decodeObjectForKey:beacon_proximity];
        type = [aDecoder decodeObjectForKey:beacon_type];
        
        pid = [aDecoder decodeObjectForKey:beacon_pid];
        did = [aDecoder decodeObjectForKey:beacon_did];
        inTxt = [aDecoder decodeObjectForKey:beacon_intxt];
        outText = [aDecoder decodeObjectForKey:beacon_outtxt];
        
    }
    return self;
}


@end
