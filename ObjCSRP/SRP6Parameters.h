//
//  SRP6Parameters.h
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BigInteger;

@interface SRP6Parameters : NSObject

- (id) initWithN: (NSString*) N g: (NSString*) g;

@property (nonatomic,readonly) BigInteger * N;
@property (nonatomic,readonly) BigInteger * g;

@end
