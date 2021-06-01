//
//  RedditApi.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import Foundation
import Alamofire

func fetchPosts(url: String, completion: @escaping (_ success: [Any]) -> Void) {
    var posts = [Post]()
    
    Alamofire.request(url).responseJSON { response in
        if let data = response.data {
              print("alamofire")
            if let decodedSubRedditData = try? JSONDecoder().decode(SubRedditDecode.Root.self,from: data) {
                for postData in decodedSubRedditData.data.children.dropFirst() {
                    var videoID = ""
                    var isVideo = false
                    var isYt = false
                    var redditPreviewUrl = ""
                    var mediaUrlToUse = ""
                    var isRedditPreviewVideo = false
                    var fallBackThumb = ""
                    
                    //TODO: hosted:video
                    
                    if postData.data.post_hint != "image" || postData.data.preview?.reddit_video_preview != nil || postData.data.media?.reddit_video != nil{
                        isVideo = true
                        
                        if postData.data.preview?.reddit_video_preview != nil { // reddit preview video and reddit video appears to be the same thing
                            print("\n\n\nis reddit preview sfsfasfassssssssssssssss \n\n\n", postData.data.preview?.reddit_video_preview?.scrubber_media_url)
                            redditPreviewUrl = (postData.data.preview?.reddit_video_preview?.scrubber_media_url)!
                            mediaUrlToUse = redditPreviewUrl
                            isRedditPreviewVideo = true
                            fallBackThumb = postData.data.thumbnail
                        } else if postData.data.media?.reddit_video != nil {
                            isRedditPreviewVideo = true
                            redditPreviewUrl = (postData.data.media?.reddit_video?.scrubber_media_url)!
                            fallBackThumb = postData.data.thumbnail
                        }
                        
                        if ytDomains.contains(postData.data.domain) { //yt videos need special extra work to stream
                            videoID = postData.data.url.youtubeID ?? ""
                            isYt = true
                            fallBackThumb = "http://img.youtube.com/vi/" + videoID + "/sddefault.jpg"
                        }
                    } else {
                        fallBackThumb = postData.data.thumbnail.convertSpecialCharacters()
                    }
                    
                    let post = Post(title: postData.data.title, postHint: postData.data.post_hint,
                                    thumbnail: postData.data.thumbnail.convertSpecialCharacters(),
                                    url: postData.data.url,
                                    isVideo: isVideo,
                                    maxThumb: "http://img.youtube.com/vi/" + videoID + "/maxresdefault.jpg",
                                    fallBackThumb: fallBackThumb,
                                    availThumb: postData.data.preview?.images?[0].source?.url.convertSpecialCharacters() ?? "reddit.com",
                                    ytVideoId: videoID,
                                    isYt: isYt,
                                    isRedditPreviewVideo: isRedditPreviewVideo,
                                    redditPreviewUrl: redditPreviewUrl)
                    posts.append(post)
                    
                    print(postData.data.thumbnail)
                }
                completion([posts])
            }
        }
    }
}

func checkIfVideo() {
    
}

func verifyURL(urlPath: String, completion: @escaping (_ isOK: Bool)->()) {
    if let url = URL(string: urlPath) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, error == nil {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        })
        task.resume()
    } else {
        completion(false)
    }
}

extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        
        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
}

let whiteThemeDict = ["quote" : UIColor(red: 0.4706, green: 0.6, blue: 0.1333, alpha: 1.0),
                      "table" : UIColor.white, "cell" : UIColor.white, "com" : UIColor.black,
                      "name" : UIColor.green, "details" : UIColor.gray.withAlphaComponent(0.7),
                      "sub" : UIColor.black.withAlphaComponent(0.85)]

let darkThemeDict = ["navBar" : UIColor(red:0.16, green:0.16, blue:0.17, alpha: 1.0),
                     "quote" : UIColor(red: 0.4706, green: 0.6, blue: 0.1333, alpha: 1.0),
                     "table" : UIColor(red:0.07, green:0.07, blue:0.08, alpha: 1.0),
                     "cell" : UIColor(red:0.12, green:0.12, blue:0.13, alpha: 1.0),
                     "com" : UIColor(red:0.73, green:0.73, blue:0.74, alpha: 1.0),
                     "name" : UIColor(red:0.73, green:0.73, blue:0.74, alpha: 1.0),
                     "details" : UIColor.gray.withAlphaComponent(0.7),
                     "sub" : UIColor(red:0.64, green:0.50, blue:0.68, alpha: 1.0),
                     "seperator" : UIColor(red:0.21, green:0.24, blue:0.29, alpha: 0.9),
                     "url" : UIColor(red:0.31, green:0.60, blue:0.91, alpha: 1.0)]

let themeDict = darkThemeDict
