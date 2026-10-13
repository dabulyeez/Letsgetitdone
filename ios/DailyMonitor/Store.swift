import Foundation
import SwiftUI

/// Everything lives on the phone, in one JSON file in the app's Documents folder.
final class Store: ObservableObject {
    @Published var tasks: [TaskItem] = [] { didSet { save() } }
    @Published var money: [MoneyItem] = [] { didSet { save() } }
    @Published var positions: [Position] = [] { didSet { save() } }

    private struct Snapshot: Codable {
        var tasks: [TaskItem]
        var money: [MoneyItem]
        var positions: [Position]
    }

    private let url: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("daily-monitor.json")
    }()
    private var loading = true

    init() {
        if let data = try? Data(contentsOf: url),
           let snap = try? JSONDecoder().decode(Snapshot.self, from: data) {
            tasks = snap.tasks
            money = snap.money
            positions = snap.positions
        }
        loading = false
    }

    private func save() {
        guard !loading else { return }
        let snap = Snapshot(tasks: tasks, money: money, positions: positions)
        if let data = try? JSONEncoder().encode(snap) {
            try? data.write(to: url, options: .atomic)
        }
    }

    // MARK: Tasks

    /// Open tasks in a group: soonest due first, undated last.
    func open(_ group: TaskGroup) -> [TaskItem] {
        tasks.filter { $0.group == group && !$0.isDone }.sorted { a, b in
            (a.due ?? .distantFuture) < (b.due ?? .distantFuture)
        }
    }

    var done: [TaskItem] { tasks.filter { $0.isDone } }

    /// "Right now": top open Today task, else an overdue This-week task.
    var rightNow: TaskItem? {
        if let t = open(.now).first { return t }
        let today = Calendar.current.startOfDay(for: Date())
        return open(.week).first { ($0.due ?? .distantFuture) <= today }
    }

    var nextUp: TaskItem? { open(.week).first }

    func toggle(_ task: TaskItem) {
        guard let i = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[i].status = tasks[i].isDone ? .todo : .done
    }

    func toggle(_ item: MoneyItem) {
        guard let i = money.firstIndex(where: { $0.id == item.id }) else { return }
        money[i].done.toggle()
    }
}

// MARK: - Dates

enum DueLabel {
    /// Today, Tomorrow, a weekday within 6 days, otherwise "Oct 26". Past due gives "Late".
    static func text(_ due: Date, done: Bool = false) -> (text: String, late: Bool) {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: cal.startOfDay(for: due)).day ?? 0
        if days < 0 && !done { return ("Late", true) }
        if days == 0 { return ("Today", false) }
        if days == 1 { return ("Tomorrow", false) }
        let f = DateFormatter()
        f.dateFormat = days < 7 ? "EEE" : "MMM d"
        return (f.string(from: due), false)
    }
}

func money(_ v: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    return f.string(from: NSNumber(value: v)) ?? "$\(v)"
}
