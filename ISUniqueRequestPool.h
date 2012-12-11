#import "ASIHTTPRequest.h"

typedef void (^UniquePoolHandler)(ASIHTTPRequest*, BOOL);

// any pending requests to a URL that is already being loaded just add the client to the list of blocks to be executed when that request finishes.
@interface ISUniqueRequestPool : NSObject {
    BOOL dead;
}

@property (strong) NSMutableDictionary* clientURLs; // id -> URL
@property (strong) NSMutableDictionary* requests; //URL -> { "request" : ASIHTTPRequest, "clients" : { id -> handler } }
- (void) request: (NSURL*) url forClient: (id) client then: (UniquePoolHandler) handler ;
- (void) cancel: (id) client; // the request stays alive, but the client lost interest
- (void) cancelAll; // cancel all pending requests.
@end

