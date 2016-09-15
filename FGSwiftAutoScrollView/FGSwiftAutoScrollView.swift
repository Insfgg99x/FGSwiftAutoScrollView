//
//  FGSwiftAutoScrollView.swift
//  FGSwiftAutoScrollViewDemo
//
//  Created by 风过的夏 on 16/9/10.
//  Copyright © 2016年 风过的夏. All rights reserved.
//

import UIKit

typealias FGImageClickBlock=(_ selectedIndex:UInt)->Void
typealias FGImageScrolledBlock=(_ index:UInt)->Void

class FGSwiftAutoScrollView: UIView,UIScrollViewDelegate{
    
    //auto scroll interval
    let fg_scrollInterval=3.0
    //disk cache path
    let fg_cachePath=NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last!+"/FGGAutomaticScrollViewCache"
    //memery cache
    let fg_imageCache=NSCache<AnyObject,AnyObject>()
    //maximun disk chache cycle
    let fg_maxCacheCycle=TimeInterval(7*24*3600)
    // tap image call action call back
    private var didSelectedImageAction:FGImageClickBlock?
    //image did scrolled call back
    public var  imageDidScrolledBlock:FGImageScrolledBlock?
    //data source
    public var  imageUrlArray:Array<String>?{
        //redifine setter
        didSet{
            //refresh UI on main queue
            DispatchQueue.main.async {
                
                self.createScrollView()
            }
        }
    }
    //main scrollView
    private var scroll:UIScrollView?
    //to ensure automatic scroll
    private var timer:Timer!
    //page control to show current page index
    private var pageControl:UIPageControl!
    //placeHolder image
    var placeHolderImage:UIImage?
    
