//
//  ISBatchDownloader.h
//  iosugar
//
//  Created by Seth Delackner on 10/25/12.
//
//

@protocol ISBatchDownloadClient
- (BOOL) downloadItem: (NSString*) path;
- (void) downloadFinished;
- (void) updateDownloadProgress: (float) progress;
- (void) userCancelledDownload;
@end

@interface ISBatchDownloader : NSObject {
    int nextDownload;
}

@property (atomic) BOOL cancelled;
@property (nonatomic, copy) NSArray* paths;
@property (unsafe_unretained, nonatomic) UIViewController<ISBatchDownloadClient>* controller;
@end
