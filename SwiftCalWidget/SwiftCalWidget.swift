//
//  SwiftCalWidget.swift
//  SwiftCalWidget
//
//  Created by Josafat Vicente Pérez on 31/1/23.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    var dayFetchRequest: NSFetchRequest<Day> {
        let request = Day.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Day.date, ascending: true)]
        request.predicate = NSPredicate(format: " (date >= %@) AND (date <= %@)",
                                        Date().startOfCalendarWithPrefixDays as CVarArg,
                                        Date().endOfMonth as CVarArg)
        return request
    }
    
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), days: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        
        
        
        do {
            let days = try viewContext.fetch(dayFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days)
            completion(entry)
        } catch {
            print("Widget failed to fetch days in snapshot")
        }
        
        let entry = CalendarEntry(date: Date(), days: [])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let days = try viewContext.fetch(dayFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days)
            let timeline = Timeline(entries: [entry], policy: .after(.now.endOfDay))
            completion(timeline)
        } catch {
            print("Widget failed to fetch days in snapshot")
        }
        
        
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let days: [Day]
}

struct SwiftCalWidgetEntryView : View {
    
    @Environment (\.widgetFamily) var family
    var entry: CalendarEntry
    
    
    var body: some View {
        
        switch family{
        case .systemMedium:
            MediumCalendarView(entry: entry, streakValue: calculateStreakValue() )
        case .systemSmall, .systemLarge, .systemExtraLarge:
            EmptyView()
        case .accessoryCircular:
            LockScreenCircularCalendarView(entry: entry, streakValue: calculateStreakValue())
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
        case .accessoryInline:
            Label("Streak \(calculateStreakValue()) days", systemImage: "swift")
                .widgetURL(URL(string: "streak"))
        @unknown default:
            EmptyView()
        }
        
    }
    
    func calculateStreakValue() -> Int {
        guard !entry.days.isEmpty else { return 0 }
        let nonFutureDays = entry.days.filter { $0.date!.dayInt <= Date().dayInt }
        
        var streakCount = 0
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
            } else {
                if day.date!.dayInt != Date().dayInt {
                    break
                }
            }
        }
        return streakCount
    }
}

@main
struct SwiftCalWidget: Widget {
    let kind: String = "SwiftCalWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftCalWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Swift Study Calendar")
        .description("You your streaks studying Swift")
        .supportedFamilies([.systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

struct SwiftCalWidget_Previews: PreviewProvider {
    static var previews: some View {
        SwiftCalWidgetEntryView(entry: CalendarEntry(date: Date(), days: []))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

// MARK: UI Components for widget sizes

private struct MediumCalendarView: View {
    
    var entry: CalendarEntry
    var streakValue: Int
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body:  some View {
        
        HStack{
            Link(destination: URL(string: "streak")!) {
                VStack{
                    Text("\(streakValue)")
                        .font(.system(size: 70,design: .rounded))
                        .bold()
                        .foregroundColor(.orange)
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Link(destination: URL(string: "calendar")!) {
                VStack{
                    CalendarHeaderView(font: .caption)
                    
                    LazyVGrid(columns: columns, spacing: 7) {
                        ForEach(entry.days){ day in
                            if day.date!.monthInt != Date().monthInt {
                                Text("")
                            } else {
                                Text(day.date!.formatted(.dateTime.day()))
                                    .font(.caption2)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(day.didStudy ? .orange : .secondary)
                                    .background(
                                        Circle()
                                            .foregroundColor(.orange.opacity(day.didStudy ? 0.3 : 0.0))
                                            .scaleEffect(1.4)
                                    )
                            }
                        }
                    }
                }.padding(.leading, 6)
            }
        }.padding()
        
    }
}

private struct LockScreenCircularCalendarView: View {
    
    var entry: CalendarEntry
    var streakValue: Int
    
    var currentCalendarDays: Int {
        entry.days.filter { $0.date?.monthInt == Date().monthInt }.count
    }
    
    var daysStudied: Int {
        entry.days.filter { $0.date?.monthInt == Date().monthInt }.filter { $0.didStudy }.count
    }
    
    var body:  some View {
        Gauge(value: Double(daysStudied), in: 1...Double(currentCalendarDays)) {
            Image(systemName: "swift")
        } currentValueLabel: {
            Text("\(daysStudied)")
        }.gaugeStyle(.accessoryCircular)
        
    }
}

private struct LockScreenRectangularView: View {
    
    var entry: CalendarEntry
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body:  some View {
        
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(entry.days){ day in
                if day.date!.monthInt != Date().monthInt {
                    Text("")
                } else {
                    if day.didStudy {
                        Image(systemName: "swift")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 7, height: 7)
                    }
                    Text(day.date!.formatted(.dateTime.day()))
                        .font(.system(size: 7))
                        .frame(maxWidth: .infinity)
                        
                }
            }
        }.padding()
        
        
    }
}
