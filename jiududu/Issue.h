//
//  Issue.h
//  jiududu
//
//  Created by Larry on 2/24/13.
//  Copyright (c) 2013 warycat.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Issue : NSManagedObject

@property (nonatomic, retain) NSData * cover;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * page;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSNumber * percentage;

@end
