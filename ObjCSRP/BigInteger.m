//
//  BigInteger.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "BigInteger.h"

#import "BigNumUtilities.h"

@implementation BigInteger

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
    NSMutableData * data = [NSMutableData dataWithLength: length];
    BN_bn2bin(a.n, data.mutableBytes + (length - a.length));
    return data;
}


@end