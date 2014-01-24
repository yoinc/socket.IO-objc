//
//  SocketIOJSONSerialization.m
//  v0.4.1 ARC
//
//  based on
//  socketio-cocoa https://github.com/fpotter/socketio-cocoa
//  by Fred Potter <fpotter@pieceable.com>
//
//  using
//  https://github.com/square/SocketRocket
//  https://github.com/stig/json-framework/
//
//  reusing some parts of
//  /socket.io/socket.io.js
//
//  Created by Philipp Kyeck http://beta-interactive.de
//
//  Updated by
//    samlown   https://github.com/samlown
//    kayleg    https://github.com/kayleg
//    taiyangc  https://github.com/taiyangc
//

#import "SocketIOJSONSerialization.h"

extern NSString * const SocketIOException;

// covers the methods in SBJson and JSONKit
@interface NSObject (SocketIOJSONSerialization)

// used by both JSONKit and SBJson
- (id) objectWithData:(NSData *)data;

// Use by JSONKit serialization
- (NSString *) JSONString;
- (id) decoder;

// Used by SBJsonWriter
- (NSString *) stringWithObject:(id)object;

@end

@implementation SocketIOJSONSerialization

+ (id) objectFromJSONData:(NSData *)data error:(NSError **)error {
    Class serializer;

    // try Foundation's JSON coder first, available in OS X 10.7/iOS 5.0
    serializer = NSClassFromString(@"NSJSONSerialization");
    if (serializer) {
        return [serializer JSONObjectWithData:data options:0 error:error];
    }
    
    // next, try JSONKit
    serializer = NSClassFromString(@"JSONDecoder");
    if (serializer) {
        return [[serializer decoder] objectWithData:data];
    }

    // try SBJson last
    serializer = NSClassFromString(@"SBJsonParser");
    if (serializer) {
        id parser;
        id object;

        parser = [[serializer alloc] init];
        object = [parser objectWithData:data];

        return object;
    }
    
    // unable to find a suitable JSON deseralizer
    [NSException raise:SocketIOException format:@"socket.IO-objc requires SBJson, JSONKit or an OS that has NSJSONSerialization."];
    
    return nil;
}

+ (NSString *) JSONStringFromObject:(id)object error:(NSError **)error {
    Class     serializer;
    NSString *jsonString;
    
    jsonString = nil;

    serializer = NSClassFromString(@"NSJSONSerialization");
    if (serializer) {
        NSData *data;
        data = [serializer dataWithJSONObject:object options:0 error:error];
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return jsonString;
    }

    if ([object respondsToSelector:@selector(JSONString)]) {
        return [object JSONString];
    }

    // lastly, try SBJson
    serializer = NSClassFromString(@"SBJsonWriter");
    if (serializer) {
        id writer;

        writer = [[serializer alloc] init];
        jsonString = [writer stringWithObject:object];

        return jsonString;
    }
    
    // unable to find a suitable JSON seralizer
    [NSException raise:SocketIOException format:@"socket.IO-objc requires SBJson, JSONKit or an OS that has NSJSONSerialization."];
    
    return nil;
}

@end
