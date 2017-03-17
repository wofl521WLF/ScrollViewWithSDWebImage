//
//  ViewController.swift
//  ScrollViewSwift
//
//  Created by 吴林丰 on 2017/3/13.
//  Copyright © 2017年 吴林丰. All rights reserved.
//

import UIKit
import SDWebImage


class ViewController: UIViewController {
    var imageViewArray = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        let  ScView = LFScrollView.init(frame: CGRect.init(x: 0, y: 64, width: self.view.frame.width, height: 200), animationDuration: 3.0)
        self.view.addSubview(ScView)
        //设置轮播图的数组URL
        let dataArray = ["http://img04.sogoucdn.com/app/a/100520020/50c11a6a4b7a4da664e93a9cf4c061ce",
                         "http://img04.sogoucdn.com/app/a/100520024/1f9163519dac6b2138c7d96b5598467e",
                         "http://img01.sogoucdn.com/app/a/100520024/e2f057ede9d3cafabed15418bad2ee17",
                         "http://img04.sogoucdn.com/app/a/100520024/f4d580ab0d9f5d514c9471b23bba0561",
                         "http://img03.sogoucdn.com/app/a/100520024/30e8009fb8710f519b565b1cd17df7ec",
                         "http://img02.sogoucdn.com/app/a/100520020/992e6ea334d3d1c34abfa5ea1ec0978a"]
        //创建加载图片的imageview
        for index in 0 ..< dataArray.count {
            let imageview = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 200))
            imageview.sd_setImage(with: URL.init(string: dataArray[index]))
            self.imageViewArray.add(imageview)
            
        }
        
        
        //闭包返回相应的view
        ScView.fetchContentViewAtIndex = {(pageIndex:NSInteger) in
            return (self.imageViewArray[pageIndex] as! UIView)
        }
        ScView.urlArr = dataArray
        ScView.totalPageCount = self.imageViewArray.count
        ScView.pageControl?.numberOfPages = self.imageViewArray.count
        ScView.clickActionBlock = {(pageIndex:NSInteger,url:String) in
            print("\(pageIndex) ---- \(url)")
        }
        
        
        
        
        
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

