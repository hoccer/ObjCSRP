//
//  SRP6.m
//  ObjCSRP
//
//  Created by David Siegel on 16.03.14.
//  Copyright (c) 2014 Hoccer GmbH. All rights reserved.
//

#import "SRP6.h"

#import "openssl/rand.h"

#import "BigInteger.h"

static const unsigned kSeedBufferSize   = 64;
static const unsigned kPrivateValueBits = 256; // RFC5054: SHOULD be at least 256 bits in length

@implementation SRP6

+ (void) initialize {
    NSMutableData* buffer = [NSMutableData dataWithLength: kSeedBufferSize];
    int err = SecRandomCopyBytes(kSecRandomDefault, buffer.length, buffer.mutableBytes);
    if (err != 0) {
        NSLog(@"RandomBytes; RNG error = %d", errno);
    }
    RAND_seed( buffer.bytes, (int)buffer.length);
}

- (id) initWithDigest: (id<SRPDigest>) digest N: (BigInteger*) N g: (BigInteger*) g {
    self = [super init];
    if (self) {
        _digest = digest;
        _N = N;
        _g = g;
    }
    return self;
}

+ (NSData*) saltForDigest: (id<SRPDigest>) digest {
    NSMutableData * randomSalt = [NSMutableData dataWithLength: digest.length];
    int err = SecRandomCopyBytes(kSecRandomDefault, randomSalt.length, randomSalt.mutableBytes);
    if (err != 0) {
        NSLog(@"RandomBytes; RNG error = %d", errno);
        return nil;
    }
    return randomSalt;
}

- (BigInteger*) selectPrivateValue {
    BigInteger * private = [BigInteger bigInteger];
    BN_rand(private.n, kPrivateValueBits, -1, 0);
    return private;
}

- (BigInteger*) xWithSalt: (NSData*) salt username: (NSString*) username password: (NSString*) password {
    NSData * d = [[@[username, password] componentsJoinedByString: @":"] dataUsingEncoding: NSUTF8StringEncoding];
    [_digest update: d];
    NSData * ucp_hash = [_digest doFinal];

    NSMutableData * s_hucp_hash = [NSMutableData dataWithData: salt];
    [s_hucp_hash appendData: ucp_hash];

    [_digest update: s_hucp_hash];
    return [BigInteger bigIntegerWithData: [_digest doFinal]];
}

- (BigInteger*) k {
    [_digest update: [NSData dataWithBigInteger: _N]];
    [_digest update: [NSData dataWithBigInteger: _g leftPaddedToLength: _N.length]];
    return [BigInteger bigIntegerWithData: [_digest doFinal]];
}

- (BigInteger*) uWithA: (BigInteger*) A andB: (BigInteger*) B {
    [_digest update: [NSData dataWithBigInteger: A leftPaddedToLength: _N.length]];
    [_digest update: [NSData dataWithBigInteger: B leftPaddedToLength: _N.length]];
    return [BigInteger bigIntegerWithData: [_digest doFinal]];
}

- (NSData*) hashNumber: (BigInteger*) number {
    [_digest update: [NSData dataWithBigInteger: number]];
    return [_digest doFinal];
}

- (NSData*) hashData: (NSData*) data {
    [_digest update: data];
    return [_digest doFinal];
}

- (NSData*) calculateHashNg {
    NSData * HN = [self hashNumber: _N];
    NSData * Hg = [self hashNumber: _g];
    NSMutableData * result = [NSMutableData dataWithLength: _digest.length];
    const unsigned char * bytesHN = HN.bytes;
    const unsigned char * bytesHg = Hg.bytes;
    unsigned char * out = result.mutableBytes;
    for (unsigned i = 0; i < result.length; ++i) {
        out[i] = bytesHN[i] ^ bytesHg[i];
    }
    return result;
}

- (NSData*) calculateM1 {
    NSData * HNg = [self calculateHashNg];
    NSData * HI  = [self hashData: [_username dataUsingEncoding: NSUTF8StringEncoding]];

    NSData * bytesA = [NSData dataWithBigInteger: _A];
    NSData * bytesB = [NSData dataWithBigInteger: _B];

    [_digest update: HNg];
    [_digest update: HI];
    [_digest update: _salt];
    [_digest update: bytesA];
    [_digest update: bytesB];
    [_digest update: _K];

    return [_digest doFinal];
}

- (NSData*) calculateM2: (NSData*) M1 {
    NSData * bytesA = [NSData dataWithBigInteger: _A];

    [_digest update: bytesA];
    [_digest update: M1];
    [_digest update: _K];

    return [_digest doFinal];
}

- (BigInteger*) validatePublicValue: (BigInteger*) publicValue {
    BigInteger * remainder = [publicValue mod: _N];
    if (remainder.isZero) {
        @throw [SRP6Exception exceptionWithName: @"BogusPublicValue" reason: @"Public value modulo N is zero." userInfo: nil];
    }
    return remainder;
}

+ (SRP6Parameters*) CONSTANTS_1024 {
    static SRP6Parameters * p = nil;
    if (! p) {
        p = [[SRP6Parameters alloc] initWithN:
             @"EEAF0AB9ADB38DD69C33F80AFA8FC5E86072618775FF3C0B9EA2314C"
             @"9C256576D674DF7496EA81D3383B4813D692C6E0E0D5D8E250B98BE4"
             @"8E495C1D6089DAD15DC7D7B46154D6B6CE8EF4AD69B15D4982559B29"
             @"7BCF1885C529F566660E57EC68EDBC3C05726CC02FD4CBF4976EAA9A"
             @"FD5138FE8376435B9FC61D2FC0EB06E3" g: @"2"];
    }
    return p;
}

