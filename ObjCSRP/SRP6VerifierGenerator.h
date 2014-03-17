//
//  SRP6VerifierGenerator.h
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SRP6.h"
#import "Digest.h"

@class BigInteger;

@interface SRP6VerifierGenerator : SRP6

- (NSData*) generateVerifierWithSalt: (NSData*) salt username: (NSString*) username password: (NSString*) password;

@end
