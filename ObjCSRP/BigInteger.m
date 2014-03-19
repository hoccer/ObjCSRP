//
//  BigInteger.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "BigInteger.h"

#import "BigNumUtilities.h"

#import "openssl/bn.h"

static BN_CTX * ctx;

@implementation BigInteger

+ (void) initialize {
    ctx = BN_CTX_new();
}

- (id) init {
    self = [super init];
    if (self) {
        _n = BN_new();
    }
    return self;
}

- (id) initWithString: (NSString*) string radix: (int) radix {
    self = [super init];
    if (self) {
        _n = DSBIGNUMFromNSString(string, radix);
    }
    return self;
}

- (id) initWithData: (NSData*) data {
    self = [super init];
    if (self) {
        _n = DSBIGNUMFromNSData(data);
    }
    return self;
}

- (NSUInteger) length {
    return BN_num_bytes(_n);
}

- (void) dealloc {
    BN_free(_n);
}

- (BOOL) isEqualToBigInt: (BigInteger*) other {
    return BN_cmp(_n, other.n) == 0;
}

+ (BigInteger*) bigInteger {
    return [[BigInteger alloc] init];
}

+ (BigInteger*) bigIntegerWithBigInteger: (BigInteger*) other {
    BigInteger * n = [[BigInteger alloc] init];
    BN_copy(n.n, other.n);
    return n;
}

+ (BigInteger*) bigIntegerWithString: (NSString*) string radix: (int) radix {
    return [[BigInteger alloc] initWithString: string radix: radix];
}

+ (BigInteger*) bigIntegerWithData: (NSData*) data {
    return [[BigInteger alloc] initWithData: data];
}

+ (BigInteger*) bigIntegerWithValue: (NSInteger) value {
    BigInteger * n = [[BigInteger alloc] init];
    BN_set_word(n.n, value);
    return n;
}

#pragma mark - Artihmetic Operations

- (BigInteger*) times: (BigInteger*) f {
    BigInteger * result = [BigInteger bigInteger];
    BN_mul(result.n, self.n, f.n, ctx);
    return result;
}

- (BigInteger*) plus: (BigInteger*) b {
    BigInteger * result = [BigInteger bigInteger];
    BN_add(result.n, self.n, b.n);
    return result;
}

- (BigInteger*) modulo: (BigInteger*) m {
    BigInteger * remainder = [BigInteger bigInteger];
    BN_mod(remainder.n, self.n, m.n, ctx);
    return remainder;
}

- (BigInteger*) times: (BigInteger*) f modulo: (BigInteger*) m {
    BigInteger * result = [BigInteger bigInteger];
    BN_mod_mul(result.n, self.n, f.n, m.n, ctx);
    return result;
}

- (BigInteger*) power: (BigInteger*) y modulo: (BigInteger*) m {
    BigInteger * result = [BigInteger bigInteger];
    BN_mod_exp(result.n, self.n, y.n, m.n, ctx);
    return result;
}

- (BigInteger*) plus: (BigInteger*) b modulo: (BigInteger*) m {
    BigInteger * result = [BigInteger bigInteger];
    BN_mod_add(result.n, self.n, b.n, m.n, ctx);
    return result;
}

- (BigInteger*) minus: (BigInteger*) b modulo: (BigInteger*) m {
    BigInteger * result = [BigInteger bigInteger];
    BN_mod_sub(result.n, self.n, b.n, m.n, ctx);
    return result;
}


- (BOOL) isZero  {
    return BN_is_zero(self.n);
}


@end

@implementation BigIntCtx

- (id) init {
    self = [super init];
    if (self) {
        _c = BN_CTX_new();
    }
    return self;
}

- (void) dealloc {
    BN_CTX_free(_c);
}

+ (BigIntCtx*) bigIntCtx {
    return [[BigIntCtx alloc] init];
}

@end

@implementation NSData (BigInteger)

+ (NSData*) dataWithBigInteger: (BigInteger*) a {
    return [NSData dataWithBIGNUM: a.n];
}

+ (NSData*) dataWithBigInteger: (BigInteger*) a leftPaddedToLength: (NSUInteger) length {
    if (a.length < length) {
        NSMutableData * data = [NSMutableData dataWithLength: length];
        BN_bn2bin(a.n, data.mutableBytes + (length - a.length));
        return data;
    }
    return [NSData dataWithBigInteger: a];
}


@end