//
//  MediaItemViewController.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/28/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import XCDYouTubeKit

@objc protocol MediaItemViewDelegate: class {
    @objc optional func mediaItemViewDidDrag(state: String)
    @objc optional func mediaControlsVisibilityDidChange(isHidden: Bool)
    @objc optional func vlcVideoTimeDidChange(position: Float)
    @objc optional func vlcVideoEnded()
    @objc optional func vlcVideoPlaying()
    @objc optional func vlcVideoPaused()
    @objc optional func newMediaItemDidAppeared(pageIndex: Int)
}

class MediaItemViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, VLCMediaPlayerDelegate, MediaPageViewDelegate {
    
    // MARK: - View Creation
    let backgroundView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        //pinch zoom
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.isUserInteractionEnabled = true
        scrollView.delaysContentTouches = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let vlcView: UIView = {
        let view = UIView()
        return view
    }()
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleBottomMargin.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue | UIView.AutoresizingMask.flexibleRightMargin.rawValue | UIView.AutoresizingMask.flexibleLeftMargin.rawValue | UIView.AutoresizingMask.flexibleTopMargin.rawValue | UIView.AutoresizingMask.flexibleWidth.rawValue)
        view.contentMode = UIView.ContentMode.scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Class Properties
    weak var delegate: MediaItemViewDelegate?
    weak var parentVC: MediaPageViewController?
    
    var didSetupConstraints = false
    var statusBarIsHidden = true
    var scrollViewTopped = false
    
    //new auto-layout compatible
    var centerConstraint: NSLayoutConstraint!
    var startingConstant: CGFloat  = 0.0
    
    var panGestureRecognizer: UIPanGestureRecognizer?
    var tapGesture: UITapGestureRecognizer!
    var sliderPanGesture: UIPanGestureRecognizer?
    
    
    //old pan
    var originalPosition: CGPoint?
    var currentPositionTouched: CGPoint?
    var originalVlcFrameOriginY: CGPoint?
    var originalActivityIndicatorY: CGPoint?
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    var mediaPlayer = VLCMediaPlayer()
    var pageColor = UIColor.black
    var pageIndex : Int = 0
    var imageUrl: URL!
    var mediaItem: Post!
    var media = VLCMedia()
    weak var timer: Timer?
    
    let group = DispatchGroup()
    
    // MARK: - View Handlers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isOpaque = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        view.setNeedsUpdateConstraints()
        
        sliderPanGesture = UIPanGestureRecognizer()
        sliderPanGesture?.cancelsTouchesInView = false
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGestureRecognizer?.delegate = self
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        
        imageView.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGestureRecognizer!)
        
        view.addSubview(backgroundView)
        //    scrollView.addSubview(closeButton)
        getStreamUrl()
    
        group.notify(queue: .main) {
            self.createVideoView()
            if self.viewIfLoaded?.window != nil {
                // viewController is visible
                self.mediaPlayer.play()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("will appear")
        //    parentVC?.delegate = self
        //    mediaPlayer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("did appear")
        //Clear previous reference incase user decided to cancel swipe
        parentVC?.delegate = nil
        mediaPlayer.delegate = nil
        
        //Assign to delegate current view
        delegate?.newMediaItemDidAppeared!(pageIndex: pageIndex)
        parentVC?.delegate = self
        mediaPlayer.delegate = self
        mediaPlayer.play()
        
        if mediaPlayer.isPlaying {
            activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("will disappear")
        mediaPlayer.pause()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("did disappear")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let orientation = UIDevice.current.orientation
        var widthToUse: CGFloat = portW
        
        if mediaItem.isYt {
            if (orientation.isLandscape) {
                print("Switched to landscape")
                //Always fill entire screen
                widthToUse = view.frame.size.height
            }
            else if(orientation.isPortrait) {
                
            }
            imageView.snp.remakeConstraints { remake in
                let oldWidth = CGFloat(widthToUse)
                let scaleFactor = widthToUse / oldWidth
                
                let newHeight = CGFloat(oldWidth / 16 * 9) * scaleFactor
                let newWidth = oldWidth * scaleFactor
                
                remake.width.equalTo(newWidth)
                remake.height.equalTo(newHeight)
            }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == panGestureRecognizer) {
            if (gestureRecognizer.numberOfTouches > 0) {
                let translation = panGestureRecognizer?.translation(in: view) // *CANT WORK WITHOUT DELEGATE!!!
                return abs(CGFloat((translation?.y)!)) > abs(CGFloat((translation?.x)!)) // only begin pan if horizontal drag
            } else {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print(type(of: gestureRecognizer), !(touch.view is UIButton))
        if (gestureRecognizer != panGestureRecognizer) {
            return !(touch.view is UIButton)
        }
        return true
    }
    
    // MARK: - Image Zoom Handling
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerConstraint.isActive = false
        imageView.layoutIfNeeded()
        removeImageViewDeadSpaces(scrollView)
        
        if (scrollView.isZoomBouncing) {
            if (scrollView.zoomScale == scrollView.maximumZoomScale) {
                NSLog("Bouncing back from maximum zoom")
            }
            else
                if (scrollView.zoomScale == scrollView.minimumZoomScale) {
                    NSLog("Bouncing back from minimum zoom")
                    centerConstraint.isActive = true
                    imageView.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - VLC Delegate Funcs
    func vlcPlayTapReceieved() {
        mediaPlayer.isPlaying ? mediaPlayer.pause() : mediaPlayer.play()
    }
    
    func sliderDidSlide(position: Float) {
        //    mediaPlayer.isPlaying ? mediaPlayer.pause() : mediaPlayer.play()
        mediaPlayer.position = position
        
        let state = mediaPlayer.state
        
        if state == VLCMediaPlayerState.error {
            print("Error trying to play video!")
        }
        else if state == VLCMediaPlayerState.ended || state == VLCMediaPlayerState.stopped {
            mediaPlayer.media = VLCMedia(url: URL(string: mediaItem!.url)!) //replay
            mediaPlayer.play()
        }
    }
    
    func replayButtonClicked() {
        print("replay button delegat")
        mediaPlayer.media = VLCMedia(url: URL(string: mediaItem!.url)!) //replay
        mediaPlayer.play()
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        let state = mediaPlayer.state
        
        if mediaPlayer.isPlaying {
            activityIndicator.stopAnimating()
            self.delegate?.vlcVideoPlaying!()
            //      mediaPlayerSlider.maximumValue = 1.0
        }
        else if state == VLCMediaPlayerState.paused {
            delegate?.vlcVideoPaused!()
        }
        else if state == VLCMediaPlayerState.error {
            print("Error trying to play video!")
        }
        else if state == VLCMediaPlayerState.ended || state == VLCMediaPlayerState.stopped {
            print("Video is done playing")
            self.delegate?.vlcVideoEnded!()
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        _ = mediaPlayer.remainingTime
        _ = mediaPlayer.time
        
        //    mediaTimeLabel.text = time?.stringValue ?? "00:00"
        //    mediaPlayerSlider.value = mediaPlayer.position
        self.delegate?.vlcVideoTimeDidChange!(position: mediaPlayer.position)
        
        //    print(time?.intValue ?? 0, remaining?.intValue ?? 0)
    }
    
    // MARK: - Gestures Handling
    @objc func movieViewTapped(_ sender: UITapGestureRecognizer) {
        if mediaPlayer.isPlaying {
            mediaPlayer.pause()
            
            _ = mediaPlayer.remainingTime
            _ = mediaPlayer.time
            
            //      print("Paused at \(time?.stringValue ?? "nil") with \(remaining?.stringValue ?? "nil") time remaining")
            //stopTimer()
        }
        else {
            if (mediaPlayer.remainingTime.stringValue == "00:00") {
                mediaPlayer.rewind()
            }
            mediaPlayer.play()
            print("Playing")
            //startTimer()
        }
        
    }
    
    @objc func updateSlider() {
        print(mediaPlayer.position)
    }
    
    func startTimer() {
        timer?.invalidate()   // stops previous timer, if any
        
        let seconds = 1.0
        timer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    @objc func rotated() {
        
        let orientation = UIDevice.current.orientation
        var widthToUse: CGFloat = view.frame.size.width
        var heightToUse: CGFloat = view.frame.size.height
        if mediaItem.is_video {
            if (orientation.isLandscape) {
                print("Switched to landscape")
                //Always fill entire screen
                widthToUse = view.frame.size.height
                heightToUse = view.frame.size.width
            }
            else if(orientation.isPortrait) {

            }
            imageView.snp.remakeConstraints { remake in
                let oldWidth = CGFloat(widthToUse)
                let scaleFactor = widthToUse / oldWidth
                
                let newHeight = CGFloat(oldWidth / 16 * 9) * scaleFactor
                let newWidth = oldWidth * scaleFactor
    
                remake.width.equalTo(newWidth)
                remake.height.equalTo(newHeight)
            }
        }
        
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        print("media tap")
        if statusBarIsHidden {
            UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.normal
            statusBarIsHidden = false
            self.delegate?.mediaControlsVisibilityDidChange!(isHidden: false)
        } else {
            UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.statusBar
            statusBarIsHidden = true
            self.delegate?.mediaControlsVisibilityDidChange!(isHidden: true)
        }
    }
    
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        
        if panGesture.state == .began {
            self.centerConstraint.isActive = true
            
            originalPosition = view.center
            currentPositionTouched = panGesture.location(in: view)
            self.startingConstant = self.centerConstraint.constant
            delegate?.mediaItemViewDidDrag!(state: "began")
        } else if panGesture.state == .changed {
            
            self.centerConstraint.constant = self.startingConstant + translation.y
            print("centerConstraint.constant ", centerConstraint.constant, "translation.y ", translation.y )
            self.imageView.layoutIfNeeded()
            backgroundView.alpha = 1 - translation.y / self.view.frame.height
            
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: view)
            
            if velocity.y >= 200 {
                UIView.animate(withDuration: 0.30
                    , animations: {
                        UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.normal
                        self.backgroundView.alpha = 0
                        self.centerConstraint.constant = self.view.frame.size.height
                        self.imageView.layoutIfNeeded()
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else { //failed
                UIView.animate(withDuration: 0.2, animations: {
                    print("image pan failed", self.centerConstraint.constant, self.startingConstant)
                    self.backgroundView.alpha = 1
                    self.centerConstraint.constant = self.startingConstant
                    self.imageView.layoutIfNeeded()
                    self.delegate?.mediaItemViewDidDrag!(state: "failed")
                }, completion: { (isCompleted) in
                    if isCompleted {
                        print("image pan failed complete", self.centerConstraint.constant, self.startingConstant)
                    }
                })
            }
        }
    }
    
    struct YouTubeVideoQuality {
        static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
        static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
        static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
    }
    
    // MARK: - Wrappers
    func createVideoView() {
        backgroundView.contentMode = UIView.ContentMode.scaleAspectFill
        backgroundView.layer.masksToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.masksToBounds = true
        
        backgroundView.addSubview(blurEffectView)
        
        view.addSubview(imageView)
        
        backgroundView.kf.setImage(with: URL(string: self.mediaItem!.fallBackThumb))
        imageView.kf.setImage(with: URL(string: self.mediaItem!.fallBackThumb))
        imageView.backgroundColor = .clear
        
        print("should be after streamurl")
        //    media = VLCMedia(url: mediaItem.imageUrl) //URL(string: "http://www.youtube.com/watch?v=ft8TkAeIopI")!
        //    //    self.scrollView.addSubview(vlcView)
        //    // Set media options
        //    // https://wiki.videolan.org/VLC_command-line_help
        media.addOptions([
            "network-caching": 300
            ])
        backgroundView.frame.origin.y = 0.0
        imageView.snp.makeConstraints { make in
            let oldWidth = CGFloat(portW)
            let scaleFactor = view.frame.size.width / oldWidth
            
            let newHeight = CGFloat(portH) * scaleFactor
            let newWidth = oldWidth * scaleFactor
            print(newWidth < view.frame.size.width, portW, newWidth, view.frame.size.width )
            make.width.equalTo(newWidth)
            make.height.equalTo(newHeight)
        }
        mediaPlayer.media = media
        mediaPlayer.drawable = imageView
        
        centerConstraint = imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerConstraint.isActive = true
        
        //loading indicator
        view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.layer.zPosition = 1
        // Position loading indicator at the center of the ViewController.
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.backgroundColor = .black
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)])
        activityIndicator.startAnimating()
    }
    
    func getStreamUrl() {
        group.enter()
        XCDYouTubeClient.default().getVideoWithIdentifier(mediaItem.ytVideoId) { (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
                //        playerViewController?.player = AVPlayer(url: streamURL)
                self.media = VLCMedia(url: streamURL)
                self.group.leave()
                print("stream url", streamURL)
            }
        }
    }
    
    func createImageView() {
        self.scrollView.addSubview(imageView)
        
        var thumbImage: UIImage!
        ImageCache.default.retrieveImage(forKey: mediaItem.fallBackThumb, options: nil) {
            image, cacheType in
            if let image = image {
                print("Get image \(image), cacheType: \(cacheType).")
                //In this code snippet, the `cacheType` is .disk
                thumbImage = image
            } else {
                print("Not exist in cache.")
            }
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: URL(string: self.mediaItem!.fallBackThumb), placeholder: thumbImage, completionHandler: {
                (image, error, cacheType, imageUrl) in
                print("image loaded")
            })
        }
    }
    
    func removeImageViewDeadSpaces(_ scrollView: UIScrollView) {
        //take out dead space when zoomed
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW:ratioH
                
                let newWidth = image.size.width*ratio
                let newHeight = image.size.height*ratio
                
                let left = 0.5 * (newWidth * scrollView.zoomScale > imageView.frame.width ? (newWidth - imageView.frame.width) : (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * scrollView.zoomScale > imageView.frame.height ? (newHeight - imageView.frame.height) : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
    }
    
    // MARK: - View Constraints
    override func updateViewConstraints() {
        //bottom -, right -,
        if (!didSetupConstraints) {
            backgroundView.snp.makeConstraints { make in
                make.width.equalTo(view.snp.width)
                make.height.equalTo(view.snp.height)
                make.centerY.equalTo(view)
            }
            
            if (!mediaItem.isYt){
                scrollView.snp.makeConstraints { make in
                    make.width.equalTo(view.snp.width)
                    make.height.equalTo(view.snp.height)
                }

                imageView.snp.makeConstraints { make in
                    make.width.equalTo(view.snp.width)
                    make.height.equalTo(view.snp.height)
                }
            }
            //      closeButton.snp.makeConstraints { make in
            //        make.top.equalTo(view.snp.top).offset(50.0)
            //        make.left.equalTo(view.snp.left).offset(10.0)
            //      }
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
}

extension UIPanGestureRecognizer {
    
    public struct PanGestureDirection: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        static let Up = PanGestureDirection(rawValue: 1 << 0)
        static let Down = PanGestureDirection(rawValue: 1 << 1)
        static let Left = PanGestureDirection(rawValue: 1 << 2)
        static let Right = PanGestureDirection(rawValue: 1 << 3)
    }
    
    private func getDirectionBy(velocity: CGFloat, greater: PanGestureDirection, lower: PanGestureDirection) -> PanGestureDirection {
        if velocity == 0 {
            return []
        }
        return velocity > 0 ? greater : lower
    }
    
    public func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        let yDirection = getDirectionBy(velocity: velocity.y, greater: PanGestureDirection.Down, lower: PanGestureDirection.Up)
        let xDirection = getDirectionBy(velocity: velocity.x, greater: PanGestureDirection.Right, lower: PanGestureDirection.Left)
        return xDirection.union(yDirection)
    }
}