+ (SRP6Parameters*) CONSTANTS_2048 {
    static SRP6Parameters * p = nil;
    if (! p) {
        p = [[SRP6Parameters alloc] initWithN:
             @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC319294"
             @"3DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310D"
             @"CD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FB"
             @"D5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF74"
             @"7359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A"
             @"436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D"
             @"5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E73"
             @"03CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB6"
             @"94B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F"
             @"9E4AFF73" g: @"2"];
    }
    return p;
}

+ (SRP6Parameters*) CONSTANTS_4096 {
    static SRP6Parameters * p = nil;
    if (! p) {
        p = [[SRP6Parameters alloc] initWithN:
             @"FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E08"
             @"8A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B"
             @"302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9"
             @"A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE6"
             @"49286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8"
             @"FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D"
             @"670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E772C"
             @"180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF695581718"
             @"3995497CEA956AE515D2261898FA051015728E5A8AAAC42DAD33170D"
             @"04507A33A85521ABDF1CBA64ECFB850458DBEF0A8AEA71575D060C7D"
             @"B3970F85A6E1E4C7ABF5AE8CDB0933D71E8C94E04A25619DCEE3D226"
             @"1AD2EE6BF12FFA06D98A0864D87602733EC86A64521F2B18177B200C"
             @"BBE117577A615D6C770988C0BAD946E208E24FA074E5AB3143DB5BFC"
             @"E0FD108E4B82D120A92108011A723C12A787E6D788719A10BDBA5B26"
             @"99C327186AF4E23C1A946834B6150BDA2583E9CA2AD44CE8DBBBC2DB"
             @"04DE8EF92E8EFC141FBECAA6287C59474E6BC05D99B2964FA090C3A2"
             @"233BA186515BE7ED1F612970CEE2D7AFB81BDD762170481CD0069127"
             @"D5B05AA993B4EA988D8FDDC186FFB7DC90A6C08F4DF435C934063199"
             @"FFFFFFFFFFFFFFFF" g:@"5"];
    }
    return p;

}
+ (SRP6Parameters*) CONSTANTS_8192 {
    static SRP6Parameters * p = nil;
    if (! p) {
        p = [[SRP6Parameters alloc] initWithN:
             @"FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E08"
             @"8A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B"
             @"302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9"
             @"A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE6"
             @"49286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8"
             @"FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D"
             @"670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E772C"
             @"180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF695581718"
             @"3995497CEA956AE515D2261898FA051015728E5A8AAAC42DAD33170D"
             @"04507A33A85521ABDF1CBA64ECFB850458DBEF0A8AEA71575D060C7D"
             @"B3970F85A6E1E4C7ABF5AE8CDB0933D71E8C94E04A25619DCEE3D226"
             @"1AD2EE6BF12FFA06D98A0864D87602733EC86A64521F2B18177B200C"
             @"BBE117577A615D6C770988C0BAD946E208E24FA074E5AB3143DB5BFC"
             @"E0FD108E4B82D120A92108011A723C12A787E6D788719A10BDBA5B26"
             @"99C327186AF4E23C1A946834B6150BDA2583E9CA2AD44CE8DBBBC2DB"
             @"04DE8EF92E8EFC141FBECAA6287C59474E6BC05D99B2964FA090C3A2"
             @"233BA186515BE7ED1F612970CEE2D7AFB81BDD762170481CD0069127"
             @"D5B05AA993B4EA988D8FDDC186FFB7DC90A6C08F4DF435C934028492"
             @"36C3FAB4D27C7026C1D4DCB2602646DEC9751E763DBA37BDF8FF9406"
             @"AD9E530EE5DB382F413001AEB06A53ED9027D831179727B0865A8918"
             @"DA3EDBEBCF9B14ED44CE6CBACED4BB1BDB7F1447E6CC254B33205151"
             @"2BD7AF426FB8F401378CD2BF5983CA01C64B92ECF032EA15D1721D03"
             @"F482D7CE6E74FEF6D55E702F46980C82B5A84031900B1C9E59E7C97F"
             @"BEC7E8F323A97A7E36CC88BE0F1D45B7FF585AC54BD407B22B4154AA"
             @"CC8F6D7EBF48E1D814CC5ED20F8037E0A79715EEF29BE32806A1D58B"
             @"B7C5DA76F550AA3D8A1FBFF0EB19CCB1A313D55CDA56C9EC2EF29632"
             @"387FE8D76E3C0468043E8F663F4860EE12BF2D5B0B7474D6E694F91E"
             @"6DBE115974A3926F12FEE5E438777CB6A932DF8CD8BEC4D073B931BA"
             @"3BC832B68D9DD300741FA7BF8AFC47ED2576F6936BA424663AAB639C"
             @"5AE4F5683423B4742BF1C978238F16CBE39D652DE3FDB8BEFC848AD9"
             @"22222E04A4037C0713EB57A81A23F0C73473FC646CEA306B4BCBC886"
             @"2F8385DDFA9D4B7FA2C087E879683303ED5BDD3A062B3CF5B3A278A6"
             @"6D2A13F83F44F82DDF310EE074AB6A364597E899A0255DC164F31CC5"
             @"0846851DF9AB48195DED7EA1B1D510BD7EE74D73FAF36BC31ECFA268"
             @"359046F4EB879F924009438B481C6CD7889A002ED5EE382BC9190DA6"
             @"FC026E479558E4475677E9AA9E3050E2765694DFC81F56E880B96E71"
             @"60C980DD98EDD3DFFFFFFFFFFFFFFFFF" g: @"13"];
    }
    return p;

}

@end

@implementation SRP6Exception
@end
