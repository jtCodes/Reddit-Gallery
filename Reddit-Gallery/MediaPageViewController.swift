//
//  MediaPageViewController.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/28/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import UIKit

@objc protocol MediaPageViewDelegate: class {
    @objc optional func mediaPageViewDidSwipe(rowNo: Int)
    @objc optional func sliderDidSlide(position: Float)
    @objc optional func replayButtonClicked()
    @objc optional func vlcPlayTapReceieved()
}

class MediaPageViewController: UIViewController, UIPageViewControllerDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate, MediaItemViewDelegate {
    
    let mediaInfoContainer: UIView = {
        let view = UIView()
        view.layer.zPosition = 10
        //    view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.isUserInteractionEnabled = true
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        return view
    }()
    
    let filenameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.sizeToFit()
        label.lineBreakMode = .byTruncatingMiddle
        label.textAlignment = .center
        label.font = label.font.withSize(10)
        return label
    }()
    
    let vlcControlsContainer: UIView = {
        let view = UIView()
        view.layer.zPosition = 10
        //    view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.isUserInteractionEnabled = true
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        return view
    }()
    
    let playButton: UIButton = {
        let button = UIButton()
        let origImage = UIImage(named: "play")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    let mediaPlayerSlider: CustomSlider = {
        let slider = CustomSlider()
        slider.isUserInteractionEnabled = true
        return slider
    }()
    
    let mediaTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    let replayButton: UIButton = {
        let button = UIButton()
        button.setTitle("Replay", for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    //MARK: - Class Properties
    weak var delegate: MediaPageViewDelegate?
    
    var didSetupConstraints = false
    
    var pageViewController : UIPageViewController?
    var postMediaItems : Array<Post> = []
    var currentIndex : Int = 0
    
    var scrollView: UIScrollView?
    
    var mediaItemControlIsHidden = false
    var replayButtonIsHidden = true
    var isCurrentMediaWebm = false
    
    var vlcState = "paused"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(1)
        view.isOpaque = false
        
        let optionsDict = [UIPageViewController.OptionsKey.interPageSpacing : 40]
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: optionsDict)
        pageViewController!.dataSource = self
        
        let startingViewController: MediaItemViewController = viewControllerAtIndex(index: currentIndex)!
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height);
        
        addChild(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMove(toParent: self)
        pageViewController?.scrollView?.delaysContentTouches = false
        pageViewController?.scrollView?.delegate = self
        
        view.addSubview(mediaInfoContainer)
        mediaInfoContainer.addSubview(filenameLabel)
        mediaInfoContainer.isHidden = true
        
        vlcControlsContainer.isHidden = true
        view.addSubview(vlcControlsContainer)
        mediaPlayerSlider.minimumValue = 0.0
        mediaPlayerSlider.maximumValue = 1.0
        mediaPlayerSlider.addTarget(self, action: #selector(paybackSliderValueDidChange), for: .valueChanged)
        //    mediaPlayerSlider.isHidden = true
        //    mediaTimeLabel.isHidden = true
        vlcControlsContainer.addSubview(mediaPlayerSlider)
        vlcControlsContainer.addSubview(mediaTimeLabel)
        playButton.addTarget(self, action: #selector(playPauseButtonOnTap), for: .touchUpInside)
        vlcControlsContainer.addSubview(playButton)
        replayButton.isHidden = replayButtonIsHidden
        replayButton.addTarget(self, action: #selector(replayButtonAction), for: .touchUpInside)
        view.addSubview(replayButton)
        view.setNeedsUpdateConstraints()
    }
    
    //TO HIDE THE PRESENTING VIEW BECAUSE OVERCURRENTCONTEXT
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func newMediaItemDidAppeared(pageIndex: Int) {
        
    }
    
    func mediaControlsVisibilityDidChange(isHidden: Bool) {
        if !isHidden {
            vlcControlsContainer.isHidden = !isCurrentMediaWebm
            mediaInfoContainer.isHidden = false
            self.mediaInfoContainer.snp.updateConstraints( { make in
                make.top.equalTo(self.view.snp.top).offset(0)
            })
            self.vlcControlsContainer.snp.updateConstraints( { make in
                make.bottom.equalTo(self.view.snp.bottom).offset(0)
            })
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (isCompleted) in
                if isCompleted {
                    
                }
            })
        } else {
            self.mediaInfoContainer.snp.updateConstraints( { make in
                make.top.equalTo(self.view.snp.top).offset(-100)
            })
            self.vlcControlsContainer.snp.updateConstraints( { make in
                make.bottom.equalTo(self.view.snp.bottom).offset(100)
            })
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (isCompleted) in
                if isCompleted {
                    self.vlcControlsContainer.isHidden = true
                    self.mediaInfoContainer.isHidden = true
                }
            })
        }
    }
    
    func mediaItemViewDidDrag(state: String) {
        var alphaLevel = 0
        state == "failed" ? (alphaLevel = 1) : (alphaLevel = 0)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(alphaLevel))
    }
    
    func vlcVideoTimeDidChange(position: Float) {
        mediaPlayerSlider.value = position
        replayButton.isHidden = true
    }
    
    func vlcVideoPlaying() {
        vlcState = "playing"
        
        let origImage = UIImage(named: "pause")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        playButton.setImage(tintedImage, for: .normal)
        
        replayButton.isHidden = true
    }
    
    func vlcVideoPaused() {
        vlcState = "paused"
        
        let origImage = UIImage(named: "play")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        playButton.setImage(tintedImage, for: .normal)
    }
    
    func vlcVideoEnded() {
        vlcState = "ended"
        
        print("done celgate")
        let origImage = UIImage(named: "play")
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        playButton.setImage(tintedImage, for: .normal)
        
        replayButton.isHidden = false
        mediaPlayerSlider.value = 1
    }
    
    //MARK: - PageView Setup
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MediaItemViewController).pageIndex
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! MediaItemViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if (index == self.postMediaItems.count) {
            return nil
        }
        
        return viewControllerAtIndex(index: index)
    }
    
    func viewControllerAtIndex(index: Int) -> MediaItemViewController? {
        if self.postMediaItems.count == 0 || index >= self.postMediaItems.count {
            print("post media array empty", self.postMediaItems.count)
            return nil
        }
        // Create a new view controller and pass suitable data.
        let pageContentViewController = MediaItemViewController()
        pageContentViewController.pageIndex = index
        pageContentViewController.mediaItem = self.postMediaItems[index]
        pageContentViewController.delegate = self
        pageContentViewController.parentVC = self
        currentIndex = index
        //    myPrint(className: self, funcName: #function, string: self.postMediaItems[index].ext)
        
        return pageContentViewController
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.postMediaItems.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    @objc func playPauseButtonOnTap() {
        print("playbutton press")
        delegate?.vlcPlayTapReceieved!()
        
        if vlcState == "ended" {
            delegate?.replayButtonClicked!()
            replayButton.isHidden = true
        }
    }
    
    @objc func paybackSliderValueDidChange(sender: UISlider!) {
        self.delegate?.sliderDidSlide!(position: sender.value)
    }
    
    @objc func handlePan(sender:UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            print("page swipe began")
        case .ended:
            break
        default:
            break
        }
    }
    
    @objc func replayButtonAction(sender: UIButton!) {
        print("replay butotn click")
        delegate?.replayButtonClicked!()
        replayButton.isHidden = true
    }
    
    // MARK: - View Constraints
    override func updateViewConstraints() {
        //bottom -, right -,
        if (!didSetupConstraints) {
            //
            mediaInfoContainer.snp.makeConstraints { make in
                make.left.equalTo(view.snp.left)
                make.width.equalTo(view.snp.width)
                make.height.equalTo(75)
                make.top.equalTo(view.snp.top).offset(-100)
            }
            
            filenameLabel.snp.makeConstraints { make in
                make.leading.equalTo(mediaInfoContainer).offset(80)
                make.trailing.equalTo(mediaInfoContainer).offset(-80)
                //        make.bottom.equalTo(mediaInfoContainer).offset(-10)
                make.centerY.equalTo(mediaInfoContainer)
            }
            
            vlcControlsContainer.snp.makeConstraints { make in
                make.left.equalTo(view.snp.left)
                make.width.equalTo(view.snp.width)
                make.height.equalTo(45)
                make.bottom.equalTo(view.snp.bottom).offset(100)
            }
            
            mediaTimeLabel.snp.makeConstraints { make in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.bottom.equalTo(mediaPlayerSlider.snp.top)
            }
            
            playButton.snp.makeConstraints { make in
                make.left.equalTo(vlcControlsContainer).offset(10)
                make.right.equalTo(mediaPlayerSlider.snp.left).offset(-5)
                make.centerY.equalTo(vlcControlsContainer)
                make.height.equalTo(35)
                make.width.equalTo(35)
            }
            
            mediaPlayerSlider.snp.makeConstraints { make in
                make.right.equalTo(vlcControlsContainer).offset(-10)
                make.left.equalTo(playButton.snp.right).offset(5)
                make.height.equalTo(20)
                make.width.equalTo(view.frame.size.width * 0.5)
                make.centerY.equalTo(vlcControlsContainer)
            }
            
            replayButton.snp.makeConstraints { make in
                make.width.equalTo(70)
                make.height.equalTo(50)
                make.center.equalTo(view)
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

class CustomSlider: UISlider {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds: CGRect = self.bounds
        bounds = bounds.insetBy(dx: -10, dy: -15)
        return bounds.contains(point)
    }
}

extension UIPageViewController {
    
    public var scrollView: UIScrollView? {
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }
}
