//
//  Digest.h
//  ObjCSRP
//
//  Created by David Siegel on 17.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SRPDigest <NSObject>

- (void) update: (NSData*) data;
- (NSData*) doFinal;

@property (nonatomic,readonly) NSUInteger length;
@end

@interface DigestSHA1 : NSObject <SRPDigest>
+ (id) digest;
@end

@interface DigestSHA224 : NSObject <SRPDigest>
+ (id) digest;
@end

@interface DigestSHA256 : NSObject <SRPDigest>
+ (id) digest;
@end

@interface DigestSHA384 : NSObject <SRPDigest>
+ (id) digest;
@end

@interface DigestSHA512 : NSObject <SRPDigest>
+ (id) digest;
@end
