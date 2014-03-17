//
//  BignNumUtilities.h
//  VisualHash
//
//  Created by David Siegel on 10.03.14.
//  Copyright (c) 2014 David Siegel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "openssl/bn.h"

#import "NSData+HexString.h"

NSString * DSNSStringFromBIGNUM(BIGNUM * a, unsigned radix);

BIGNUM * DSBIGNUMFromNSData(NSData * data);

BIGNUM * DSBIGNUMFromNSString(NSString * string, unsigned radix);

@interface NSData (BIGNUM)

+ (NSData*) dataWithBIGNUM: (BIGNUM*) n;


@end