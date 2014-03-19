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
    NSString   * _password;
    NSData     * _M1;
}
@end

@implementation SRP6Client

- (NSData*) generateCredentialsWithSalt: (NSData*) salt username: (NSString*) username password: (NSString*) password {
    _salt = salt;
    _username = username;
    _password = password;
    _a = [self selectPrivateValue];
    _A = [_g power: _a modulo: _N];
    return [NSData dataWithBigInteger: _A];
}

- (NSData*) calculateSecret:(NSData *)serverB error: (NSError**) error {
    _B = [self validatePublicValue: [BigInteger bigIntegerWithData:serverB] error: error];
    if (_B == nil) {
        return nil;
    }
    BigInteger * x = [self xWithSalt: _salt username: _username password: _password];
    BigInteger * k = [self k];
    BigInteger * u = [self uWithA: _A andB: _B];

    BigInteger * tmp = [_B minus: [k times: [_g power: x modulo: _N] modulo: _N] modulo: _N];
    BigInteger * S   = [tmp power: [[u times: x] plus: _a] modulo: _N];

    _K = [self hashNumber: S];

    return [NSData dataWithBigInteger: S];
}

- (NSData*) calculateVerifier {
    _M1 = [self calculateM1];
    return _M1;
}

- (NSData*) verifyServer: (NSData*) serverM2 error: (NSError **) error {
    NSData * M2 = [self calculateM2: _M1];
    if ([M2 isEqualToData: serverM2]) {
        return _K;
    }
    if (error) {
        NSString * description = NSLocalizedString(@"Authentication failed", nil);
        NSString * reason = NSLocalizedString(@"The servers verifier M2 did not match the local version.", nil);
        *error = [NSError errorWithDomain: SRP6ProtocolErrorDomain
                                     code: SRP6_KEY_VERIFICATION_ERROR
                                 userInfo: @{ NSLocalizedDescriptionKey: description,
                                              NSLocalizedFailureReasonErrorKey: reason,
                                              }];
    }
    return nil;
}

@end
