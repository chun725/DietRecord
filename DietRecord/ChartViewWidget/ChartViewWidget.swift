//
//  ChartViewWidget.swift
//  ChartViewWidget
//
//  Created by chun on 2022/11/17.
//

import WidgetKit
import SwiftUI

struct WidgetConstant {
    static let dateFormatter = DateFormatter()
    static let decoder = JSONDecoder()
    static let userDefaults = UserDefaults(suiteName: "group.chun.DietRecord")
    static let waterImage = "WaterImage"
    static let dietImage = "DietImage"
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        guard let imagePath = Bundle.main.url(forResource: WidgetConstant.waterImage, withExtension: ".png"),
            let imageData = try? Data(contentsOf: imagePath)
        else { fatalError("Could not find water image.") }
        return SimpleEntry(date: Date(), imageData: imageData)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        guard let imagePath = Bundle.main.url(forResource: WidgetConstant.waterImage, withExtension: ".png"),
            let imageData = try? Data(contentsOf: imagePath)
        else { fatalError("Could not find water image.") }
        let entry = SimpleEntry(date: Date(), imageData: imageData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        WidgetConstant.dateFormatter.locale = .current
        WidgetConstant.dateFormatter.dateFormat = "yyyy-MM-dd"
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let currentDateString = WidgetConstant.dateFormatter.string(from: currentDate)
        let refreshDate = WidgetConstant.dateFormatter.date(from: currentDateString)?.advanced(by: 60 * 60 * 24)
        
        let waterReloadDate = WidgetConstant.userDefaults?.string(forKey: "WaterDate")
        if currentDateString == waterReloadDate {
            guard let imageData = WidgetConstant.userDefaults?.value(forKey: WidgetConstant.waterImage) as? Data,
                  let data = try? WidgetConstant.decoder.decode(Data.self, from: imageData)
            else { fatalError("Could not find update image.") }
            let entry = SimpleEntry(date: currentDate, imageData: data)
            entries.append(entry)
        } else {
            guard let imagePath = Bundle.main.url(forResource: WidgetConstant.waterImage, withExtension: ".png"),
                let imageData = try? Data(contentsOf: imagePath)
            else { fatalError("Could not find water image.") }
            let entry = SimpleEntry(date: currentDate, imageData: imageData)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .after(refreshDate ?? Date()))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imageData: Data
}

struct ChartViewWidgetEntryView: View {
    var entry: Provider.Entry
    
    private static let deeplinkURL = URL(string: "Water-Widget://")!

    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: UIImage(data: entry.imageData)!).resizable().aspectRatio(contentMode: .fill)
            Spacer()
        }.background(Color("WidgetBackground")).widgetURL(ChartViewWidgetEntryView.deeplinkURL)
    }
}

struct ChartViewWidget: Widget {
    let kind: String = "ChartViewWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ChartViewWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WidgetBackground"))
        }
        .configurationDisplayName("飲水量攝取")
        .description("當日飲水量攝取一目暸然")
        .supportedFamilies([.systemSmall])
    }
}

struct ChartViewWidget_Previews: PreviewProvider {
    static var previews: some View {
        ChartViewWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            imageData: (UIImage(named: WidgetConstant.waterImage)?.pngData())!))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


@main
struct SwiftWidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ChartViewWidget()
        DietPieChartWidget()
    }
}
