//
//  NSData+HexString.h
//  HoccerXO
//
//  Created by David Siegel on 29.03.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HexString)

+ (id)dataWithHexadecimalString:(NSString *)inString NS_RETURNS_RETAINED;
- (NSString *)hexadecimalString;

@end
