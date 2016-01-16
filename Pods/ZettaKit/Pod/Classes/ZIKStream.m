//
//  ZIKStream.m
//  ReactiveLearning
//
//  Created by Matthew Dobson on 4/7/15.
//  Copyright (c) 2015 Matthew Dobson. All rights reserved.
//

#import "ZIKStream.h"
#import <SocketRocket/SRWebSocket.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ZIKStreamEntry.h"
#import "ZIKLogStreamEntry.h"

@interface ZIKStream () <SRWebSocketDelegate>

@property (nonatomic, retain) NSString *url;

@property (nonatomic, retain) id<RACSubscriber> subscriber;

@end

@implementation ZIKStream {
    SRWebSocket *_socket;
}

+ (instancetype) initWithDictionary:(NSDictionary *)data {
    return [[ZIKStream alloc] initWithDictionary:data];
}



- (id) initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        if ([data objectForKey:@"title"]) {
            self.title = data[@"title"];
        }
        
        if ([data objectForKey:@"href"]) {
            self.url = data[@"href"];
            NSURL *streamUrl = [NSURL URLWithString:self.url];
            _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:streamUrl]];
            _socket.delegate = self;
            @weakify(self)
            self.signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self)
                self.subscriber = subscriber;
                return nil;
            }];
        }
    }
    return self;
}

+ (instancetype) initWithLink:(ZIKLink *)link {
    return [[ZIKStream alloc] initWithLink:link];
}

- (id) initWithLink:(ZIKLink *)link {
    if (self = [super init]) {
        self.title = link.title;
        self.url = link.href;
        NSURL *streamUrl = [NSURL URLWithString:self.url];
        _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:streamUrl]];
        _socket.delegate = self;
        @weakify(self)
        self.signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self)
            self.subscriber = subscriber;
            return nil;
        }];

    }
    return self;
}

- (void) resume {
    [_socket open];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if (self.subscriber != nil) {
        NSString *messageData = (NSString *)message;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[messageData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        if ([self.title isEqualToString:@"logs"]) {
            [self.subscriber sendNext:[ZIKLogStreamEntry initWithDictionary:data]];
        } else {
            [self.subscriber sendNext:[ZIKStreamEntry initWithDictionary:data]];
        }
    } else {
        NSLog(@"Subscriber is nil");
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    if (self.subscriber != nil) {
        [self.subscriber sendCompleted];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    if (self.subscriber != nil) {
        [self.subscriber sendError:error];
    }
}

- (void) stop {
    [_socket close];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<ZIKStream: %@>", self.title];
}

@end
