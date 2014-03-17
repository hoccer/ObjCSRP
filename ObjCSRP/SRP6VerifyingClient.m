//
//  SRP6VerifyingClient.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "SRP6VerifyingClient.h"
#import "BigInteger.h"

@interface SRP6VerifyingClient ()
{
    BigInteger * _a;
    BigInteger * _A;
}
@end

@implementation SRP6VerifyingClient

- (NSData*) generateCredentialsWithSalt: (NSData*) salt username: (NSString*) username password: (NSString*) password {
    _a = [self selectPrivateValue];

    BigIntCtx * ctx = [BigIntCtx bigIntCtx];
    _A = [BigInteger bigInteger];
    BN_mod_exp(_A.n, _g.n, _a.n, _N.n, ctx.c);
    return [NSData dataWithBigInteger: _A];
}

@end
