//
//  FoundationExtension.swift
//  WTKit
//
//  Created by SongWentong on 4/21/16.
//  Copyright © 2016 SongWentong. All rights reserved.
//  https://github.com/songwentong/WTKit
//
import Foundation
#if os(iOS)
//    import SystemConfiguration
    import CoreFoundation
    import CoreGraphics
    //    import MobileCoreServices
    import UIKit
#elseif os(OSX)
    import CoreServices
#endif

// MARK: - 用于DEBUG模式的print,强烈推荐使用
/*!
 用于DEBUG模式的log
 */
public func WTPrint<T>(_ items:T,
                    separator: String = " ",
                    terminator: String = "\n",
                    file: String = #file,
                    method: String = #function,
                    line: Int = #line)
{
    DEBUGClosure {
        print("\((file as NSString).lastPathComponent)[\(line)], \(method)")
        print(items,separator: separator,terminator: terminator)
    }
}

/*!
 用于WTKit内部log
 只有在debug下并且WTKitLogMode是true的情况下输出
 */
private let WTKitLogMode:Bool = false
public func WTLog(
    _ items: Any...,
    separator: String = " ",
    terminator: String = "\n",
    file: String = #file,
    method: String = #function,
    line: Int = #line
    ) {
    DEBUGClosure {
        if WTKitLogMode{
            WTPrint(items)
        }
    }
}


// MARK: - DEBUG执行的方法
public func DEBUGBlock(_ block:() -> Void){
    DEBUGClosure(block)
}
public func DEBUGClosure(_ closure:()->Void){
    #if DEBUG
        closure()
    #else
    #endif
}
public func ReleaseClosure(_ work:()->Void){
    #if DEBUG
    #else
        work()
    #endif
}



// MARK: - 延时执行的代码块
/*!
 延时执行的代码块
 */
public func performOperation(with block:@escaping ()->Void, afterDelay:TimeInterval){
    //Swift 不允许数据在计算中损失,所以需要在计算的时候转换以下类型
    let time = Int64(afterDelay * Double(NSEC_PER_SEC))
    let t = DispatchTime.now() + Double(time) / Double(NSEC_PER_SEC)
    //    DispatchQueue.main.after(when: t, execute: block)
    DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    
}
/*
 func bridge<T : AnyObject>(obj : T) -> UnsafeRawPointer {
 //    return UnsafeRawPointer(bitPattern: Unmanaged.passUnretained(obj).toOpaque())
 return UnsafePointer(Unmanaged.passUnretained(obj).toOpaque())
 // return unsafeAddress(of: obj) // ***
 }
 
 func bridge<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
 return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
 // return unsafeBitCast(ptr, to: T.self) // ***
 }
 
 func bridgeRetained<T : AnyObject>(obj : T) -> UnsafeRawPointer {
 return UnsafePointer( Unmanaged.passRetained(obj).toOpaque())
 }
 
 func bridgeTransfer<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
 return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
 }
 */



extension UInt{
    
    
    /*!
     计算阶乘
     */
    public static func wt_factorial(number:UInt)->UInt{
        if number == 1 {
            return 1
        }else{
            return number * wt_factorial(number: (number - 1))
        }
        
        
    }
}
extension Int{
    
    
    
    /*!
     斐波那契数列,用递归实现的,容易出现栈溢出,推荐用颗粒化来做
     */
    public static func wt_fibonacci(number:UInt)->UInt{
        if number <= 1 {
            return 1
        }else{
            return wt_fibonacci(number: number - 2) + wt_fibonacci(number: number - 1)
        }
    }
    
    
    
    /*
     public static func wt_fibonacciCurry(number:Int)->Int{
     var total:Int = 0
     func sum(number1:Int)->Int{
     if number1 == 1 || number1 == 0 {
     return 1
     }else{
     return sum(number1: number1 - 2) + sum(number1: number1 - 1)
     }
     }
     return sum(number1: number - 2) + sum(number1: number - 1)
     }
     */
    
    
    public func isEven() -> Bool{
        return (self%2) == 0
    }
    
    /*!
     尾递归
     */
    func tailSum(_ n: UInt) -> UInt {
        func sumInternal(_ n: UInt, current: UInt) -> UInt {
            if n == 0 {
                return current
            } else {
                return sumInternal(n - 1, current: current + n)
            }
        }
        
        return sumInternal(n, current: 0)
    }
}


extension NSObject{
    
    
    /*!
     交换实例方法
     */
    public static func exchangeInstanceImplementations(_ func1:Selector , func2:Selector){
        method_exchangeImplementations(class_getInstanceMethod(self, func1)!, class_getInstanceMethod(self, func2)!);
    }
    
    /*!
     交换类方法
     */
    public static func exchangeClassImplementations(_ func1:Selector , func2:Selector){
        method_exchangeImplementations(class_getClassMethod(self, func1)!, class_getClassMethod(self, func2)!);
    }
    
    
    public func performBlock(_ block: @escaping () -> Void , afterDelay:Double){
        //Swift 不允许数据在计算中损失,所以需要在计算的时候转换以下类型
        let time = Int64(afterDelay * Double(NSEC_PER_SEC))
        let t:DispatchTime = DispatchTime.now() + Double(time) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
        //        DispatchQueue.main.after(when: t, execute: block)
        //        DispatchQueue.main.after(when: t, block: block)
        
    }
    
    /*!
     递归遍历:先深度
     note:必须是可用的的json对象
     */
    public static func traversal(_ obj:AnyObject){
        //        if JSONSerialization.isValidJSONObject(obj) {
        if let array = obj as? Array<AnyObject> {
            for item in array{
                traversal(item)
            }
        }else if let dict = obj as? Dictionary<String,AnyObject>{
            for (_,value) in dict{
                traversal(value)
            }
        }else {
            print("----------  \(obj)")
        }
        //        }
    }
    
    
    /*!
     遍历,层次遍历
     */
    
    public static func wt_traversal(with obj:AnyObject){
        //当前层数
        var theLevel = 0
        
        //所有的数据
        var levels = [AnyObject]()
        levels.append(obj)
        
        //仓前曾的数组
        var currentLevel:[AnyObject] = [AnyObject]()
        
        
        print("start t")
        repeat{
            currentLevel = [AnyObject]()
            let currentObject:AnyObject = levels[theLevel]
            
            if let array = currentObject as? [AnyObject]{
                print(array)
                currentLevel.append(contentsOf: array)
            }else if let dict = currentObject as? Dictionary<String,AnyObject>{
                print(dict)
                for (_,v) in dict{
                    print(v)
                    currentLevel.append(v)
                }
                //                currentLevel.append(contentsOf: dict.values)
            }else{
                print(currentObject)
            }
            theLevel = theLevel + 1
            levels.append(currentLevel as AnyObject)
        }while currentLevel.count != 0
        print("end t")
        
    }
    
    
    /*!
     非递归遍历
     */
    /*
     public static func wt_tarversal(with obj:AnyObject){
     
     func tarversalOneDepth(with objects:AnyObject)->[AnyObject]{
     
     
     var result = [AnyObject]()
     if let array:[AnyObject] = objects as? Array<AnyObject>{
     for t in array{
     if let u:[AnyObject] = t as?Array<AnyObject> {
     result.append(contentsOf: u)
     }else if let v:[String:AnyObject] = t as? Dictionary<String,AnyObject>{
     result.append(contentsOf: v.values)
     }
     }
     }
     return result
     
     }
     
     var tempArray = [AnyObject]()
     tempArray.append(obj)
     
     
     repeat{
     let r = tarversalOneDepth(with: tempArray)
     for a in r{
     print("print : \(a)")
     }
     tempArray = r
     }while (tempArray.count != 0)
     
     }
     */
    
}

//数据缓存
private var wt_sharedURLCacheForRequestsKey:Void?
extension URLCache{
    
    
    /*
      public static let wt_sharedInstance:URLSession = {
     let delegate = WTURLSessionManager.sharedInstance
     let configuration = URLSessionConfiguration.default
     configuration.urlCache = URLCache.wt_sharedURLCacheForRequests()
     let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: OperationQueue())
     return session
     
     }()
     */
    /*!
     数据缓存
     */
//    public static let wt_sharedURLCacheForRequests:URLCache={
//        let cache = URLCache(memoryCapacity: 4*1024*1024, diskCapacity: 1*1024*1024*1024, diskPath: "wt_sharedURLCacheForRequestsKey")
//        return cache
//    }()
    
    
    
    
}
extension Array{
    
    /*!
     排序方法,这个方法的效率很垃圾,不要尝试使用,想优化的帮我优化一下吧.
     mutating 代表该方法将会改变该对象的内部结构,比如排序什么的.
     */
    /*
     public mutating func wtSort( _ isOrderedBefore: @noescape(Array.Iterator.Element, Array.Iterator.Element) -> Bool)->Array!{
     //        let result = self;
     let count = self.count-1
     for i in 0..<count{
     var obj1 = self[i]
     var obj2 = self[i+1]
     if(isOrderedBefore(obj1,obj2) == true){
     swap(&obj1, &obj2)
     }
     }
     for i in 0..<count{
     let obj1 = self[i]
     let obj2 = self[i+1]
     if(isOrderedBefore(obj1,obj2) == true){
     self.wtSort(isOrderedBefore)
     }
     }
     
     return self
     }
     */
    
    
    
    
}


extension Dictionary{
    
}
extension Data{
    
    /*!
     utf-8 string
     */
    public func toUTF8String()->String{
        let string = String.init(data: self, encoding: String.Encoding.utf8)
        if string == nil {
            return ""
        }
        return string!
    }
    
    /*!
     Create a Foundation object from JSON data.
     */
    public func parseJson()->Any?{
        var obj:Any?
        do{
            try obj = JSONSerialization.jsonObject(with: self, options: [])
        } catch _{
        }
        return obj
    }
    
    /*!
     Create a Foundation object from JSON data.
     */
    public func parseJSON(handler block:jsonHandler){
        var obj:Any? = nil
        var theError:NSError?
        do{
            try obj = JSONSerialization.jsonObject(with: self, options: .mutableLeaves)
        }catch let error as NSError{
            theError = error
        }
        block(obj,theError)
    }
    //public func +(lhs: Date, rhs: TimeInterval) -> Date
    
    
}
//public func +(lhs: [String],rhs: [String]) -> [String]{

//}

public func +(lhs: Data, rhs: Data) -> Data{
    var data = lhs
    data.append(rhs)
    return data
}
public func +=(lhs: inout Data, rhs: Data){
    lhs.append(rhs)
}
/*
 extension Date{
 public func numberFor(component unit:Calendar.Unit)->Int{
 return Calendar.current.component(unit, from: self)
 }
 public var year:Int{
 get{
 return numberFor(component: .year)
 }
 }
 public var month:Int{
 get{
 return numberFor(component:.month)
 }
 }
 public var day:Int{
 get{
 return numberFor(component:.day)
 }
 }
 public var hour:Int{
 get{
 return numberFor(component:.hour)
 }
 }
 public var weekOfYear:Int{
 get{
 return numberFor(component: .weekOfYear)
 }
 }
 public var minute:Int{
 get{
 return numberFor(component:.minute)
 }
 }
 public var second:Int{
 get{
 return numberFor(component:.second)
 }
 }
 public func stringWithDateFormat(_ format:String)->String{
 let dateFormatter = DateFormatter()
 dateFormatter.dateFormat = format
 dateFormatter.locale = Locale.current
 return dateFormatter.string(from: self)
 }
 
 
 }
 */
extension NSPredicate{
}

extension NSRegularExpression{
    
    public static func wt_englishWord()->NSRegularExpression{
        var r:NSRegularExpression?
        do{
            try r = NSRegularExpression(pattern: "^\\w+$", options: [])
        } catch _{
        }
        
        return r!
    }
    public static func wt_eMail()->NSRegularExpression{
        var r:NSRegularExpression?
        do{
            try r = NSRegularExpression(pattern: "[\\w!#$%&'*+/=?^_`{|}~-]+(?:\\.[\\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\\w](?:[\\w-]*[\\w])?\\.)+[\\w](?:[\\w-]*[\\w])?", options: [])
        } catch _{
        }
        
        return r!
    }
    public static func wt_phoneNumber()->NSRegularExpression{
        var r:NSRegularExpression?
        do{
            try r = NSRegularExpression(pattern: "^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\\d{8}$", options: [])
        } catch _{
        }
        
        return r!
    }
    
    public static func wt_ipv4()->NSRegularExpression{
        var r:NSRegularExpression?
        do{
            try r = NSRegularExpression(pattern: "\\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\b", options: [])
        } catch _{
        }
        return r!
    }
    public static func wt_ipv6()->NSRegularExpression{
        var r:NSRegularExpression?
        do{
            try r = NSRegularExpression(pattern: "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))", options: [])
        } catch _{
        }
        return r!
    }
}


extension String{
    
    //TODO MD5
    
    //"$＄¥￥231"
    /*!
     半角的RMB符号，加删除线的时候比较方便,不会和数字看起来不同
     Half-width
     注意:如果是全角的和数字放在一起加删除线不会连接在一起
     
     ¥ 全角 ￥半角
     */
    public static func RMBSymbol()->String{
        return "¥"
    }
    
    /*!
     half-width dollar
     $ 半角   ＄全角
     */
    public static func DollarSymbol()->String{
        return "$"
    }
    
    subscript(range:Range<Int>)->String{
        get{
            
            let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: range.upperBound);
            return String(self[startIndex..<endIndex])
        }
    }
    /*
    public var length:Int{
        return self.count
    }
    */
    //将十六进制字符串转换成十进制
    public static func changeToInt(_ num:String) -> Int{
        
        let str = num.uppercased();
        var result = 0
        for i in str.utf8{
            result = result*16 + Int(i) - 48   //0-9   48开始
            if  i >= 65 {     // A-Z   65开始
                result -= 7
            }
        }
        return result;
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    var intValue:Int{
        return (self as NSString).integerValue
    }
    
    public func parseJSON(handler block:jsonHandler)->Void{
        let data = self.data(using: String.Encoding.utf8)
        data?.parseJSON(handler: block)
    }
    
    public func toUTF8Data()->Data{
        var data = self.data(using: String.Encoding.utf8)
        if data == nil {
            data = Data()
        }
        return data!
    }
    
    
    #if os(iOS)
    /*!
     *  用于计算文字高度
     */
    public func boundingRectWithSize(_ size: CGSize, options: NSStringDrawingOptions, attributes: [NSAttributedStringKey : AnyObject]?, context: NSStringDrawingContext?) -> CGRect{
        let string:NSString = self as NSString
        return string.boundingRect(with: size, options: options, attributes: attributes, context: context)
    }
    #endif
}



/*
 print 的源码
 @inline(never)
 @_semantics("stdlib_binary_only")
 public func print(
 _ items: Any...,
 separator: String = " ",
 terminator: String = "\n"
 ) {
 if let hook = _playgroundPrintHook {
 var output = _TeeStream(left: "", right: _Stdout())
 _print(
 items, separator: separator, terminator: terminator, to: &output)
 hook(output.left)
 }
 else {
 var output = _Stdout()
 _print(
 items, separator: separator, terminator: terminator, to: &output)
 }
 }
 */


