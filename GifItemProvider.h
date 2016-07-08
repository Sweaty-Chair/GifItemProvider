//
//  GifItemProvider.h
//  Unity-iPhone
//
//  Created by Richard on 6/23/16.
//
//

#import <UIKit/UIKit.h>
// #import "GiphyViewController.h"

@interface GifItemProvider : UIActivityItemProvider <UIActivityItemSource, NSURLConnectionDelegate>
{
    NSURLConnection *connection;
    NSError *error;
    NSString *uploadFileURL;
    //GiphyViewController *giphyViewController;
    UIProgressView *progressView;
}

@end
