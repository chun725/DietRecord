//
//  DietPieChartWidget.swift
//  ChartViewWidgetExtension
//
//  Created by chun on 2022/11/17.
//

import WidgetKit
import SwiftUI

struct DietProvider: TimelineProvider {
    func placeholder(in context: Context) -> DietEntry {
        guard let imagePath = Bundle.main.url(forResource: "DietImage", withExtension: ".png"),
            let imageData = try? Data(contentsOf: imagePath)
        else { fatalError("Could not find diet image.") }
        return DietEntry(date: Date(), imageData: imageData)
    }

    func getSnapshot(in context: Context, completion: @escaping (DietEntry) -> Void) {
        guard let imagePath = Bundle.main.url(forResource: "DietImage", withExtension: ".png"),
            let imageData = try? Data(contentsOf: imagePath)
        else { fatalError("Could not find water image.") }
        let entry = DietEntry(date: Date(), imageData: imageData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var entries: [DietEntry] = []
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        let refreshDate = dateFormatter.date(from: currentDateString)?.advanced(by: 60 * 60 * 24)
        
        let waterReloadDate = userDefaults?.string(forKey: "DietDate")
        if currentDateString == waterReloadDate {
            guard let imageData = userDefaults?.value(forKey: "DietImage") as? Data,
                let data = try? decoder.decode(Data.self, from: imageData)
            else { fatalError("Could not find update image.") }
            let entry = DietEntry(date: currentDate, imageData: data)
            entries.append(entry)
        } else {
            guard let imagePath = Bundle.main.url(forResource: "DietImage", withExtension: ".png"),
                let imageData = try? Data(contentsOf: imagePath)
            else { fatalError("Could not find diet image.") }
            let entry = DietEntry(date: currentDate, imageData: imageData)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .after(refreshDate ?? Date()))
        completion(timeline)
    }
}

struct DietEntry: TimelineEntry {
    let date: Date
    let imageData: Data
}

struct DietPieChartWidgetEntryView: View {
    var entry: DietProvider.Entry

    var body: some View {
        HStack {
            Spacer()
            Image(uiImage: UIImage(data: entry.imageData)!).resizable().aspectRatio(contentMode: .fill).padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            Spacer()
        }.background(Color.white)
    }
}

struct DietPieChartWidget: Widget {
    let kind: String = "DietPieChartWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DietProvider()) { entry in
            DietPieChartWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("卡路里攝取")
        .description("當日卡路里攝取一目暸然")
        .supportedFamilies([.systemSmall])
    }
}

struct DietPieChartWidget_Previews: PreviewProvider {
    static var previews: some View {
        DietPieChartWidgetEntryView(entry: DietEntry(
            date: Date(),
            imageData: (UIImage(named: "DietImage")?.pngData())!))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
