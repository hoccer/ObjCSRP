//
//  NSData+HexString.m
//  HoccerXO
//
//  Created by David Siegel on 29.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import "NSData+HexString.h"

@implementation NSData (HexString)

+ (id)dataWithHexadecimalString:(NSString *)inString {
    if (inString == nil) {
        return nil;
    }
    unsigned char byte;
    char tmp_buffer[3] = {'\0','\0','\0'};
    char * buffer = malloc([inString length] / 2);
    for (int i=0; i < [inString length]/2; i++) {
        tmp_buffer[0] = [inString characterAtIndex:i*2];
        tmp_buffer[1] = [inString characterAtIndex:i*2+1];
        byte = strtol(tmp_buffer, NULL, 16);
        buffer[i] = byte;
    }
    return [NSData dataWithBytesNoCopy: buffer length: [inString length] / 2];
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
