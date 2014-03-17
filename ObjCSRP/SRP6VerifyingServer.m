//
//  SRP6VerifyingServer.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "SRP6VerifyingServer.h"

#import "BigInteger.h"

@interface SRP6VerifyingServer ()
{
    BigInteger * _b;
    BigInteger * _B;
}
@end

@implementation SRP6VerifyingServer

- (NSData*) generateCredentialsWithSalt: (NSData*) salt username: (NSString*) username verifier: (NSData*) verifier {
    _b = [self selectPrivateValue];

    [_digest update: [NSData dataWithBigInteger: _N]];
    [_digest update: [NSData dataWithBigInteger: _g leftPaddedToLength: _N.length]];
    BigInteger * k = [BigInteger bigIntegerWithData: [_digest doFinal]];

    BigIntCtx * ctx = [BigIntCtx bigIntCtx];
    BigInteger * v = [BigInteger bigIntegerWithData: verifier];
    BigInteger * tmp1 = [BigInteger bigInteger];
    BigInteger * tmp2 = [BigInteger bigInteger];
    BN_mod_mul(tmp1.n, k.n, v.n, _N.n, ctx.c);
    BN_mod_exp(tmp2.n, _g.n, _b.n, _N.n, ctx.c);
    _B = [BigInteger bigInteger];
    BN_mod_add(_B.n, tmp1.n, tmp2.n, _N.n, ctx.c);
    return [NSData dataWithBigInteger: _B];
}

@end
