//
//  Issue+NKIssue.h
//  jiududu
//
//  Created by Larry on 2/19/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import "Issue.h"
#import <NewsstandKit/NewsstandKit.h>
#import "ZipArchive.h"

@interface Issue (NKIssue)<NSURLConnectionDownloadDelegate,ZipArchiveDelegate>

@property (nonatomic, strong, readonly) NKIssue *nkIssue;
@property (nonatomic, strong, readonly) NSString *status;

- (void)download;
- (void)remove;

@end
