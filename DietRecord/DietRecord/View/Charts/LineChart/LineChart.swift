//
//  LineChart.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import Foundation
import Charts

class LineChart: LineChartView, ChartViewDelegate {
    private var referenceTimeInterval: TimeInterval = 0
    
    init(frame: CGRect, superview: UIView) {
        super.init(frame: frame)
        initView(superview: superview)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView(superview: UIView) {
        superview.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        configureConstraint(superview: superview)
        delegate = self
    }
    
    private func configureConstraint(superview: UIView) {
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            self.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 1),
            self.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    
    func setWeightLineChart(datas: [WeightData], goal: Double) {
        self.backgroundColor = UIColor.clear // 背景設為透明
        self.noDataText = "請輸入體重紀錄" // 折線圖無數據時，顯示的提示文字
        self.chartDescription.text = "" // 折線圖描述文字和樣式
        self.scaleYEnabled = false // y軸不能縮放
        self.doubleTapToZoomEnabled = false // 雙擊縮放關閉
        self.dragEnabled = true // 啟用拖移手勢
        self.dragDecelerationEnabled = true // 拖移後是否有慣性效果
        self.dragDecelerationFrictionCoef = 0.9 // 拖移後慣性效果摩擦係數(0~1)，數值越小慣性越不明顯
        
        if let minTimeInterval = (datas.map { $0.date.timeIntervalSince1970 }).min() {
            referenceTimeInterval = minTimeInterval
        }

        let xValuesNumberFormatter = ChartXAxisFormatter(
            referenceTimeInterval: referenceTimeInterval,
            dateFormatter: dateFormatter)
        
        // 設定體重data
        var dataEntries: [ChartDataEntry] = []
        guard let originYvalue = datas.first?.value,
            let lastYvalue = datas.last?.value
        else { return }
        
        dataEntries.append(ChartDataEntry(x: -20, y: originYvalue))
        for data in datas {
            let timeInterval = data.date.timeIntervalSince1970
            let xValue = (timeInterval - referenceTimeInterval) / (3600 * 24)
            let yValue = data.value
            let entry = ChartDataEntry(x: xValue, y: yValue)
            dataEntries.append(entry)
        }
        let nowXvalue = (Date().timeIntervalSince1970 - referenceTimeInterval) / (3600 * 24)
        dataEntries.append(ChartDataEntry(x: nowXvalue + 10, y: lastYvalue))
        
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        chartDataSet.colors = [UIColor.darkGray] // 線條顏色
        chartDataSet.circleColors = [UIColor.drYellow] // 外圓顏色
        chartDataSet.circleHoleColor = UIColor.white // 內圓顏色
        chartDataSet.circleRadius = 3 // 外圓半徑
        chartDataSet.circleHoleRadius = 0 // 內圓半徑
        chartDataSet.drawFilledEnabled = true // 開啟填充色繪製
        
        let gradientColors = [UIColor.drYellow.cgColor, UIColor.drLightYellow.cgColor] as CFArray // 漸變顏色組合
        let colorLocations: [CGFloat] = [0.5, 0.0] // 每組顏色所在位置（範圍0~1）
        guard let gradient = CGGradient.init(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors,
            locations: colorLocations) else { return } // 生成漸變色
        chartDataSet.fill = LinearGradientFill(
            gradient: gradient,
            angle: 90.0) // 將漸變色作為填充對象，角度為由上往下
        
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = false // 不顯示橫向十字線
        chartDataSet.drawVerticalHighlightIndicatorEnabled = false // 不顯示縱向十字線
        chartDataSet.drawValuesEnabled = false // 不顯示數字
        // chartDataSet.mode = .horizontalBezier // 改變折線弧度
        let chartData = LineChartData(dataSets: [chartDataSet])
        // 折線圖數據只包含一組數據
        self.data = chartData // 設置折線圖數據
        
        self.drawGridBackgroundEnabled = true // 要不要有背景
        self.drawBordersEnabled = false // 要不要有邊框
        self.legend.form = .none
        
        self.xAxis.labelPosition = .bottom // x軸顯示在下方，預設為上方
        self.xAxis.drawGridLinesEnabled = false // 不要有每個x值的線
        self.xAxis.drawLabelsEnabled = false // 不顯示x軸文字
        self.xAxis.valueFormatter = xValuesNumberFormatter
        self.xAxis.granularity = 30 // x軸的間隔
        self.xAxis.axisMinimum = -5
        self.xAxis.axisMaximum = nowXvalue + 5
        
        // 讓x軸下有線(ticks)
        // let customXAxisRenderer = XAxisRendererWithTicks(
        //     viewPortHandler: self.viewPortHandler,
        //     axis: self.xAxis,
        //    transformer: self.getTransformer(forAxis: .left))
        // self.xAxisRenderer = customXAxisRenderer
        
        self.rightAxis.enabled = false // 不使用右側y軸
        self.leftAxis.drawGridLinesEnabled = false // 不要有每個y值的線
        self.leftAxis.drawLabelsEnabled = false // 不顯示左側y軸文字
        self.leftAxis.drawAxisLineEnabled = false // 不顯示左側y軸線
        guard let maxWeight = datas.map({ $0.value }).max(),
            let minWeight = datas.map({ $0.value }).min()
        else { return }
        self.leftAxis.axisMinimum = minWeight - 20 // 最小刻度值
        self.leftAxis.axisMaximum = maxWeight + 20 // 最大刻度值
        
        // 設定目標線
        self.leftAxis.removeAllLimitLines()
        let limitLine = ChartLimitLine(limit: goal, label: "\(goal) kg") // 設置警戒線
        self.leftAxis.addLimitLine(limitLine)
        self.leftAxis.drawLimitLinesBehindDataEnabled = true // 警戒線在折線圖下
        limitLine.valueTextColor = UIColor.darkGray  // 文字颜色
        limitLine.valueFont = UIFont.systemFont(ofSize: 10)  // 文字大小
        limitLine.labelPosition = .rightTop // 文字在警戒線的右上
        limitLine.lineWidth = 1 // 線寬
        limitLine.lineColor = .red // 線條顏色
        limitLine.lineDashLengths = [4, 2] // 設定警戒線為虛線
        
        self.setVisibleXRangeMaximum(90) // 圖表最多顯示10個點
        self.moveViewToX(nowXvalue) // 默認顯示最後一個數據
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // 將選擇的點置中
        // self.moveViewToAnimated(xValue: entry.x - 45, yValue: 0, axis: .left, duration: 0.3)
        let date = Date(timeIntervalSince1970: entry.x * 3600 * 24 + self.referenceTimeInterval)
        let dateString = dateFormatter.string(from: date)
        self.showMarkerView(value: "\(entry.y)", date: dateString)
    }
    
    private func showMarkerView(value: String, date: String) {
        let marker = BalloonMarker(
            color: UIColor.drGray,
            font: .systemFont(ofSize: 12),
            textColor: .white,
            insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = self
        marker.minimumSize = CGSize(width: 80, height: 40)
        marker.setLabel("\(date)\n\(value) kg")
        self.marker = marker
    }
}
