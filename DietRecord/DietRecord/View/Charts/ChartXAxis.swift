//
//  ChartXAxis.swift
//  DietRecord
//
//  Created by chun on 2022/11/2.
//

import Charts

class ChartXAxisFormatter: NSObject {
    private var dateFormatter: DateFormatter?
    private var referenceTimeInterval: TimeInterval?

    convenience init(referenceTimeInterval: TimeInterval, dateFormatter: DateFormatter) {
        self.init()
        self.referenceTimeInterval = referenceTimeInterval
        self.dateFormatter = dateFormatter
    }
}

extension ChartXAxisFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter,
        let referenceTimeInterval = referenceTimeInterval
        else { return "" }

        let date = Date(timeIntervalSince1970: value * 3600 * 24 + referenceTimeInterval)
        return dateFormatter.string(from: date)
    }
}

class XAxisRendererWithTicks: XAxisRenderer {
    override func drawLabel(context: CGContext, formattedLabel: String, x: CGFloat, y: CGFloat, attributes: [NSAttributedString.Key: Any], constrainedTo constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat) {
        super.drawLabel(
            context: context,
            formattedLabel: formattedLabel,
            x: x,
            y: y,
            attributes: attributes,
            constrainedTo: constrainedToSize,
            anchor: anchor,
            angleRadians: angleRadians)
        context.beginPath()
        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: x, y: self.viewPortHandler.contentBottom))
        context.strokePath()
    }
}
