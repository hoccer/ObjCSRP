//
//  FunctionalTest.m
//  ObjCSRP
//
//  Created by David Siegel on 18.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SRP6Client.h"
#import "SRP6Server.h"
#import "SRP6VerifierGenerator.h"

NSString * const username = @"alice";
NSString * const password = @"password123";

@interface FunctionalTest : XCTestCase

@end

@implementation FunctionalTest

- (void) testSHA1 {
    DigestSHA1 * digest = [DigestSHA1 digest];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_1024 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_2048 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_4096 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_8192 username: username password: password];
}

- (void) testSHA224 {
    DigestSHA224 * digest = [DigestSHA224 digest];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_1024 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_2048 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_4096 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_8192 username: username password: password];
}

- (void) testSHA256 {
    DigestSHA256 * digest = [DigestSHA256 digest];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_1024 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_2048 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_4096 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_8192 username: username password: password];
}

- (void) testSHA384 {
    DigestSHA384 * digest = [DigestSHA384 digest];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_1024 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_2048 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_4096 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_8192 username: username password: password];
}

- (void) testSHA512 {
    DigestSHA512 * digest = [DigestSHA512 digest];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_1024 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_2048 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_4096 username: username password: password];
    [self performSRPTestWithDigest: digest parameters: SRP6.CONSTANTS_8192 username: username password: password];
}

- (void) performSRPTestWithDigest: (id<SRPDigest>) digest parameters: (SRP6Parameters*) params
                         username: (NSString*) username password: (NSString*) password
{
    NSData * salt = [SRP6 saltForDigest: digest];

    SRP6VerifierGenerator * generator = [[SRP6VerifierGenerator alloc] initWithDigest: digest N: params.N g: params.g];
    NSData * verifier = [generator generateVerifierWithSalt: salt username: username password: password];

    SRP6Client * client = [[SRP6Client alloc] initWithDigest: digest N: params.N g: params.g];
    SRP6Server * server = [[SRP6Server alloc] initWithDigest: digest N: params.N g: params.g];

    NSData * A = [client generateCredentialsWithSalt: salt username: username password: password];

    NSData * B = [server generateCredentialsWithSalt: salt username: username verifier: verifier];

    NSError * error;
    NSData * serverS = [server calculateSecret: A error: &error];
    XCTAssert(serverS, @"error: %@", error);

    NSData * clientS = [client calculateSecret: B error: &error];
    XCTAssert(clientS, @"error: %@", error);

    XCTAssert([clientS isEqualToData: serverS], @"Client secret must match server secret");

    NSData * M1 = [client calculateVerifier];

    NSData * M2 = [server verifyClient: M1 error: &error];
    XCTAssert(M2, @"error: %@", error);

    NSData * sessionKey = [client verifyServer: M2 error: &error];
    XCTAssert(sessionKey, @"error: %@", error);
}

@end
