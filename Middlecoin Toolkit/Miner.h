//
//  Miner.h
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 2/2/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Miner : NSObject <NSCoding>
{
    NSString* name;
    NSString* address;
}

@property NSString *name, *address;

+(NSArray*)loadMinersFromDefaultsForKey:(NSString*) key;
+(void)saveMinersToDefaults:(NSArray*) miners  forKey:(NSString*) key;
+(Boolean)isValidAddress:(NSString*)address;

@end
