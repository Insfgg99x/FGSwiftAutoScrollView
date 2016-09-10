##FGSwiftAutoScrollView
...................................................................................
###Introduction
A class with ad. pics auotmatic scrolling build in swift with image cache policy used.
![](https://github.com/Insfgg99x/FGGAutomaticScrollView/blob/master/demo.gif)
###Installtion
Manual:

Download This Project and drag the `FGSwiftAutoScrollView` folder into your peroject, do not forget to ensure "copy item if need" being selected.
```

###Usage
- Load Web Images：
```
    //MARK:-
    //MARK:automatic scrollView with web images
    convenience init(frame:CGRect, placeHolder placeHolderImage:UIImage?,remoteImageUrls imgs:Array<String>?, selectImageAction imageDidSelectedAction:@escaping FGImageClickBlock){
        
        self.init(frame: frame)
        self.createLoacalCacheFolder()
        self.placeHolderImage=placeHolderImage
        self.didSelectedImageAction=imageDidSelectedAction
        self.imageUrlArray=imgs
        DispatchQueue.main.async {
            self.createScrollView()
        }
    }
```
- Load Local Images：
```
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
```
- you can simply use the srcoll call back block if need (not necessary)
```
self.banner?.imageDidScrolledBlock={ (currentIndex) in
            
            print("滚到到了第"+String(currentIndex)+"页了")
}
```
###Explain：
If you don't need add image tap action, property didSelectedImageAction  block can be nil.
###About Me
- Blog:     [CGPointZeero](http://cgpointzero.top)
- GitHub:   [Insfgg99x](https://github.com/Insfgg99x)
- Mooc:     [CGPointZero](http://www.imooc.com/u/3909164/articles)
- Jianshu:  [CGPointZero](http://www.jianshu.com/users/c3f2e8c87dc4/latest_articles)
- Email:    [newbox0512@yahoo.com](mailto:newbox0512@yahoo.com)

...............................................................................

Copyright (c) 2016 CGPointZero. All rights reserved.<br>
