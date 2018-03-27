//
//  Chart.swift
//  WTKit
//
//  Created by SongWentong on 06/04/2017.
//  Copyright © 2017 songwentong. All rights reserved.
//  
//  股票图绘制

import Foundation
#if os(iOS)
import UIKit
public enum ChartViewDrawType:Int
{
    case NONE//painting Nothing , usually in this case may only be used to draw lines
    case KDJ//Candle chart🕯
    case VOL//Histogram📊 VOL
    case CIRCLE//Circle⭕️
}
public protocol ChartViewDelegate
{
    //optional func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func chartView(_ chartView:ChartView, showing index:Int)->Void
}

public protocol ChartViewDataSource
{
    //values count
    func numberOfValues(in chartView:ChartView)->Int
    //draw type
    func drawType(of chartView:ChartView)->ChartViewDrawType
    //min
    func minValue(of chartView:ChartView)->Double
    //max
    func maxValue(of ChartView:ChartView)->Double
}
//just line
public protocol LineChartViewDataSource:ChartViewDataSource
{
    //number of lines
    func numberOfLines(in chartView:ChartView)->Int
    //line color
    func chartView(_ chartView:ChartView,colorForLineAt index:Int)->UIColor
    //values
    func chartView(_ chartView:ChartView,_ lineIndex:Int,_ valueIndex:Int)->Double
}
public protocol FullLineChartViewDataSource:LineChartViewDataSource
{
    //line with
    func chartView(_ chartView:ChartView,widthForLineAt index:Int)->Int
}
//candle 🕯
public protocol CandleChartViewDataSource:ChartViewDataSource{
    //open
    func chartView(chartView:ChartView,openValueAt index:Int)->Double
    //close
    func chartView(chartView:ChartView,closeValueAt index:Int)->Double
    //high
    func chartView(chartView:ChartView,highValueAt index:Int)->Double
    //low
    func chartView(chartView:ChartView,lowValueAt index:Int)->Double
    //color
}
/*
    Histogram📊 ,VOL
 */
public protocol VOLChartViewDataSource:ChartViewDataSource{
    //value
    func chartView(chartView:ChartView,valueFor Index:Int)->Int
    //color
    func chartView(chartView:ChartView,colorFor index:Int)->UIColor
}
/*
    circle⭕️  ,SAR
 */
public protocol circleChartViewDataSource:ChartViewDataSource{
    //value
    func chartView(chartView:ChartView,circleIndex:Int)->Double
    //colot
}
/*
    empty implement of ChartViewDataSource
 */
private class ChartViewDataSourceEmptyClass:ChartViewDataSource{
    //数值的数量
    func numberOfValues(in chartView:ChartView)->Int{
        return 0
    }
    //绘制的类型
    func drawType(of chartView:ChartView)->ChartViewDrawType{
        return .NONE
    }
    //绘制的颜色
    func chartView(chartView:ChartView,colorAt index:Int)->UIColor{
        return UIColor.clear
    }
    //min
    func minValue(of chartView:ChartView)->Double{
        return 0
    }
    //max
    func maxValue(of ChartView:ChartView)->Double{
        return 100
    }
}
private class ChartViewDelegateEmptyClass:ChartViewDelegate{
    func chartView(_ chartView: ChartView, showing index: Int) {
            
    }
}
//it not finished
public class ChartView:UIView{
    public var dataSource:ChartViewDataSource = ChartViewDataSourceEmptyClass()
    public var delegate:ChartViewDelegate = ChartViewDelegateEmptyClass()
    var drawType:ChartViewDrawType = .NONE
    var bezierPath:UIBezierPath = UIBezierPath()
    var numberOfValues:Int = 0
    var needRedraw:Bool = true
    var widthBetweenValues:Double = 0
    var minValue:Double = 0
    var maxValue:Double = 100
    var delta:Double = 0
    var distanceBetweenValues:Double = 0
    open func reloadData(){
        setNeedsDisplay()
    }
    open override func draw(_ rect: CGRect) {
        redrawIfNeeded()
    }
    func redrawIfNeeded(){
        if needRedraw {
            drawCustomType()
            drawLinesIfNeeded()
            bezierPath.stroke()
            needRedraw = false
        }
        
    }

    func drawCustomType(){
        minValue = dataSource.minValue(of: self)
        maxValue = dataSource.maxValue(of: self)
        numberOfValues = dataSource.numberOfValues(in: self)
        drawType = dataSource.drawType(of: self)
        widthBetweenValues = Double(self.frame.size.width)/Double(numberOfValues)
        delta = maxValue - minValue
        distanceBetweenValues = Double(self.frame.size.width) / Double(numberOfValues)
        switch drawType {
        case .NONE:
            doNothing()
            break
        case .KDJ:
            drawKDJ()
            break
        case .VOL:
            drawVOL()
            break
        case .CIRCLE:
            drawCIRCLE()
            break
        }
    }
    func drawLinesIfNeeded(){
        if let lineDataSource:LineChartViewDataSource = dataSource as? LineChartViewDataSource {
            let numberOfLines = lineDataSource.numberOfLines(in: self)
            for i in 0...numberOfLines{
                let color = lineDataSource.chartView(self, colorForLineAt: i)
                var linePath:UIBezierPath? = nil
                color.setStroke()
                for j in 0...numberOfValues{
                    let value = lineDataSource.chartView(self, i, j)
                    //bezier path will not create untile value is not nan
                    if value.isNaN {
                        //do nothing
                    }else{
                        let point = CGPoint(x: widthBetweenValues * Double(j), y:Double(self.frame.size.height) - Double(value))
                        print("\(point)")
                        if linePath == nil {
                            linePath = UIBezierPath()
                            linePath?.lineWidth = 1
                            linePath?.move(to: point)
                        }else{
                            linePath?.addLine(to: point)
                        }
                    }
                }
                if let temp = linePath {
                    temp.stroke()
                }
            }
        }
    }
    
    func doNothing(){
        
    }
    func drawKDJ(){
        /*
        open,close,high,low
         */
    
    }
    func drawVOL(){
        /*
         |-2-H-2-H-2-|
         (hiswidth + 1) * numberOfValues = width
         hiswidth = (width - 1) / numberofvalue -1
         */
        let pixelDistanceBetweenTwoVOL:Double = 1
        let hisWidth:Double = (Double(self.frame.size.width) - pixelDistanceBetweenTwoVOL) / Double(numberOfValues) - pixelDistanceBetweenTwoVOL
        
        if let vol:VOLChartViewDataSource = dataSource as? VOLChartViewDataSource {
            for index in 0...numberOfValues{
                
                let value = vol.chartView(chartView: self, valueFor: index)
                let rect = CGRect(x: Double(index) * (hisWidth + pixelDistanceBetweenTwoVOL) + 1 , y: 0, width: hisWidth, height: Double(value))
                let bezierPath = UIBezierPath.init(rect: rect)
                let color = vol.chartView(chartView: self, colorFor: index)
                color.setFill()
                bezierPath.fill()
            }
        }
    
    }
    func drawCIRCLE(){
        /*
         just circle ⭕️
         */
    }

    
    //touch events
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
#endif
