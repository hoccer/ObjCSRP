//
//  SRP6.h
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRP6Parameters.h"
#import "Digest.h"

typedef enum SRP6Hashes {
    SRP6_SHA1,
    SRP6_SHA224,
    SRP6_SHA256,
    SRP6_SHA384,
    SRP6_SHA512
} SRP6Hash;

typedef enum SRP6Ngs {
    SRP_NG_1024,
    SRP_NG_2048,
    SRP_NG_4096,
    SRP_NG_8192
} SRP6Ng;

@interface SRP6 : NSObject
{
    id<SRPDigest> _digest;
    BigInteger *  _N;
    BigInteger *  _g;
}

- (id) initWithDigest: (id<SRPDigest>) digest N: (BigInteger*) N g: (BigInteger*) g;
- (BigInteger*) selectPrivateValue;

+ (SRP6Parameters*) CONSTANTS_1024;
+ (SRP6Parameters*) CONSTANTS_2048;
+ (SRP6Parameters*) CONSTANTS_4096;
+ (SRP6Parameters*) CONSTANTS_8192;

@end
