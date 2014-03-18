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

- (NSData*) calculateSecret:(NSData *)serverB {
    _B = [self validatePublicValue: [BigInteger bigIntegerWithData:serverB]];
    BigInteger * x = [self xWithSalt: _salt username: _username password: _password];
    BigInteger * k = [self k];
    BigInteger * u = [self uWithA: _A andB: _B];

    BigInteger * tmp = [_B subtract: [k multiply: [_g power: x modulo: _N] modulo: _N] modulo: _N];
    BigInteger * S   = [tmp power: [[u multiply: x] add: _a] modulo: _N];

    _K = [self hashNumber: S];

    return [NSData dataWithBigInteger: S];
}

- (NSData*) calculateVerifier {
    _M1 = [self calculateM1];
    return _M1;
}

- (void) verifyServer: (NSData*) serverM2 {
    NSData * M2 = [self calculateM2: _M1];
    if (! [M2 isEqualToData: serverM2]) {
        @throw [SRP6Exception exceptionWithName: @"ServerVerificationError" reason: @"Server verifier M2 is bogus" userInfo: nil];
    }
}

@end
