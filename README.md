# Reddit-Gallery
Browse Reddit's videos subreddit

## Installation
<ol>
<li>git clone this project</li> 
<li>open terminal and cd to Reddit-Gallery directory</li>
<li>then do</li> 
</ol>
  
```
pod install
```
  
:exclamation: then open Reddit-Gallery.xcworkspace and do the following: :exclamation:

<ol>
<li>search for XCDYouTubeVideoOperation.m in xcode </li>
<li>open the file</li>
<li>do a CMD + f for get_video_info</li>
<li>append &html5=1 to the query string for https://www.youtube.com/get_video_info? requests. There are two.</li>
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
