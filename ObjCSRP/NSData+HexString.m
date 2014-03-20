//
//  NSData+HexString.m
//  HoccerXO
//
//  Created by David Siegel on 29.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "NSData+HexString.h"

unsigned char parseNibble(unichar c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    } else if (c >= 'a' && c <= 'f') {
        return (c - 'a') + 10;
    } else if (c >= 'A' && c <= 'F') {
        return (c - 'A') + 10;
    } else {
        @throw [NSException exceptionWithName: @"Input invalid" reason: @"string is not a hex string" userInfo: nil];
    }
}

@implementation NSData (HexString)

+ (id)dataWithHexadecimalString:(NSString *)inString {
    if (inString == nil) {
        return nil;
    }
    unsigned char byte = 0;
    unsigned char nibble = 0;

    NSUInteger size = inString.length / 2 + (inString.length % 2 ? 1 : 0);
    NSMutableData * data = [NSMutableData dataWithLength: size];
    unsigned char * out = data.mutableBytes;
    for (NSUInteger i = 0; i < inString.length; i++) {
        nibble = parseNibble([inString characterAtIndex:i]);
        byte = (byte << 4) | nibble;
        if ((i % 2 && inString.length % 2 == 0) || (i % 2 == 0 && inString.length % 2)) {
            *out++ = byte;
            byte = 0;
        }
    }
    if (inString.length % 2) {
        *out = byte;
    }
    return data;
}


- (NSString *)hexadecimalString {
    if (self == nil) {
        return nil;
    }
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];

    if (!dataBuffer) {
        return [NSString string];
    }

    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (NSUInteger i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02x", (unsigned int)dataBuffer[i]]];
    }

    return [hexString copy];
}
@end
