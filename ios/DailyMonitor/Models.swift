import Foundation

enum TaskGroup: String, Codable, CaseIterable, Identifiable {
    case now, week
    var id: String { rawValue }
    var label: String { self == .now ? "Today" : "This week" }
}

enum TaskStatus: String, Codable {
    case todo, doing, done, blocked
}

struct TaskItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var note: String = ""
    var group: TaskGroup = .now
    var status: TaskStatus = .todo
    var due: Date? = nil

    var isDone: Bool { status == .done }
}

struct MoneyItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var amount: Double? = nil
    var due: Date? = nil
    var risk: Bool = false
    var done: Bool = false
    var note: String = ""
}

struct Position: Identifiable, Codable, Equatable {
    var id = UUID()
    var ticker: String
    var shares: Double
    var buy: Double
    var stop: Double? = nil
    var target: Double? = nil
    var lastPrice: Double? = nil
    var stopOrderSet: Bool = false

    var gain: Double? {
        guard let p = lastPrice else { return nil }
        return (p - buy) * shares
    }

    enum StopState { case none, ok, near, hit }

    /// "near" means within 5% above the stop, the same rule the web board and the stock guard use.
    var stopState: StopState {
        guard let stop = stop, let p = lastPrice, p > 0 else { return .none }
        if p <= stop { return .hit }
        return (p - stop) / p < 0.05 ? .near : .ok
    }

    var targetHit: Bool {
        guard let t = target, let p = lastPrice else { return false }
        return p >= t
    }
}
