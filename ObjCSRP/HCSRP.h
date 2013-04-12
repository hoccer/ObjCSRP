//
//  ObjCSRP.h
//  ObjCSRP
//
//  Created by David Siegel on 02.04.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "srp.h"

@interface HCSRP : NSObject

@property (nonatomic,assign) SRP_HashAlgorithm hashAlgorithm;
@property (nonatomic,assign) SRP_NGType primeAndGenerator;

- (id) initWithHashAlgorithm: (SRP_HashAlgorithm) hashAlgorithm primeAndGenerator: (SRP_NGType) primeAndGenerator;

@end

@interface HCSRPUser : HCSRP
{
    struct SRPUser * _user;
}

@property (nonatomic,readonly) NSString * username;
@property (nonatomic,readonly) BOOL       isAuthenticated;

- (id) initWithUserName: (NSString*) username andPassword: (NSString*) password;

- (id) initWithUserName: (NSString*) username andPassword: (NSString*) password
          hashAlgorithm: (SRP_HashAlgorithm) hashAlgorithm primeAndGenerator: (SRP_NGType) primeAndGenerator;

- (void)    salt: (NSData**) salt andVerificationKey: (NSData**) verificationKey forPassword: (NSString*) password;
- (NSData*) startAuthentication;
- (NSData*) processChallenge: (NSData*) salt B: (NSData*) b;
- (void)    verifySession: (NSData*) hamk;

@end