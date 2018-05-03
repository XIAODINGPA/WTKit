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
extension NSValue{
    func objCTypeString() -> String {
        let objCType = self.objCType
        let type = String.init(cString: objCType)
        return type
    }
}
public class WTModelMaker {
    public var commonKeywords:[String] = ["super","class","var","let","struct","func","private","public","return","import","protocol"]//常用的关键字命名修改,如有需要可以添加
    public var keywordsVarPrefix = ""//关键字属性的前缀,如有需要可以添加
    public var keywordsVarSuffix = "_var"//关键字属性的后缀,默认添加的是_var
    public var needQuestionMark:Bool = false //是否需要添加问号,来处理字段不存在的情况,true+问号?,否则不用加
    public var useStruct = true //true用struct,false用class
    public var shouldHasDefaultValut = false //是否需要默认值，如果需要默认值
    public var convertNumberToString = false //数字转换成字符串
    public var indent:String = "    "//缩进
    public let crlf = "\n"//换行
    
    
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
        if commonKeywords.contains(origin){
            return keywordsVarPrefix + origin + keywordsVarSuffix
        }
        return origin
    }
    
    func QuestionMarkIfNeeded() -> String {
        if needQuestionMark{
            return "?"
        }
        return ""
    }
    func getClassOrStructName() -> String {
        if useStruct {
            return "struct"
        }else{
            return "class"
        }
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
        
        stringToPrint += "public"
        stringToPrint += " "
        stringToPrint += getClassOrStructName()
        stringToPrint += " "
        stringToPrint += "\(className): Codable {" + crlf
        codingKeys = "    enum CodingKeys: String, CodingKey {" + crlf
//        var varList:String = String()
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
                stringToPrint += crlf
                stringToPrint += indent
                
                if let classForCoder = value.classForCoder {
                    
                    var string = NSStringFromClass(classForCoder)
                    var codableValue = true
                    if string == "NSArray"{
                        if value is [Int] || value is [String]{
//                            print("\(key)")
                        }else{
//                            print("\(key)")
                            codableValue = false
                        }
                    }
                    if !codableValue{
                        stringToPrint += "//"
                    }
                    stringToPrint += "var \(nameReplacedKey): "
                    if string == "NSString" {
                        string = "String"
                        stringToPrint += "\(string)"
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
                        stringToPrint += "\(string)"
                        
                    } else if string == "NSArray"{
                        if value is [Int]{
                            //print("int array")
                            stringToPrint += "[Int]"
                        }else if value is [String]{
                            //print("string array")
                            stringToPrint += "[String]"
                        }else{
                            stringToPrint += "//[Any]"
                        }
                        
                    }else if string == "NSDictionary"{
                        if value is [String:Int]{
                            stringToPrint += "[String: Int]"
                        }else if value is [String:String]{
                            stringToPrint += "[String: String]"
                        }else{
                            let tempData = try! JSONSerialization.data(withJSONObject: value, options: [])
                            let tempString = String.init(data: tempData, encoding: String.Encoding.utf8)
                            subModelDict[nameReplacedKey] = tempString
                            stringToPrint += "\(nameReplacedKey)"
                        }
                    }
                    codingKeys += crlf
                    codingKeys += indent
                    codingKeys += indent
                    if !codableValue{
                        codingKeys += "//"
                    }
                    codingKeys += "case \(nameReplacedKey) = \"\(key)\""
                    codingKeys += crlf
                    
                }
                stringToPrint += QuestionMarkIfNeeded()
                stringToPrint += crlf
                
            }
        }
        codingKeys = codingKeys + indent + "}" + crlf
        stringToPrint = stringToPrint + "\n" + codingKeys + "}" + crlf
        for (key,value) in subModelDict{
            stringToPrint += WTSwiftModelString(with: key, jsonString: value)
        }
        return stringToPrint
//        print("\(stringToPrint)")
    }
}
