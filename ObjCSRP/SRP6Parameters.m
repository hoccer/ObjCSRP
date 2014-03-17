//
//  SRP6Parameters.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "SRP6Parameters.h"
#import "BigInteger.h"

@implementation SRP6Parameters

- (id) initWithN: (NSString*) N g: (NSString*) g {
    self = [super init];
    if (self) {
        _N = [[BigInteger alloc] initWithString: N radix: 16];
        _g = [[BigInteger alloc] initWithString: g radix: 16];
    }
    return self;
}

@end
