//
//  GifActivityItemProvider.mm
//  Unity-iPhone
//
//  Created by Richard on 6/23/16.
//
//

#import "GifItemProvider.h"
// #import "GiphyViewController.h"


@implementation GifItemProvider


- (id)item
{
    
    if ([self.activityType isEqualToString:UIActivityTypePostToFacebook]) {
    
        // Upload to Giphy
        
        NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
        [_params setObject:@"dc6zaTOxFJmzC" forKey:@"api_key"];
        //        [_params setObject:[NSString stringWithString:@"ulgymon"] forKey:[NSString stringWithString:@"username"]];
        [_params setObject:@"test,dev" forKey:@"tag"];
        
        NSString *boundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
        
        // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
        NSString* fileParamConstant = @"file";
        
        NSURL *requestURL = [NSURL URLWithString:@"https://upload.giphy.com/v1/gifs"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryConstant];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        
        for (NSString *param in _params) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSData *imageData = [NSData dataWithContentsOfFile:self.placeholderItem];
        if (imageData) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", fileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        [request setURL:requestURL];
        
        uploadFileURL = nil;
        error = nil;
        
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [connection setDelegateQueue:[[NSOperationQueue alloc] init]];
        [connection start];
        
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failed" message:@"Check your Connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert performSelectorOnMainThread:@selector(show)
                                withObject:nil
                             waitUntilDone:NO];
        [alert release];
         */
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uploading..." message:@"Please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show)
                                withObject:nil
                             waitUntilDone:NO];
        [alert release];
        
        //progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        // giphyViewController = [[GiphyViewController alloc] init];
        
        // progressView.progress = 0;
        // [self performSelectorOnMainThread:@selector(makeMyProgressBarMoving) withObject:nil waitUntilDone:NO];
        // [self.view addSubview: progressView]
        // [progressView release];
        
        while (uploadFileURL == nil && error == nil) {
            NSLog (@"Waiting for upload...");
            [NSThread sleepForTimeInterval:1.0f];
            NSLog (@"uploadFileURL: %@", uploadFileURL);
        }
        
        NSLog (@"Ready to Share");
        
        if (!uploadFileURL)
            NSLog (@"uploadFileURL: %@", uploadFileURL);
        else
            NSLog (@"error: %@", error);
        
        return [NSURL URLWithString:uploadFileURL];
    }
    
    if ([self.activityType isEqualToString:UIActivityTypePostToTwitter]) {
        
         // TODO
        
        return [NSData dataWithContentsOfFile:self.placeholderItem];
    }
    
    return [NSData dataWithContentsOfFile:self.placeholderItem];
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    UIActivityIndicatorView *progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    progress.frame = CGRectMake(125, 50, 30, 30);
    
    [progress startAnimating];
    [alertView addSubview:progress];
    
    /*
     UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
     progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
     [alert addSubview:progress];
     [progress startAnimating];
     */
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    float myProgress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    // progressView.progress = myProgress;
    // [giphyViewController updateUI:myProgress];
    NSLog(@"Progress: %f", myProgress);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    BOOL success = NO;
    NSDictionary *retDict, *metaDict, *dataDict;
    
    if (data.length > 0) {
        retDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSLog (@"retDict: %@", retDict);
        
        metaDict = [retDict objectForKey:@"meta"];
        
        if (metaDict) {
            NSString *msg = [metaDict objectForKey:@"msg"];
            NSNumber *status = [metaDict objectForKey:@"status"];
        
            NSLog (@"msg: %@", msg);
            NSLog (@"status: %@", status);
        
            if ([msg isEqualToString:@"OK"] && [status isEqual:@(200)]) {
        
                dataDict = [retDict objectForKey:@"data"];
                
                if (dataDict) {
        
                    uploadFileURL = [NSString stringWithFormat:@"http://i.giphy.com/%@.gif", [dataDict objectForKey:@"id"]];
        
                    NSLog (@"Retrived uploadFileURL: %@", uploadFileURL);
                    success = YES;
                }
            }
        }
    }
    
    if (success == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failed" message:@"Check your Connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        });
        
        error = [NSError errorWithDomain:@"giphy" code:100 userInfo:metaDict];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)conError {
    error = conError;
    NSLog(@"didFailWithError: %@", error);
}

/*
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    
    // Or just stop
    // [self stopActivityIndicator];
    
    connection = nil;
}
 */

@end
