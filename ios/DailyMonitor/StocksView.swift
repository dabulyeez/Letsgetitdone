import SwiftUI

struct StocksView: View {
    @EnvironmentObject var store: Store
    @State private var adding = false
    @State private var editing: Position?

    private var total: Double? {
        let gains = store.positions.compactMap { $0.gain }
        return gains.isEmpty ? nil : gains.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            List {
                if store.positions.isEmpty {
                    Text("No positions yet. Tap + and add your holdings.").foregroundColor(.secondary)
                } else {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total gain / loss").font(.caption).foregroundColor(.secondary)
                                Text(total.map(money) ?? "-")
                                    .font(.title2.weight(.semibold)).monospacedDigit()
                                    .foregroundColor((total ?? 0) < 0 ? .red : .green)
                            }
                            Spacer()
                        }
                    }
                    Section {
                        ForEach(store.positions) { p in
                            Button { editing = p } label: { PositionRow(position: p) }
                                .buttonStyle(.plain)
                        }
                        .onDelete { store.positions.remove(atOffsets: $0) }
                    }
                    Section {
                        Text("Prices are typed in by you. This app does not trade and does not set stop orders: place those inside Webull or Robinhood.")
                            .font(.footnote).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Stocks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { adding = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add position")
                }
            }
            .sheet(isPresented: $adding) { PositionForm(position: nil) }
            .sheet(item: $editing) { PositionForm(position: $0) }
        }
    }
}

struct PositionRow: View {
    let position: Position

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(position.ticker).font(.headline)
                Spacer()
                if let g = position.gain {
                    Text(money(g)).monospacedDigit().foregroundColor(g < 0 ? .red : .green)
                }
            }
            HStack(spacing: 6) {
                Text("\(trim(position.shares)) sh @ \(money(position.buy))")
                if let p = position.lastPrice { Text("· last \(money(p))") }
            }
            .font(.footnote).foregroundColor(.secondary)

            HStack(spacing: 6) {
                if let stop = position.stop {
                    switch position.stopState {
                    case .hit: Chip(text: "stop hit \(money(stop))", tone: .bad)
                    case .near: Chip(text: "near stop \(money(stop))", tone: .warn)
                    default: Chip(text: "stop \(money(stop))", tone: .good)
                    }
                    if !position.stopOrderSet { Chip(text: "set stop order in app", tone: .warn) }
                }
                if let t = position.target {
                    Chip(text: (position.targetHit ? "target hit " : "target ") + money(t),
                         tone: position.targetHit ? .good : .plain)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

private func trim(_ v: Double) -> String {
    v == v.rounded() ? String(Int(v)) : String(v)
}

struct PositionForm: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let position: Position?

    @State private var ticker = ""
    @State private var shares = ""
    @State private var buy = ""
    @State private var stop = ""
    @State private var target = ""
    @State private var last = ""
    @State private var stopOrderSet = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Ticker, like AAPL", text: $ticker).textInputAutocapitalization(.characters).autocorrectionDisabled()
                    TextField("Shares", text: $shares).keyboardType(.decimalPad)
                    TextField("Price you paid per share", text: $buy).keyboardType(.decimalPad)
                }
                Section("Your lines (optional)") {
                    TextField("Stop price", text: $stop).keyboardType(.decimalPad)
                    TextField("Target price", text: $target).keyboardType(.decimalPad)
                    Toggle("Stop order is set in my brokerage app", isOn: $stopOrderSet)
                }
                Section("Latest price") {
                    TextField("Last price", text: $last).keyboardType(.decimalPad)
                }
            }
            .navigationTitle(position == nil ? "New position" : "Edit position")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                guard let p = position else { return }
                ticker = p.ticker; shares = trim(p.shares); buy = String(p.buy)
                stop = p.stop.map { String($0) } ?? ""; target = p.target.map { String($0) } ?? ""
                last = p.lastPrice.map { String($0) } ?? ""; stopOrderSet = p.stopOrderSet
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(ticker.trimmingCharacters(in: .whitespaces).isEmpty || Double(shares) == nil || Double(buy) == nil)
                }
            }
        }
    }

    private func save() {
        guard let s = Double(shares), let b = Double(buy) else { return }
        var p = position ?? Position(ticker: "", shares: s, buy: b)
        p.ticker = ticker.trimmingCharacters(in: .whitespaces).uppercased()
        p.shares = s; p.buy = b
        p.stop = Double(stop); p.target = Double(target); p.lastPrice = Double(last)
        p.stopOrderSet = stopOrderSet
        if let i = store.positions.firstIndex(where: { $0.id == p.id }) {
            store.positions[i] = p
        } else {
            store.positions.append(p)
        }
        dismiss()
    }
}
