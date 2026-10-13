import SwiftUI

struct MoneyView: View {
    @EnvironmentObject var store: Store
    @State private var adding = false

    private var sorted: [MoneyItem] {
        store.money.sorted { a, b in
            if a.done != b.done { return !a.done }
            if a.risk != b.risk { return a.risk }
            return (a.due ?? .distantFuture) < (b.due ?? .distantFuture)
        }
    }

    private var openTotal: Double {
        store.money.filter { !$0.done }.compactMap { $0.amount }.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            List {
                if store.money.isEmpty {
                    Text("No bills or alerts yet. Tap + to add one.").foregroundColor(.secondary)
                } else {
                    Section(openTotal > 0 ? "\(money(openTotal)) open" : "") {
                        ForEach(sorted) { item in
                            HStack(alignment: .top, spacing: 12) {
                                Button { store.toggle(item) } label: {
                                    Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundColor(item.done ? .green : (item.risk ? .red : .secondary))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(item.done ? "Reopen \(item.title)" : "Mark paid: \(item.title)")

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.title)
                                        .fontWeight(.semibold)
                                        .strikethrough(item.done)
                                        .foregroundColor(item.done ? .secondary : (item.risk ? .red : .primary))
                                    if let due = item.due {
                                        Text("due " + DueLabel.text(due, done: item.done).text)
                                            .font(.footnote).foregroundColor(.secondary)
                                    }
                                    if !item.note.isEmpty {
                                        Text(item.note).font(.footnote).foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                if let amount = item.amount {
                                    Text(money(amount)).monospacedDigit()
                                }
                            }
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { sorted[$0].id }
                            store.money.removeAll { ids.contains($0.id) }
                        }
                    }
                }
            }
            .navigationTitle("Money")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { adding = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add bill")
                }
            }
            .sheet(isPresented: $adding) { AddMoneyView() }
        }
    }
}

struct AddMoneyView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var amount = ""
    @State private var hasDue = true
    @State private var due = Date()
    @State private var risk = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Bill or alert", text: $title)
                TextField("Amount (optional)", text: $amount).keyboardType(.decimalPad)
                Toggle("Due date", isOn: $hasDue)
                if hasDue { DatePicker("Due", selection: $due, displayedComponents: .date) }
                Toggle("Needs attention first", isOn: $risk)
            }
            .navigationTitle("New bill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let t = title.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        store.money.append(MoneyItem(title: t, amount: Double(amount), due: hasDue ? due : nil, risk: risk))
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
