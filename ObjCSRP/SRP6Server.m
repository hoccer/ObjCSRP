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
    BigInteger * _v;
}
@end

@implementation SRP6Server

- (NSData*) generateCredentialsWithSalt: (NSData*) salt username: (NSString*) username verifier: (NSData*) verifier {
    _username = username;
    _salt = salt;
    _b = [self selectPrivateValue];

    BigInteger * k = [self k];
    _v = [BigInteger bigIntegerWithData: verifier];

    BigInteger * tmp1 = [k times: _v modulo: _N];
    BigInteger * tmp2 = [_g power: _b modulo: _N];
    _B = [tmp1 plus: tmp2 modulo: _N];
    return [NSData dataWithBigInteger: _B];
}

- (NSData*) calculateSecret: (NSData*) clientA error: (NSError**) error {
    _A = [self validatePublicValue: [BigInteger bigIntegerWithData: clientA] error: error];
    if ( ! _A) {
        return nil;
    }
    BigInteger * u = [self uWithA: _A andB: _B];
    BigInteger * tmp = [_A times: [_v power: u modulo: _N] modulo: _N];
    BigInteger * S = [tmp power: _b modulo: _N];

    _K = [self hashNumber: S];

    return [NSData dataWithBigInteger: S];
}

- (NSData*) verifyClient: (NSData*) clientM1 error: (NSError**) error{
    NSData * M1 = [self calculateM1];
    if ([M1 isEqualToData: clientM1]) {
        return [self calculateM2: M1];
    }
    if (error) {
        NSString * description = NSLocalizedString(@"Authentication failed", nil);
        NSString * reason = NSLocalizedString(@"The clients verifier M1 did not match the local version.", nil);
        *error = [NSError errorWithDomain: SRP6ProtocolErrorDomain
                                     code: SRP6_KEY_VERIFICATION_ERROR
                                 userInfo: @{ NSLocalizedDescriptionKey: description,
                                              NSLocalizedFailureReasonErrorKey: reason,
                                              }];
    }
    return nil;
}

@end