    override init(frame:CGRect){
        super.init(frame:frame)
        self.createLoacalCacheFolder()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:- create cache area
    //MARK:create a cache area to cache web images
    private func createLoacalCacheFolder(){
        
        if !FileManager.default.fileExists(atPath: fg_cachePath){
            do{
                try FileManager.default.createDirectory(atPath: fg_cachePath, withIntermediateDirectories: true, attributes: nil)
                
            }catch{
                
            }
        }
    }
    //MARK:-Load Web Image
    //MARK:automatic scrollView with web images
    convenience init(frame:CGRect, placeHolder placeHolderImage:UIImage?,remoteImageUrls imgs:Array<String>?, selectImageAction imageDidSelectedAction:@escaping FGImageClickBlock){
        
        self.init(frame: frame)
        self.placeHolderImage=placeHolderImage
        self.didSelectedImageAction=imageDidSelectedAction
        self.imageUrlArray=imgs
        DispatchQueue.main.async {
            self.createScrollView()
        }
    }
    //MARK:Load Local Image
    //MARK:automatic scrollView with local images
    convenience init(frame:CGRect,placeHolder placeHolderImage:UIImage?,localImageNames imgs:Array<String>?, selectImageAction imageDidSelectedAction:@escaping FGImageClickBlock){
        
        self.init(frame: frame)
        self.placeHolderImage=placeHolderImage
        var fileUrlsArray:Array<String>=[]
        for name in imgs!{
            
            var path:String?
            if name.hasSuffix("jpg")||name.hasSuffix("png"){
                path=Bundle.main.path(forResource: name, ofType: nil)
            }
            else{
                path=Bundle.main.path(forResource: name, ofType: "png")
            }
            if path==nil{
                path=""
            }
            path=path?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            let fullPath=String.init(format: "file://%@", path!)
            fileUrlsArray.append(fullPath)
        }
        self.didSelectedImageAction=imageDidSelectedAction
        self.imageUrlArray=fileUrlsArray
        self.createScrollView()
    }
    //MARK:-
    //MARK:create scroll view
    private func createScrollView(){
        
        if self.scroll != nil{
            
            for sub in self.subviews {
                
                sub.removeFromSuperview()
            }
            self.scroll?.removeFromSuperview()
            self.scroll=nil
        }
        self.scroll=UIScrollView.init(frame: self.bounds)
        self.addSubview(self.scroll!)
        self.scroll?.delegate=self
        var count:Int?;
        if self.imageUrlArray==nil{
            count=0
        }else{
            count=self.imageUrlArray?.count
        }
        let width:CGFloat=CGFloat((count!+1))*self.bounds.size.width;
        let height:CGFloat=self.bounds.size.height;
        self.scroll?.contentSize=CGSize.init(width: width, height: height)
        
        self.scroll?.isPagingEnabled=true
        self.scroll?.showsHorizontalScrollIndicator=false
        
        if self.timer != nil{
            
            self.timer.invalidate()
            self.timer=nil
        }
        //detach the timer
        self.timer=Timer.scheduledTimer(withTimeInterval: fg_scrollInterval, repeats: true, block: { (t) in
            
            if self.imageUrlArray?.count==0{
                return
            }
            var index=Int((self.scroll?.contentOffset.x)!/self.bounds.size.width);
            index+=1
            if index==self.imageUrlArray?.count{
                index=0
            }
            if self.imageDidScrolledBlock != nil{
                
                self.imageDidScrolledBlock?(UInt(index))
            }
            self.pageControl.currentPage=index
            UIView.animate(withDuration: 0.2, animations: {
                self.scroll?.contentOffset=CGPoint.init(x: self.bounds.size.width*CGFloat(index), y: 0)
            })
        })
        if count!>0{
            for i in 0...count!{
                
                let xpos=CGFloat(i)*self.bounds.size.width
                let frm=CGRect.init(x: xpos, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
                let imv=UIImageView.init(frame: frm)
                imv.image=self.placeHolderImage
                imv.isUserInteractionEnabled=true
                let tap:UITapGestureRecognizer=UITapGestureRecognizer.init(target: self, action:#selector(FGSwiftAutoScrollView.tapImage))
                imv.addGestureRecognizer(tap)
                self.scroll?.addSubview(imv)
                var urlString:String?
                if i<count!{
                    
                    urlString=self.imageUrlArray?[i]
                }else{
                    urlString=imageUrlArray?.first
                }
//                self.fg_setImageWithUrlString(imageView: imv,
//                                              urlString: urlString,
//                                              placeHolder:self.placeHolderImage)
                imv.fg_setImageWithUrl(urlString: urlString, placeHolder: self.placeHolderImage)
                
            }
        }
        if self.pageControl != nil{
            self.pageControl.removeFromSuperview()
            self.pageControl=nil
        }
        let pageControlFrame=CGRect.init(x: 0, y: 0, width: 200, height: 17)
        self.pageControl=UIPageControl.init(frame: pageControlFrame)
        self.pageControl.center=CGPoint.init(x: self.bounds.size.width/2, y: self.bounds.size.height-10)
        self.pageControl.numberOfPages=count!
        self.pageControl.pageIndicatorTintColor=UIColor.init(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        self.pageControl.currentPageIndicatorTintColor=UIColor.orange
        self.addSubview(self.pageControl)
    }
    //MARK:-
    //MARK:UIScrollView Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var index=Int((self.scroll?.contentOffset.x)!/self.bounds.size.width);
        if index==self.imageUrlArray?.count{
            index=0;
        }
        if self.imageDidScrolledBlock != nil{
            
            self.imageDidScrolledBlock?(UInt(index))
        }
        self.pageControl.currentPage=index
        self.scroll?.contentOffset=CGPoint.init(x: self.bounds.size.width*CGFloat(index), y: 0)
    }
    //MARK:-
    //MARK: Tag Image Action
    func tapImage(){
        
        if self.didSelectedImageAction != nil{
            
            self.didSelectedImageAction?(UInt(self.pageControl.currentPage));
        }
    }
    deinit{
        if self.timer != nil{
            self.timer .invalidate()
            self.timer=nil
        }
    }
}
extension FGSwiftAutoScrollView{
    
    //fg_setImageWithUrlString(imageView:UIImageView?,urlString:String?,placeHolder:UIImage?)
    //async image loading like `SDWebImage` with cache in memery an disk
    func fg_setImageWithUrlString(imageView:UIImageView?,urlString:String?,placeHolder:UIImage?){
        
        if imageView==nil{
            return
        }
        imageView?.image=placeHolder
        if urlString==nil{
            return
        }
        var cachePath=fg_cachePath+"/"+String(describing: urlString?.hash)
        if (urlString?.hasPrefix("file://"))!{//local path
            cachePath=urlString!
        }
        //check the memery chache exist or not(both local and web images)
        var data=fg_imageCache.object(forKey: cachePath as AnyObject)
        if (data != nil) {//exist in memery cache
            
            DispatchQueue.main.async{
                imageView?.image=UIImage(data: data as! Data)
            }
        }else{//not in memery cache,check if exist in disk or not
            //local images
            if (urlString?.hasPrefix("file://"))!{
                
                let url:NSURL=NSURL.init(string: urlString!)!
                do{
                    try data=Data.init(contentsOf: url as URL) as AnyObject?
                }catch{
                    
                }
                //if local image exist
                if data != nil{
                    
                    fg_imageCache.setObject(data as AnyObject, forKey: cachePath as AnyObject)
                    DispatchQueue.main.async{
                        imageView?.image=UIImage(data: data as! Data)
                    }
                }
                else{//local image is not exist,just ingnore
                    //ingnore
                }
            }
                //web images
            else{
                //check if exist in disk
                let exist=FileManager.default.fileExists(atPath: cachePath)
                if exist {//exist in disk
                    //check if expired
                    var attributes:Dictionary<FileAttributeKey,Any>?
                    do{
                        try attributes=FileManager.default.attributesOfItem(atPath: cachePath)
                    }catch{
                        
                    }
                    let createDate:Date?=attributes?[FileAttributeKey.creationDate] as! Date?
                    let interval:TimeInterval?=Date.init().timeIntervalSince(createDate!)
                    let expired=(interval! > fg_maxCacheCycle)
                    if expired{//expired
                        //download image
                        self.donwloadDataAndRefreshImageView(imageView: imageView, urlString: urlString, cachePath: cachePath)
                    }
                    else{//not expired
                        //load from disk
                        let url:NSURL=NSURL.init(string: urlString!)!
                        do{
                            try data=Data.init(contentsOf: url as URL) as AnyObject?
                        }catch{
                            
                        }
                        if data != nil{//if has data
                            //cached in memery
                            fg_imageCache.setObject(data as AnyObject, forKey: cachePath as AnyObject)
                            DispatchQueue.main.async{
                                imageView?.image=UIImage(data: data as! Data)
                            }
                        }
                        else{//has not data
                            //remove item from disk
                            let url:NSURL=NSURL.init(string: urlString!)!
                            do{
                                try data=Data.init(contentsOf: url as URL) as AnyObject?
                            }catch{
                                
                            }
                            //donwload agin
                            self.donwloadDataAndRefreshImageView(imageView: imageView, urlString: urlString, cachePath: cachePath)
                        }
                    }
                }
                    //not exist in disk
                else{
                    //download image
                    self.donwloadDataAndRefreshImageView(imageView: imageView, urlString: urlString, cachePath: cachePath)
                }
            }
        }
    }
    //async download image
    private func donwloadDataAndRefreshImageView(imageView:UIImageView?,urlString:String?,cachePath:String!){
        
        do{
            try FileManager.default.removeItem(atPath: cachePath)
        }catch{
            
        }
        //download data
        let url=URL.init(string: urlString!)
        let session=URLSession.shared.dataTask(with: url!, completionHandler: { (resultData, res, err) in
            let fileUrl=URL.init(fileURLWithPath: cachePath)
            do{
                try resultData?.write(to: fileUrl, options:.atomic)
            }catch{
                
            }
            self.fg_imageCache.setObject(resultData as AnyObject, forKey: cachePath as AnyObject)
            if resultData != nil{
                DispatchQueue.main.async{
                    imageView?.image=UIImage(data: resultData!)
                }
            }
            else{
                //ingnore
            }
        })
        session.resume()
    }
}

