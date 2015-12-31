//
//  MWGGeofence.m
// Author:   Ranjan Patra
// Created:  01/4/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "MWGGeofence.h"
#import "MWGConstants.h"


/**
 *  Represents a geofence
 */
@implementation MWGGeofence

@synthesize gfid,gflat,gflon,radius,type,pid,did,intxt,outtxt;

/**
 *  converts Objects into geofence dictionary
 *
 *  @return equivalent geofence dictionary
 */
-(NSDictionary *)geofenceDictionary
{
    return @{geofence_id : gfid,
             geofence_lat : gflat,
             geofence_long : gflon,
             geofence_radius : radius,
             geofence_type : type,
             geofence_pid : pid,
             geofence_did : did,
             geofence_intxt : intxt,
             geofence_outtxt : outtxt};
}


/**
 *  initialize class with geofence dictionary
 *
 *  @param geofence geofence dictionary
 *
 *  @return class instance
 */
-(id) initWithDictionary:(NSDictionary *)geofence
{
    if (self = [super init])
    {
        gfid = geofence[geofence_id];
        gflat = geofence[geofence_lat];
        
        gflon = geofence[geofence_long];
        radius = geofence[geofence_radius];
        
        type = geofence[geofence_type];
        
        pid = geofence[geofence_pid];
        did = geofence[geofence_did];
        
        intxt = geofence[geofence_intxt];
        outtxt = geofence[geofence_outtxt];
        
    }
    
    return self;
}


/**
 *  Encode current class
 *
 *  @param aCoder coder object
 */
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:gfid forKey:geofence_id];
    [aCoder encodeObject:gflat forKey:geofence_lat];
    [aCoder encodeObject:gflon forKey:geofence_long];
    
    [aCoder encodeObject:radius forKey:geofence_radius];
    [aCoder encodeObject:type forKey:geofence_type];
    
    [aCoder encodeObject:pid forKey:geofence_pid];
    [aCoder encodeObject:did forKey:geofence_did];
    [aCoder encodeObject:intxt forKey:geofence_intxt];
    
    [aCoder encodeObject:outtxt forKey:geofence_outtxt];
    
}


/**
 *  initialize class by encoding data using specified decoder
 *
 *  @param aDecoder decoder object
 *
 *  @return class instance
 */
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        gfid = [aDecoder decodeObjectForKey:geofence_id];
        gflat = [aDecoder decodeObjectForKey:geofence_lat];
        gflon = [aDecoder decodeObjectForKey:geofence_long];
        
        radius = [aDecoder decodeObjectForKey:geofence_radius];
        type = [aDecoder decodeObjectForKey:geofence_type];
        
        pid = [aDecoder decodeObjectForKey:geofence_pid];
        did = [aDecoder decodeObjectForKey:geofence_did];
        intxt = [aDecoder decodeObjectForKey:geofence_intxt];
        outtxt = [aDecoder decodeObjectForKey:geofence_outtxt];
        
    }
    return self;
}



@end
