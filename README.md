# Reddit-Gallery
Browse Reddit's videos subreddit

## Installation
Git clone this project and go to the folder then do
```
pod install
```
Then open Reddit-Gallery.xcworkspace

:exclamation: Do this right after pod install :exclamation:

<ol>
<li>Search for XCDYouTubeVideoOperation.m in xcode </li>
<li>Open the file</li>
<li>Do a CMD + f for get_video_info</li>
<li>Append &html5=1 to the query string for https://www.youtube.com/get_video_info? requests. There are two.</li>
</ol>
  
```obj-c
NSString *queryString = [XCDQueryStringWithDictionary(query) stringByAppendingString: @"&html5=1"];
```

## Design
![](https://i.imgur.com/B3j1BpY.png) ![Demo CountPages alpha](https://i.imgur.com/Wg4VlZb.png)

## Features
Swipe through all the media contents with media slider and drag image to dismiss when done.

![Demo CountPages alpha](https://thumbs.gfycat.com/HealthyScalyCockatiel-size_restricted.gif)

Support for image and video.

![Demo CountPages alpha](https://thumbs.gfycat.com/SerpentineLividIrishdraughthorse-size_restricted.gif)

Support for video streaming sites like Youtube.

![Demo CountPages alpha](https://thumbs.gfycat.com/PepperyCheapCuttlefish-size_restricted.gif)
