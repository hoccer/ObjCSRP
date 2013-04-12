//
//  ObjCSRP.m
//  ObjCSRP
//
//  Created by David Siegel on 02.04.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "HCSRP.h"

@implementation HCSRP

- (id) init {
    self = [super init];
    if (self != nil) {
        self.hashAlgorithm     = SRP_SHA256;
        self.primeAndGenerator = SRP_NG_2048;
    }
    return self;
}

- (id) initWithHashAlgorithm: (SRP_HashAlgorithm) hashAlgorithm primeAndGenerator: (SRP_NGType) primeAndGenerator {
    self = [super init];
    if (self != nil) {
        self.hashAlgorithm     = hashAlgorithm;
        self.primeAndGenerator = primeAndGenerator;
    }
    return self;
}

@end


@implementation HCSRPUser

- (id) initWithUserName: (NSString*) username andPassword: (NSString*) password {
    self = [super init];
    if (self != nil) {
        [self commonInit: username password: password];
    }
    return self;
}

- (id) initWithUserName: (NSString*) username andPassword: (NSString*) password
          hashAlgorithm: (SRP_HashAlgorithm) hashAlgorithm primeAndGenerator: (SRP_NGType) primeAndGenerator {
    self = [super initWithHashAlgorithm: hashAlgorithm primeAndGenerator: primeAndGenerator];
    if (self != nil) {
        [self commonInit: username password: password];
    }
    return self;
}

- (void) commonInit: (NSString*) username password: (NSString*) password {
    _user = srp_user_new(self.hashAlgorithm, self.primeAndGenerator, [username UTF8String], (const unsigned char*)[password UTF8String], [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding], NULL, NULL);
}

- (void) salt: (NSData**) salt andVerificationKey: (NSData**) verificationKey forPassword: (NSString*) password{
    const unsigned char * saltBytes;
    int saltLength;
    const unsigned char * verificationKeyBytes;
    int verificationKeyLength;
    srp_create_salted_verification_key(self.hashAlgorithm, self.primeAndGenerator, [self.username UTF8String],
                                       (const unsigned char *)[password UTF8String], [password lengthOfBytesUsingEncoding: NSUTF8StringEncoding],
                                       & saltBytes, & saltLength, & verificationKeyBytes, & verificationKeyLength,
                                       NULL, NULL);
    *salt = [NSData dataWithBytesNoCopy: (void*)saltBytes length: saltLength];
    *verificationKey = [NSData dataWithBytesNoCopy: (void*)verificationKeyBytes length: verificationKeyLength];
}

- (NSData*) startAuthentication {
    const unsigned char * a;
    int aLength;
    const char * unusedUsername;
    srp_user_start_authentication(_user, &unusedUsername, &a, &aLength);
    return [NSData dataWithBytesNoCopy: (void*) a length: aLength];
}

- (NSData*) processChallenge:(NSData *)salt B:(NSData *)b {
    const unsigned char * mBytes;
    int mLength;
    srp_user_process_challenge( _user, salt.bytes, salt.length, b.bytes, b.length, &mBytes, &mLength);
    if ( ! mBytes) {
        return nil;
    }
    return [NSData dataWithBytesNoCopy: (void*)mBytes length: mLength];
}

- (void) verifySession: (NSData*) hamk {
    srp_user_verify_session( _user, [hamk bytes] );
}

- (BOOL) isAuthenticated {
    return srp_user_is_authenticated(_user);
}

- (NSString*) username {
    return [NSString stringWithCString: srp_user_get_username(_user) encoding: NSUTF8StringEncoding];
}


- (void) dealloc {
    srp_user_delete(_user);
    _user = NULL;
}

@end
