//
//  main.m
//  crashdump
//
//  Created by Dave MacLachlan on 11/6/22.
//

#import <Foundation/Foundation.h>

// Private API for turning crash reports into dictionaries.
// This is valid for at least MacOS 12 and 13.
// This was extracted from:
// /System/Library/PrivateFrameworks/OSAnalytics.framework/Versions/A/OSAnalytics
@interface OSALegacyXform : NSObject
// Takes in a crash report file pointed to by url and returns a dictionary with either
// OSATransformResultReport or OSATransformResultError keys.
+ (NSDictionary<NSString *, id> *)transformURL:(NSURL *)url options:(id)options;
@end

// These are the keys for the dictionary created by OSALegacyXform.
extern NSString *OSATransformResultError;
extern NSString *OSATransformResultReport;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc > 3 || argc < 2) {
            printf("error: parameter error\n");
            return 1;
        }
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        NSString *toPath = argc > 2 ? [NSString stringWithUTF8String:argv[2]]:[path stringByAppendingString:@".crash"];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSDictionary<NSString *, id> *output = [OSALegacyXform transformURL:url options:nil];
        NSString *report = output[OSATransformResultReport];
        NSError *error = output[OSATransformResultError];
        if (error) {
            printf("error: %s\n", error.localizedDescription.UTF8String);
        } else if (report) {
            [report writeToFile:toPath atomically:true encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                printf("error: %s\n", error.localizedDescription.UTF8String);
            } else {
                printf("success: %s\n",toPath.UTF8String);
                return 0;
            }
        } else {
            printf("error: Unable to parse file %s\n", argv[1]);
        }
    }
    return 1;
}
