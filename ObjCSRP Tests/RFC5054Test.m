//
//  SRP6RFC5054Test.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SRP6VerifierGenerator.h"
#import "SRP6Server.h"
#import "SRP6Client.h"
#import "NSData+HexString.h"
#import "BigInteger.h"

static NSString * const username = @"alice";
static NSString * const password = @"password123";
static NSString * const salt_HEX = @"BEB25379D1A8581EB5A727673A2441EE";
static NSString * const verifier_HEX =
    @"7E273DE8696FFC4F4E337D05B4B375BEB0DDE1569E8FA00A9886D812"
    @"9BADA1F1822223CA1A605B530E379BA4729FDC59F105B4787E5186F5"
    @"C671085A1447B52A48CF1970B4FB6F8400BBF4CEBFBB168152E08AB5"
    @"EA53D15C1AFF87B2B9DA6E04E058AD51CC72BFC9033B564E26480D78"
    @"E955A5E29E7AB245DB2BE315E2099AFB";
static NSString * const a_HEX =
    @"60975527035CF2AD1989806F0407210BC81EDC04E2762A56AFD529DDDA2D4393";
static NSString * const A_HEX =
    @"61D5E490F6F1B79547B0704C436F523DD0E560F0C64115BB72557EC4"
    @"4352E8903211C04692272D8B2D1A5358A2CF1B6E0BFCF99F921530EC"
    @"8E39356179EAE45E42BA92AEACED825171E1E8B9AF6D9C03E1327F44"
    @"BE087EF06530E69F66615261EEF54073CA11CF5858F0EDFDFE15EFEA"
    @"B349EF5D76988A3672FAC47B0769447B";
static NSString * const b_HEX =
    @"E487CB59D31AC550471E81F00F6928E01DDA08E974A004F49E61F5D105284D20";
static NSString * const B_HEX =
    @"BD0C61512C692C0CB6D041FA01BB152D4916A1E77AF46AE105393011"
    @"BAF38964DC46A0670DD125B95A981652236F99D9B681CBF87837EC99"
    @"6C6DA04453728610D0C6DDB58B318885D7D82C7F8DEB75CE7BD4FBAA"
    @"37089E6F9C6059F388838E7A00030B331EB76840910440B1B27AAEAE"
    @"EB4012B7D7665238A8E3FB004B117B58";


// Non-RFC reference values generated using @promovicz test
// ... but with leading zeros removed [DS]
static NSString * const S_HEX =
    @"b0dc82babcf30674ae450c0287745e7990a3381f63b387aaf271a10d"
    @"233861e359b48220f7c4693c9ae12b0a6f67809f0876e2d013800d6c"
    @"41bb59b6d5979b5c00a172b4a2a5903a0bdcaf8a709585eb2afafa8f"
    @"3499b200210dcc1f10eb33943cd67fc88a2f39a4be5bec4ec0a3212d"
    @"c346d7e474b29ede8a469ffeca686e5a";
static NSString * const M1_HEX =
    @"3f3bc67169ea71302599cf1b0f5d408b7b65d347";
static NSString * const M2_HEX =
    @"9cab3c575a11de37d3ac1421a9f009236a48eb55";

@interface RFC5054Test : XCTestCase
@end

@interface MockClient : SRP6Client
@end

@implementation MockClient
- (BigInteger*) selectPrivateValue {
    return [BigInteger bigIntegerWithString: a_HEX radix: 16];
}
@end

@interface MockServer : SRP6Server
@end

@implementation MockServer
- (BigInteger*) selectPrivateValue {
    return [BigInteger bigIntegerWithString: b_HEX radix: 16];
}
@end

@implementation RFC5054Test

- (void)testVector {
    DigestSHA1 * digest = [DigestSHA1 digest];
    SRP6Parameters * params = SRP6.CONSTANTS_1024;

    NSData * salt = [NSData dataWithHexadecimalString: salt_HEX];

    SRP6VerifierGenerator * verifierGenerator = [[SRP6VerifierGenerator alloc] initWithDigest: digest N: params.N g: params.g];
    NSData * verifier = [verifierGenerator generateVerifierWithSalt: salt username: username password: password];
    NSData * verifierRef = [NSData dataWithHexadecimalString: verifier_HEX];
    XCTAssert([verifier isEqualToData: verifierRef], @"Verifier must match reference value");

    MockClient * client = [[MockClient alloc] initWithDigest: digest N: params.N g: params.g];
    MockServer * server = [[MockServer alloc] initWithDigest: digest N: params.N g: params.g];

    NSData * A = [client generateCredentialsWithSalt: salt username: username password: password];
    NSData * ARef = [NSData dataWithHexadecimalString: A_HEX];
    XCTAssert([A isEqualToData: ARef], @"Client credentials must match reference value");

    NSData * B = [server generateCredentialsWithSalt: salt username: username verifier: verifier];
    NSData * BRef = [NSData dataWithHexadecimalString: B_HEX];
    XCTAssert([B isEqualToData: BRef], @"Server credentials must match reference value");

    NSError * error;
    NSData * SRef = [NSData dataWithHexadecimalString: S_HEX];
    NSData * serverS = [server calculateSecret: A error: &error];
    XCTAssert(serverS, @"server secret calculation failed: %@", error);
    XCTAssert([serverS isEqualToData: SRef], @"Server secret must match reference value");

    NSData * clientS = [client calculateSecret: B error: &error];
    XCTAssert(clientS, @"client secret calculation failed: %@", error);
    XCTAssert([clientS isEqualToData: SRef], @"Client secret must match reference value");

    NSData * M1 = [client calculateVerifier];
    NSData * M1Ref = [NSData dataWithHexadecimalString: M1_HEX];
    XCTAssert([M1 isEqualToData: M1Ref], @"Client M1 must match reference value");

    NSData * M2 = [server verifyClient: M1 error: &error];
    NSData * M2Ref = [NSData dataWithHexadecimalString: M2_HEX];
    XCTAssert(M2, @"client verification failed: %@", error);
    XCTAssert([M2 isEqualToData: M2Ref], @"Server M2 must match reference value");

    NSData * K = [client verifyServer: M2 error: &error];
    XCTAssert( K, @"server verification failed: %@", error);

    XCTAssert([K isEqualToData: server.sessionKey], @"Session keys must match");
}

@end
