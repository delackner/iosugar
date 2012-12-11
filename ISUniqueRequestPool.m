#import "ISUniqueRequestPool.h"

@implementation ISUniqueRequestPool
- (id) init {
    if (nil != (self = [super init])) {
        self.clientURLs = [NSMutableDictionary new];
        self.requests = [NSMutableDictionary new];
    }
    return self;
}

- (void) dealloc {
    [self cancelAll];
}

//clientURLs; // id -> URL
//requests; // URL -> { "request" : ASIHTTPRequest, "clients" : { id -> handler } }

- (void) request: (NSURL*) url forClient: (id) client then: (UniquePoolHandler) handler {
    NSValue* c = [NSValue valueWithPointer: (__bridge const void *)(client)];
    self.clientURLs[c] = url;
    id req = self.requests[url];
    if (!req) {
        ASIHTTPRequest* r = [ASIHTTPRequest requestWithURL: url];
        r.delegate = self;
        self.requests[url] = [@{
                         @"request" : r,
                         @"clients" : [@{c : handler} mutableCopy]}
                         mutableCopy];
        [r startAsynchronous];
        NSLog(@"starting request %p for url %@", r, url);
    }
    else {
        NSLog(@"added client %@ to url %@", client, url);
        req[@"clients"][c] = handler;
    }
}

- (void) cancel: (id) client {
    NSValue* c = [NSValue valueWithPointer: (__bridge const void *)(client)];
    NSMutableDictionary* req = [self.requests objectForKey: self.clientURLs[c]];
    [req[@"clients"] removeObjectForKey: c];
}

- (void) cancelAll {
    for (NSDictionary* req in [self.requests allValues]) {
        [req[@"request"] clearDelegatesAndCancel];
    }
    [self.clientURLs removeAllObjects];
    [self.requests removeAllObjects];
}

- (void) finishRequest: (ASIHTTPRequest*) r ok: (BOOL) ok {
    if ([r isCancelled]) {
        ok = FALSE;
    }
    NSURL* url = [r url];
    NSDictionary* req = self.requests[url];
    NSDictionary* clients = req[@"clients"];
    NSLog(@"request %p %@ %@", r, ok ? @"finished" : @"failed", [r url]);
    for (id client in [clients allKeys]) {
        NSLog(@"calling client %@ handler for url %@", client, r.url);
        UniquePoolHandler handler = (UniquePoolHandler)clients[client];
        handler(r, ok);
        [self.clientURLs removeObjectForKey: client];
    }
    [self.requests removeObjectForKey: url];
}

- (void)requestFinished:(ASIHTTPRequest *)r {
    [self finishRequest: r ok: TRUE];
}

- (void)requestFailed:(ASIHTTPRequest *)r {
    [self finishRequest: r ok: FALSE];
}

@end

