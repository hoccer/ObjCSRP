//
//  Digest.m
//  ObjCSRP
//
//  Created by David Siegel on 17.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "Digest.h"

#include <openssl/sha.h>

//=== SHA1 =====================================================================

@interface DigestSHA1 ()
{
    SHA_CTX _ctx;
}
@end

@implementation DigestSHA1

- (id) init {
    self = [super init];
    if (self) {
        SHA1_Init(&_ctx);
    }
    return self;
}

- (NSUInteger) length {
    return SHA_DIGEST_LENGTH;
}

- (void) update:(NSData *)data {
    SHA1_Update(&_ctx, data.bytes, data.length);
}

- (NSData*) doFinal {
    NSMutableData * digest = [NSMutableData dataWithLength: self.length];
    SHA1_Final(digest.mutableBytes, &_ctx);
    SHA1_Init(&_ctx);
    return digest;
}

+ (id) digest {
    return [[DigestSHA1 alloc] init];
}

@end

//=== SHA224 ===================================================================

@interface DigestSHA224 ()
{
    SHA256_CTX _ctx;
}
@end

@implementation DigestSHA224

- (id) init {
    self = [super init];
    if (self) {
        SHA224_Init(&_ctx);
    }
    return self;
}

- (NSUInteger) length {
    return SHA224_DIGEST_LENGTH;
}

- (void) update:(NSData *)data {
    SHA224_Update(&_ctx, data.bytes, data.length);
}

- (NSData*) doFinal {
    NSMutableData * digest = [NSMutableData dataWithLength: self.length];
    SHA224_Final(digest.mutableBytes, &_ctx);
    SHA224_Init(&_ctx);
    return digest;
}

+ (id) digest {
    return [[DigestSHA224 alloc] init];
}

@end

//=== SHA256 ===================================================================

@interface DigestSHA256 ()
{
    SHA256_CTX _ctx;
}
@end

@implementation DigestSHA256

- (id) init {
    self = [super init];
    if (self) {
        SHA256_Init(&_ctx);
    }
    return self;
}

- (NSUInteger) length {
    return SHA256_DIGEST_LENGTH;
}

- (void) update:(NSData *)data {
    SHA256_Update(&_ctx, data.bytes, data.length);
}

- (NSData*) doFinal {
    NSMutableData * digest = [NSMutableData dataWithLength: self.length];
    SHA256_Final(digest.mutableBytes, &_ctx);
    SHA256_Init(&_ctx);
    return digest;
}

+ (id) digest {
    return [[DigestSHA256 alloc] init];
}

@end

//=== SHA384 ===================================================================

@interface DigestSHA384 ()
{
    SHA512_CTX _ctx;
}
@end

@implementation DigestSHA384

- (id) init {
    self = [super init];
    if (self) {
        SHA384_Init(&_ctx);
    }
    return self;
}

- (NSUInteger) length {
    return SHA384_DIGEST_LENGTH;
}

- (void) update:(NSData *)data {
    SHA384_Update(&_ctx, data.bytes, data.length);
}

- (NSData*) doFinal {
    NSMutableData * digest = [NSMutableData dataWithLength: self.length];
    SHA384_Final(digest.mutableBytes, &_ctx);
    SHA384_Init(&_ctx);
    return digest;
}

+ (id) digest {
    return [[DigestSHA384 alloc] init];
}

@end

//=== SHA512 ===================================================================

@interface DigestSHA512 ()
{
    SHA512_CTX _ctx;
}
@end

@implementation DigestSHA512

- (id) init {
    self = [super init];
    if (self) {
        SHA512_Init(&_ctx);
    }
    return self;
}

- (NSUInteger) length {
    return SHA512_DIGEST_LENGTH;
}

- (void) update:(NSData *)data {
    SHA512_Update(&_ctx, data.bytes, data.length);
}

- (NSData*) doFinal {
    NSMutableData * digest = [NSMutableData dataWithLength: self.length];
    SHA512_Final(digest.mutableBytes, &_ctx);
    SHA512_Init(&_ctx);
    return digest;
}

+ (id) digest {
    return [[DigestSHA512 alloc] init];
}

@end
