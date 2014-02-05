//
//  Miner.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 2/2/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "Miner.h"

@implementation Miner

@synthesize name;
@synthesize address;

-(void)encodeWithCoder:(NSCoder*) encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.address forKey:@"address"];
}

-(id)initWithCoder:(NSCoder*) decoder
{
    if (self = [super init])
    {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.address = [decoder decodeObjectForKey:@"address"];
    }
    return self;
}

+(NSArray*)loadMinersFromDefaultsForKey:(NSString*) key
{
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+(void)saveMinersToDefaults:(NSArray*) miners  forKey:(NSString*) key
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:miners];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(Boolean)isValidAddress:(NSString*)address
{
    if (address == nil)
        return false;
    if ([address length] != 34)
        return false;
    if ([address characterAtIndex:0] != '1')
        return false;
    
    return true;
}

@end
