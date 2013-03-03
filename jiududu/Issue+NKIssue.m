//
//  Issue+NKIssue.m
//  jiududu
//
//  Created by Larry on 2/19/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "Issue+NKIssue.h"
#import "AppDelegate.h"

@implementation Issue (NKIssue)

- (void)download
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.content]];
    NKAssetDownload *assetDownload = [self.nkIssue addAssetWithRequest:request];
    [assetDownload downloadWithDelegate:self];
    self.progress = @0.0;
    self.percentage = @0;
}

- (void)remove
{
    [[NKLibrary sharedLibrary]removeIssue:self.nkIssue];
    self.progress = @0.0;
    self.percentage = @0;
}

- (NKIssue *)nkIssue
{
    NKIssue *issue = [[NKLibrary sharedLibrary]issueWithName:self.name];
    if (issue) {
        return issue;
    }else{
        return [[NKLibrary sharedLibrary]addIssueWithName:self.name date:self.date];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
    [[NKLibrary sharedLibrary]removeIssue:self.nkIssue];
    self.progress = @0.0f;
    self.percentage = @0;
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    self.progress = [NSNumber numberWithFloat:1.0 * totalBytesWritten / expectedTotalBytes];
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    self.progress = [NSNumber numberWithFloat:1.0 * totalBytesWritten / expectedTotalBytes];
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    ZipArchive *archive = [[ZipArchive alloc]init];
    archive.progressBlock = ^(int percentage, int filesProcessed, int numFiles){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.percentage = [NSNumber numberWithInt:percentage];
            [[self app] saveContext];
        });
    };
    dispatch_queue_t unzipQueue = dispatch_queue_create("com.warycat.jiududu.unzip", 0);
    dispatch_async(unzipQueue, ^{
        [archive UnzipOpenFile:destinationURL.path];
        [archive UnzipFileTo:self.nkIssue.contentURL.path overWrite:YES];
    });
    NSLog(@"%@",self.nkIssue.contentURL);
}

- (void)ErrorMessage:(NSString *)msg
{
    NSLog(@"unzip %@",msg);
}

- (NSString *)status
{
    if (self.nkIssue.status == NKIssueContentStatusNone) {
        return @"None";
    }
    if (self.nkIssue.status == NKIssueContentStatusDownloading) {
        return @"Downloading";
    }
    if (self.nkIssue.status == NKIssueContentStatusAvailable) {
        if ([self.percentage isEqualToNumber: @100]) {
            return @"Ready";
        }else{
            return @"Processing";
        }
    }
    return @"Error";
}

- (AppDelegate *)app
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    return app;
}

@end
