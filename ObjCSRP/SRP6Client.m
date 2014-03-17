//
//  SRP6VerifyingClient.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "SRP6Client.h"
#import "BigInteger.h"

@interface SRP6Client ()
{
    BigInteger * _a;
    BigInteger * _A;
    NSData     * _salt;
    NSString   * _username;
    NSString   * _password;
}
@end

@implementation SRP6Client

- (NSData*) generateCredentialsWithSalt: (NSData*) salt username: (NSString*) username password: (NSString*) password {
    _salt = salt;
    _username = username;
    _password = password;
    _a = [self selectPrivateValue];

    BigIntCtx * ctx = [BigIntCtx bigIntCtx];
    _A = [BigInteger bigInteger];
    BN_mod_exp(_A.n, _g.n, _a.n, _N.n, ctx.c);
    return [NSData dataWithBigInteger: _A];
}

- (BigInteger*) calculateSecret:(NSData *)serverB {
    BigInteger * B = [BigInteger bigIntegerWithData:serverB];
    BigInteger * x = [self xWithSalt: _salt username: _username password: _password];
    BigInteger * k = [self k];
    BigInteger * u = [self uWithA: _A andB: B];

    BigIntCtx * ctx   = [BigIntCtx bigIntCtx];
    BigInteger * tmp1 = [BigInteger bigInteger];
    BigInteger * tmp2 = [BigInteger bigInteger];
    BigInteger * tmp3 = [BigInteger bigInteger];
    BigInteger * S    = [BigInteger bigInteger];

    BN_mul(tmp1.n, u.n, x.n, ctx.c);
    BN_add(tmp2.n, _a.n, tmp1.n);
    BN_mod_exp(tmp1.n, _g.n, x.n, _N.n, ctx.c);
    BN_mod_mul(tmp3.n, k.n, tmp1.n, _N.n, ctx.c);
    BN_mod_sub(tmp1.n, B.n, tmp3.n, _N.n, ctx.c);
    BN_mod_exp(S.n, tmp1.n, tmp2.n, _N.n, ctx.c);
    return S;
}

@end
