//
//  FGWebImage.swift
//  FGWebImage Demo
//
//  Created by 风过的夏 on 16/9/12.
//  Copyright © 2016年 风过的夏. All rights reserved.
//
/*
##async image loading like `SDWebImage` with cache in memery an disk
 ```
 fg_setImageWithUrl(imageView:UIImageView?,url?,placeHolder:UIImage?)
```
*/
import Foundation
import UIKit

// 7 days max allowed in disk cache
let fg_maxCacheCycle:TimeInterval = 7*24*3600
var fg_imageCachekey="fg_imageCachekey"

extension UIImageView{
    
    public func fg_setImageWithUrl(urlString:String?,placeHolder:UIImage?){
        
        let imageCahce=NSCache<AnyObject,AnyObject>()
        objc_setAssociatedObject(self, &fg_imageCachekey, imageCahce,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        let fg_cachePath=NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last!+"/FGGAutomaticScrollViewCache"
        self.createLoacalCacheFolder(path: fg_cachePath)
        self.image=placeHolder
        if urlString==nil{
            return
        }
        var cachePath=fg_cachePath+"/"+String(describing: urlString?.hash)
        if (urlString?.hasPrefix("file://"))!{//local path
            cachePath=urlString!
        }
        let fg_imageCache=objc_getAssociatedObject(self, &fg_imageCachekey) as? NSCache<AnyObject, AnyObject>
        //check the memery chache exist or not(both local and web images)
        var data=fg_imageCache?.object(forKey: cachePath as AnyObject)
        if (data != nil) {//exist in memery cache
            
            DispatchQueue.main.async{
                self.image=UIImage(data: data as! Data)
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
                    
                    fg_imageCache?.setObject(data as AnyObject, forKey: cachePath as AnyObject)
                    DispatchQueue.main.async{
                        self.image=UIImage(data: data as! Data)
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
                        self.donwloadDataAndRefreshImageView(urlString: urlString, cachePath: cachePath)
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
                            fg_imageCache?.setObject(data as AnyObject, forKey: cachePath as AnyObject)
                            DispatchQueue.main.async{
                                self.image=UIImage(data: data as! Data)
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
                            self.donwloadDataAndRefreshImageView(urlString: urlString, cachePath: cachePath)
                        }
                    }
                }
                    //not exist in disk
                else{
                    //download image
                    self.donwloadDataAndRefreshImageView(urlString: urlString, cachePath: cachePath)
                }
            }
        }
    }
    //async download image
    private func donwloadDataAndRefreshImageView(urlString:String?,cachePath:String!){
        
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
            let fg_imageCache=objc_getAssociatedObject(self, &fg_imageCachekey) as! NSCache<AnyObject, AnyObject>
            fg_imageCache.setObject(resultData as AnyObject, forKey: cachePath as AnyObject)
            if resultData != nil{
                DispatchQueue.main.async{
                    self.image=UIImage(data: resultData!)
                }
            }
            else{
                //ingnore
            }
        })
        session.resume()
    }
    //MARK:create a cache area to cache web images
    private func createLoacalCacheFolder(path:String){
        
        if !FileManager.default.fileExists(atPath: path){
            do{
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                
            }catch{
                
            }
        }
    }
    //inject property
    private func fg_setMemeryImageCache(_ imageCache:NSCache<AnyObject, AnyObject>){
    
          objc_setAssociatedObject(self, &fg_imageCachekey, imageCache,.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    private func fg_getMemeryImageCache()->NSCache<AnyObject, AnyObject>{
    
        return objc_getAssociatedObject(self, &fg_imageCachekey) as! NSCache<AnyObject, AnyObject>;
    }
}
