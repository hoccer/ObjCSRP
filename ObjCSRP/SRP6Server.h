//
//  SRP6VerifyingServer.h
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "SRP6.h"

@interface SRP6Server : SRP6

- (NSData*) generateCredentialsWithSalt: (NSData*) salt username: (NSString*) username verifier: (NSData*) verifier;
- (BigInteger*) calculateSecret: (NSData*) clientA;

@end
