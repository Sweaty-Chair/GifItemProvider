# GifItemProvider
An extended UIActivityItemProvider to share GIF in Twitter and Facebook with UIActivityViewController

Twitter:
The default UIActivityViewController Twitter share doesn't support it yet which it will "scale down" it as a still JPG. However somehow it works for GIF less than 100kb (tested in iOS 9) and I don't know why.
Therefore, I have to use SLRequest to upload the GIF. When the SLRequest is done and return, dismiss the UIActivityViewController
The downside of that is no preview share sheet and users cannot type their own message anymore.

Facebook:
Upload to Giphy first, and provide the giphy URL to UIActivityViewController in stead of the file, Facebook with recognize it and show the animated GIF

Usage:

// Init the GifItemProvider

GifItemProvider *gifItem = [[GifItemProvider alloc] initWithPlaceholderItem:@"file://myGIFfilePath"];

// Includess the gifItem in an array

NSArray *items = [NSArray arrayWithObjects: gifItem, @"some string", @"http://some.url", nil];

// Use it in UIActivityViewController

UIActivityViewController *activityController = [[[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil] autorelease];
[UnityGetGLViewController() presentViewController:activityController animated:YES completion:NULL];

P.S. I am a iOS newb and code may be messy and hard coded, will come back for it when I getting better in Objective-C
