//
//  ViewController.swift
//  FGSwiftAutoScrollViewDemo
//
//  Created by 风过的夏 on 16/9/10.
//  Copyright © 2016年 风过的夏. All rights reserved.
//
//  Blog:http://cgppointzero.top
//  GitHub:https://github.com/Insfgg99x
//  Email:mailto:newbox0512@yahoo.com

import UIKit

class ViewController: UIViewController {
    
    var banner:FGSwiftAutoScrollView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.white
        self.title="FGSwiftAutoScrollViewDemo"
        self.automaticallyAdjustsScrollViewInsets=false
        
        self.createUI()
        
    }
    func createUI(){
        self.remoteImageExample()//example of load web images
//        self.localImageExample()//example of load local images
    }
    func remoteImageExample(){
        
        let web_images=["http://i.okaybuy.cn/images/multipic/new/201506/fe/fe6b322427edad3dd6c7916116a9a15b.jpg",
                        "http://i.okaybuy.cn/images/multipic/new/201505/88/888d8cf6a769c401af2ced0140fa90f3.jpg",
                        "http://i.okaybuy.cn/images/multipic/new/201506/53/532a6028830f9d7e39b5bce9e5e60e52.jpg"]
        
        let frm = CGRect.init(x: 20, y: 100, width: self.view.frame.size.width-40, height: 250)
        //One function to implement automatic scroll ad.-pic view with tap image call back.
        self.banner=FGSwiftAutoScrollView.init(frame: frm, placeHolder: nil, remoteImageUrls: web_images, selectImageAction: { (selectedIndex) in
            
            print("点击了第"+String(selectedIndex)+"张照片")
        })
        self.view.addSubview(banner!)
        //you can use the srcoll call back block simply if need (not necessary)
        self.banner?.imageDidScrolledBlock={ (currentIndex) in
            
            print("滚到到了第"+String(currentIndex)+"页了")
        }
        //test setter
        self .perform(#selector(ViewController.resetFGScrollView), with: nil, afterDelay: 5)
    }
    func localImageExample(){
        
        let local_images=["影子.jpg","2.jpg","3.jpg"]
        let frm = CGRect.init(x: 20, y: 100, width: self.view.frame.size.width-40, height: 250)
        //One function to implement automatic scroll ad.-pic view with tap image call back.
        let tmp=FGSwiftAutoScrollView.init(frame: frm, placeHolder: nil, localImageNames: local_images) { (selectedIdex) in
            
        }
        self.view.addSubview(tmp)
    }
    //reset dataSource
    func resetFGScrollView(){
        
        let array=["http://upload-images.jianshu.io/upload_images/937405-aac646d98553a5e4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                   "http://upload-images.jianshu.io/upload_images/937405-e91a649f7a7df2a0.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
                   "http://upload-images.jianshu.io/upload_images/937405-77ba31f6bdfadc02.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"]
        //call setter:
        self.banner?.imageUrlArray=array
        print("reset data source")
    }
}


