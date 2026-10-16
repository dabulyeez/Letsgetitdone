import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TasksView()
                .tabItem { Label("Tasks", systemImage: "checklist") }
            MoneyView()
                .tabItem { Label("Money", systemImage: "dollarsign.circle") }
            StocksView()
                .tabItem { Label("Stocks", systemImage: "chart.line.uptrend.xyaxis") }
            CounterView()
                .tabItem { Label("Counter", systemImage: "plus.circle") }
        }
    }
}

/// Small rounded label used for due dates and stop/target states.
struct Chip: View {
    enum Tone { case plain, good, warn, bad }
    let text: String
    var tone: Tone = .plain

    private var color: Color {
        switch tone {
        case .plain: return .secondary
        case .good: return .green
        case .warn: return .orange
        case .bad: return .red
        }
    }

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundColor(color)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}
