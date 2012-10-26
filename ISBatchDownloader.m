//
//  ISBatchDownloader.m
//  iosugar
//
//  Created by Seth Delackner on 10/25/12.
//
//

#import "ISBatchDownloader.h"

@implementation ISBatchDownloader
@synthesize controller, paths, cancelled;

- (void) run {
    @autoreleasepool  {
        int checkFreeSpace = 0;
        int count = [paths count];
        while (nextDownload < count && !self.cancelled) {
            if (checkFreeSpace % 10 == 0) {
                BOOL warn = (FreeSpace() < 1000000);
                if (warn) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [controller growl: LS(@"Free Space Low") message: LS(@"Space too low to pre-download more content")];
                    });
                    return;
                }
            }
            NSString* path = [self.paths objectAtIndex: nextDownload];
            BOOL isCached = FALSE;
            if (!cancelled && !isCached) {
                isCached = [controller downloadItem: path];
                if (!isCached) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!self.cancelled) {
                            Growler* g = [controller growl:@"" message: LS(@"WARN_AUDIO_DOWN_FAILED") okButton: LS(@"OK") ok: ^(int r){
                                if (!self.cancelled) {
                                    [controller userCancelledDownload];
                                }
                            }];
                            g.busyView.hidden = FALSE;
                        }
                    });
                    return;
                }
            }
            nextDownload++;
            if (!self.cancelled) {
                if (nextDownload < count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [controller updateDownloadProgress: nextDownload / (float)count];
                    });
                }
                checkFreeSpace++;
            }
        }
        if (!self.cancelled) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [controller downloadFinished];
            });
        }
    }
}

@end
