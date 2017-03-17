//
//  LFScrollView.swift
//  ScrollViewSwift
//
//  Created by 吴林丰 on 2017/3/13.
//  Copyright © 2017年 吴林丰. All rights reserved.
//

import UIKit


/**
 当点击图片的时候，相应的返回value所在的index，和value所对应的链接，便于
 页面之间的跳转
 */
typealias clickBlock = (_ index:NSInteger,_ url:String) -> Void
/**
 获取第pageIndex个位置的contentView
 */
typealias ContentViewAtIndex = (_ pageIndex: NSInteger) -> UIView


class LFScrollView: UIView,UIScrollViewDelegate {

    /**
     定义变量数组，用于存放图片的链接地址
     */
    var urlArr = Array<String>()
    var imageViewCopy:UIImageView?
    
    /**
     定义一个轮播控制器UISCrollView
     */
    var scrollView:UIScrollView?
    /**
     声明一个PageControl ,显示当前页面的控制
     */
    var pageControl:UIPageControl?
    var currentPageIndex = NSInteger()
    //定义一个时间控制器，保证当前轮播能够自动运行
    var timerAnimation:Timer?
    var DurationAnimation = TimeInterval()
    var contentViews = NSMutableArray()
    /**
     定义Block 变量
     */
    var clickActionBlock:clickBlock?
    /**
     获取当前的View
     */
    var fetchContentViewAtIndex : ContentViewAtIndex?

    //获取图片的总数
    var _totalPageCount:NSInteger?
    var totalPageCount:NSInteger?{
        set{
            _totalPageCount = newValue
            if _totalPageCount! > 0 {
                if _totalPageCount! > 1 {
                    self.scrollView?.isScrollEnabled = true
                    self.startTimer()
                    if _totalPageCount! == 2 {
                        self.imageViewCopy = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: 200))
                    }
                }
                self.initContentView()
            }
        }
        get{
            return _totalPageCount!
        }
    }
    /**
     带有参数的初始化
     */
    init(frame: CGRect,animationDuration:TimeInterval) {
        super.init(frame: frame)
        self.DurationAnimation = animationDuration
        self.autoresizesSubviews = true
        let scrollviewFrame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frame.size.height)
        self.scrollView = UIScrollView.init(frame: scrollviewFrame)
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.contentMode = UIViewContentMode.center
        self.scrollView?.isScrollEnabled = true
        self.scrollView?.contentSize = CGSize.init(width: 3*scrollviewFrame.width, height: scrollviewFrame.height)
        self.scrollView?.delegate = self
        self.scrollView?.isPagingEnabled = true
        self.addSubview(self.scrollView!)
        self.pageControl = UIPageControl.init(frame: CGRect.init(x: (scrollviewFrame.size.width/2 - 20), y: (scrollviewFrame.size.height - 20), width: 40, height: 30))
        self.pageControl?.currentPage = 0
        self.addSubview(self.pageControl!)
        self.currentPageIndex = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //初始化页面
    func initContentView(){
        for subview in (self.scrollView?.subviews)! {
             subview.removeFromSuperview()
        }
        //初始化数据源
        self.setScrollViewContentDataSource()
        var count:CGFloat = 0
        for contentView in self.contentViews {
            let view = contentView as! UIView
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(TapAction(_:)))
            view .addGestureRecognizer(tap)
            var rightRect = view.frame
            rightRect.origin = CGPoint.init(x: UIScreen.main.bounds.width*count, y: 0)
            count += 1
            view.frame = rightRect
            self.scrollView?.addSubview(view)
        }
        
        if _totalPageCount! == 1 {
             self.scrollView?.contentOffset = CGPoint.init(x: 0, y: 0)
        }else{
            self.scrollView?.contentOffset = CGPoint.init(x: (self.scrollView?.frame.size.width)!, y: 0)
        }
    }
    
    //启动定时器
    func startTimer() {
        if self.timerAnimation != nil {
            self.timerAnimation?.invalidate()
            self.timerAnimation = nil
        }
        self.timerAnimation = Timer.scheduledTimer(timeInterval: DurationAnimation, target: self, selector: #selector(animationTimerDidFired), userInfo:nil, repeats: true)
    }
    
    func setScrollViewContentDataSource() {
        let previousPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex - 1)
        let rearPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex + 1)
        self.contentViews.removeAllObjects()
        if self.fetchContentViewAtIndex != nil {
            if _totalPageCount! == 1  {
                 self.contentViews.add(self.fetchContentViewAtIndex!(0))
            }else{
                if _totalPageCount! == 2 {
                    //如果当前是0的话，就copy1
                    if self.currentPageIndex == 0 {
                         self.imageViewCopy?.sd_setImage(with: URL.init(string: self.urlArr[1]))
                        self.contentViews.add(self.fetchContentViewAtIndex!(previousPageIndex))
                        self.contentViews.add(self.imageViewCopy!)
                    }else{
                        self.imageViewCopy?.sd_setImage(with: URL.init(string: self.urlArr[0]))
                        self.contentViews.add(self.fetchContentViewAtIndex!(previousPageIndex))
                        self.contentViews.add(self.imageViewCopy!)
                    }
                }else{
                    self.contentViews.add(self.fetchContentViewAtIndex!(previousPageIndex))
                    self.contentViews.add(self.fetchContentViewAtIndex!(self.currentPageIndex))
                    self.contentViews.add(self.fetchContentViewAtIndex!(rearPageIndex))
                }
            }
        }
        
        
    }
    
    func getValidNextPageIndexWithPageIndex(_ currentPageIndex: NSInteger) -> NSInteger {
        if currentPageIndex == -1 {
             return _totalPageCount! - 1
        }else{
            if currentPageIndex == _totalPageCount! {
                 return 0
            }else{
                return currentPageIndex
            }
        }
    }
    
    /**
     当用户点击图片时候，所执行的方法
     */
    func TapAction(_ tap: UITapGestureRecognizer) {
        if self.clickActionBlock != nil {
             self.clickActionBlock!(self.currentPageIndex,self.urlArr[self.currentPageIndex])
        }
    }
    
    func animationTimerDidFired() {
        let totalCount = round(self.scrollView!.contentOffset.x) / UIScreen.main.bounds.width
        let newOffSet = CGPoint(x: (totalCount + 1) * UIScreen.main.bounds.width, y: self.scrollView!.contentOffset.y)
        if self.pageControl!.currentPage + 1 > (_totalPageCount! - 1) {
            self.pageControl?.currentPage = 0
        }else{
            self.pageControl?.currentPage = (self.pageControl?.currentPage)! + 1
        }
        self.scrollView?.setContentOffset(newOffSet, animated: true)
    }

    
    //MARK: UIScrollViewDelegate的协议方法
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
         self.timerAnimation?.invalidate()
        self.timerAnimation = nil
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if _totalPageCount! > 1 {
             self.startTimer()
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        if contentOffsetX >= (2*UIScreen.main.bounds.size.width) {
             self.currentPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex + 1)
            self.pageControl?.currentPage = self.currentPageIndex
            self.initContentView()
        }
        if contentOffsetX <= 0 {
             self.currentPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex - 1)
            self.pageControl?.currentPage = self.currentPageIndex
            self.initContentView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
