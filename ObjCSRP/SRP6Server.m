//
//  SRP6VerifyingServer.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "SRP6Server.h"

#import "BigInteger.h"

@interface SRP6Server ()
{
    BigInteger * _b;
    BigInteger * _B;
    BigInteger * _v;
}
@end

@implementation SRP6Server

- (NSData*) generateCredentialsWithSalt: (NSData*) salt username: (NSString*) username verifier: (NSData*) verifier {
    _b = [self selectPrivateValue];

    BigInteger * k = [self k];

    BigIntCtx * ctx = [BigIntCtx bigIntCtx];
    _v = [BigInteger bigIntegerWithData: verifier];
    BigInteger * tmp1 = [BigInteger bigInteger];
    BigInteger * tmp2 = [BigInteger bigInteger];
    BN_mod_mul(tmp1.n, k.n, _v.n, _N.n, ctx.c);
    BN_mod_exp(tmp2.n, _g.n, _b.n, _N.n, ctx.c);
    _B = [BigInteger bigInteger];
    BN_mod_add(_B.n, tmp1.n, tmp2.n, _N.n, ctx.c);
    return [NSData dataWithBigInteger: _B];
}

- (BigInteger*) calculateSecret: (NSData*) clientA {
    BigIntCtx * ctx = [BigIntCtx bigIntCtx];
    BigInteger * A = [BigInteger bigIntegerWithData: clientA];
    BigInteger * u = [self uWithA: A andB: _B];
    BigInteger * tmp1 = [BigInteger bigInteger];
    BigInteger * tmp2 = [BigInteger bigInteger];
    BigInteger * S = [BigInteger bigInteger];

    BN_mod_exp(tmp1.n, _v.n, u.n, _N.n, ctx.c);
    BN_mod_mul(tmp2.n, A.n, tmp1.n, _N.n, ctx.c);
    BN_mod_exp(S.n, tmp2.n, _b.n, _N.n, ctx.c);
    return S;
}

@end
