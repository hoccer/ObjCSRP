//
//  SRP6VerifyingClient.h
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "SRP6.h"

@interface SRP6Client : SRP6

- (NSData*) generateCredentialsWithSalt: (NSData*) salt username: (NSString*) username password: (NSString*) password;
- (NSData*) calculateSecret: (NSData*) serverB;
- (NSData*) calculateVerifier;
- (void) verifyServer: (NSData*) serverM2;

@end
