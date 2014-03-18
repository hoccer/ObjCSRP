//
//  BigInteger.h
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "openssl/bn.h"

@interface BigInteger : NSObject

- (id) initWithString: (NSString*) string radix: (int) radix;

- (BOOL) isEqualToBigInt: (BigInteger*) other;

@property (nonatomic,readonly) BIGNUM * n;
@property (nonatomic,readonly) NSUInteger length;

+ (BigInteger*) bigInteger;
+ (BigInteger*) bigIntegerWithBigInteger: (BigInteger*) other;
+ (BigInteger*) bigIntegerWithString: (NSString*) string radix: (int) radix;
+ (BigInteger*) bigIntegerWithData: (NSData*) data;
+ (BigInteger*) bigIntegerWithValue: (NSInteger) value;

- (BigInteger*) multiply: (BigInteger*) f;
- (BigInteger*) add: (BigInteger*) b;
- (BigInteger*) mod: (BigInteger*) m;

- (BigInteger*) multiply: (BigInteger*) f modulo: (BigInteger*) m;
- (BigInteger*) power: (BigInteger*) y modulo: (BigInteger*) m;
- (BigInteger*) add: (BigInteger*) b modulo: (BigInteger*) m;
- (BigInteger*) subtract: (BigInteger*) b modulo: (BigInteger*) m;

- (BOOL) isZero;

@end

@interface BigIntCtx : NSObject

@property (nonatomic,readonly) BN_CTX * c;

+ (BigIntCtx*) bigIntCtx;

@end

@interface NSData (BigInteger)

+ (NSData*) dataWithBigInteger: (BigInteger*) a;
+ (NSData*) dataWithBigInteger: (BigInteger*) a leftPaddedToLength: (NSUInteger) length;

@end
