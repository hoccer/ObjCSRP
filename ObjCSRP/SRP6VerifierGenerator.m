//
//  SRP6VerifierGenerator.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "SRP6VerifierGenerator.h"

#import "BigInteger.h"

@interface SRP6VerifierGenerator ()
@end

@implementation SRP6VerifierGenerator

- (NSData*) generateVerifierWithSalt: (NSData*) salt username: (NSString*) username password: (NSString*) password {
    /*
    if (!salt) {
        NSMutableData * randomSalt = [NSMutableData dataWithLength: _digest.length];
        int err = SecRandomCopyBytes(kSecRandomDefault, randomSalt.length, randomSalt.mutableBytes);
        if (err != 0) {
            NSLog(@"RandomBytes; RNG error = %d", errno);
        }
        salt = randomSalt;
    }
*/
    BigInteger * x = [self xWithSalt: salt username: username password: password];
    BigInteger * v = [BigInteger bigInteger];
    BigIntCtx  * ctx = [BigIntCtx bigIntCtx];
    BN_mod_exp(v.n, _g.n, x.n, _N.n, ctx.c);
    return [NSData dataWithBigInteger: v];
}

@end