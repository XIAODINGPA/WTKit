//
//  JSONModel.swift
//  WTKit
//
//  Created by SongWentong on 21/11/2016.
//  Copyright © 2016 songwentong. All rights reserved.
//  https://github.com/swtlovewtt/WTKit
//
/*
  自动生成Codable的对象,可以处理字段和swift关键字重名的情况,能正确处理super,import,class这类字段
 可在属性添加前缀和后缀,自动解析嵌套类型,用JSONDecoder读取json数据可以直接生成一个已经赋值的类的实例.
 */
import Foundation
public class WTModelMaker {
    public var namesNeedAddSuffix:[String] = ["super","class","var","let","sturct","func","private","public","open","return","import"];
    public var varPrefix = ""
    public var varSuffix = "_var"
    open static let `default`:WTModelMaker = {
       return WTModelMaker()
    }()
    public func randomClassName(with prefix:String)->String{
        let randomNumber = arc4random_uniform(150)
        let suffix = String.init(randomNumber)
        return prefix+suffix
    }
    
    private func headerString(className:String)->String{
        let date:Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        var stringToPrint = ""
        stringToPrint += "//\n//  \(className).swift\n"
        stringToPrint += "//\n//  this file is auto create by WTKit on \(dateString).\n"
        stringToPrint += "//  site:https://github.com/swtlovewtt/WTKit\n//  Thank you for use my json model maker😜\n//\n\n"
        return stringToPrint;
    }
    private func nameReplace(with origin:String)->String{
        
        var dict:[String:String] = [String:String]()
        for key in namesNeedAddSuffix{
            dict[key] = varPrefix + key + varSuffix
        }
        if dict.keys.contains(origin){
            return dict[origin]!
        }
        return origin
    }
    
    /// 尝试打印出一个json对应的Model属性
    /// NSArray和NSDictionary可能需要自定义为一个model类型
    public func WTSwiftModelString(with className:String = "XXX", jsonString:String,usingHeader:Bool = false)->String{
        
        var stringToPrint:String = String()
        var codingKeys:String = String()
        
        if usingHeader == true {
            stringToPrint += headerString(className: className)
        }
        var subModelDict:[String:String] = [String:String]()
        stringToPrint += "public struct \(className): Codable {\n"
        codingKeys = "    enum CodingKeys: String, CodingKey {\n"
        var jsonObject:Any? = nil
        do {
            if let data = jsonString.data(using: String.Encoding.utf8){
                jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            }
        } catch {
            
        }
        if let printObject = jsonObject as? [String:AnyObject] {
            for (key,value) in printObject{
                let nameReplacedKey = nameReplace(with: key)
                if let classForCoder = value.classForCoder {
                    var string = NSStringFromClass(classForCoder)
                    if string == "NSString" {
                        string = "String"
                        stringToPrint += "    var \(nameReplacedKey):\(string)\n"
                        codingKeys += "        case \(nameReplacedKey) = \"\(key)\"\n"
                    }else if string == "NSNumber"{
                        //char, short int, int, long int, long long int, float, or double or as a BOOL
                        // “c”, “C”, “s”, “S”, “i”, “I”, “l”, “L”, “q”, “Q”, “f”, and “d”.
                        //1->q    true->c     1.0->d   6766882->q   6766882.1->d   0->q   false->c
                        let number:NSNumber = value as! NSNumber
                        let objCType = number.objCType
                        let type = String.init(cString: objCType)
                        switch type{
                        case "c":
                            string = "Bool"
                            break
                        case "q":
                            string = "Int"
                            break
                        case "d":
                            string = "Double"
                            break
                        default:
                            string = "Int"
                            break
                        }
                        stringToPrint += "    var \(nameReplacedKey):\(string)\n"
                        codingKeys += "        case \(nameReplacedKey) = \"\(key)\"\n"
                    } else if string == "NSArray"{
                        if value is [Int]{
                            //print("int array")
                            stringToPrint += "    var \(nameReplacedKey):[Int]\n"
                            codingKeys += "        case \(nameReplacedKey) = \"\(key)\"\n"
                        }else if value is [String]{
                            //print("string array")
                            stringToPrint += "    var \(nameReplacedKey):[String]\n"
                            codingKeys += "        case \(nameReplacedKey) = \"\(key)\"\n"
                        }else{
                            stringToPrint += "    //var \(nameReplacedKey):[Any]\n"
                            codingKeys += "        //case \(nameReplacedKey) = \"\(key)\"\n"
                            
                        }
                        
                    }else if string == "NSDictionary"{
                        if value is [String:Int]{
                            stringToPrint += "    var \(nameReplacedKey):[String:Int]\n"
                            codingKeys += "        case \(nameReplacedKey) = \"\(key)\"\n"
                        }else if value is [String:String]{
                            stringToPrint += "    var \(nameReplacedKey):[String:String]\n"
                            codingKeys += "        case \(nameReplacedKey) = \"\(key)\"\n"
                        }else{
//                            stringToPrint += "    //var \(key):[String:Any]\n"
//                            let tempClassName = self.randomClassName(with: key)
                            let tempData = try! JSONSerialization.data(withJSONObject: value, options: [])
                            let tempString = String.init(data: tempData, encoding: String.Encoding.utf8)
                            subModelDict[key] = tempString
                            stringToPrint += "    var \(nameReplacedKey):\(key)\n"
                            codingKeys += "        case \(nameReplacedKey) = \"\(key)\"\n"
                        }
                    }
                    
                }
            }
        }
        codingKeys += "}\n"
        stringToPrint += codingKeys
        stringToPrint += "}\n"
        for (key,value) in subModelDict{
            stringToPrint += WTSwiftModelString(with: key, jsonString: value)
        }
        return stringToPrint
//        print("\(stringToPrint)")
    }
    
    
}





























