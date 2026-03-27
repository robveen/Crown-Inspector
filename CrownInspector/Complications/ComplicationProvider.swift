import WidgetKit
import SwiftUI

/// watchOS complications showing game status at a glance
struct CrownInspectorComplication: Widget {
    let kind: String = "CrownInspectorComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplicationTimelineProvider()) { entry in
            ComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("Crown Inspector")
        .description("Your rank and stats at a glance.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner,
        ])
    }
}

// MARK: - Timeline

struct ComplicationEntry: TimelineEntry {
    let date: Date
    let money: Int
    let prestige: Int
    let rank: String
}

struct ComplicationTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComplicationEntry {
        ComplicationEntry(date: .now, money: 100, prestige: 0, rank: "Theme Park")
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
        let state = GameState.load()
        completion(ComplicationEntry(
            date: .now,
            money: state.economy.money,
            prestige: state.economy.prestige,
            rank: state.currentTier.displayName
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
        let state = GameState.load()
        let entry = ComplicationEntry(
            date: .now,
            money: state.economy.money,
            prestige: state.economy.prestige,
            rank: state.currentTier.displayName
        )
        let timeline = Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600)))
        completion(timeline)
    }
}

// MARK: - Views

struct ComplicationEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: ComplicationEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 1) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12))
                    Text("\(entry.prestige)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
            }

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10))
                    Text(entry.rank)
                        .font(.system(size: 11, weight: .semibold))
                }
                HStack(spacing: 8) {
                    Label("\(entry.money)", systemImage: "dollarsign.circle")
                    Label("\(entry.prestige)", systemImage: "star.fill")
                }
                .font(.system(size: 10))
            }

        case .accessoryInline:
            Label("\(entry.rank) - \(entry.money)$", systemImage: "crown.fill")

        case .accessoryCorner:
            Image(systemName: "crown.fill")
                .font(.system(size: 20))
                .widgetLabel {
                    Text("\(entry.prestige) prestige")
                }

        default:
            Text(entry.rank)
        }
    }
}
