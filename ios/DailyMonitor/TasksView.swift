import SwiftUI

struct TasksView: View {
    @EnvironmentObject var store: Store
    @State private var adding = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    RightNowCard()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                let openToday = store.open(.now)
                let openWeek = store.open(.week)

                if !openToday.isEmpty {
                    Section(TaskGroup.now.label) { rows(openToday) }
                }
                if !openWeek.isEmpty {
                    Section(TaskGroup.week.label) { rows(openWeek) }
                }
                if openToday.isEmpty && openWeek.isEmpty {
                    Section {
                        Text(store.tasks.isEmpty
                             ? "No tasks yet. Tap + to add your first one."
                             : "Everything on this list is done.")
                            .foregroundColor(.secondary)
                    }
                }
                if !store.done.isEmpty {
                    Section {
                        DisclosureGroup("Done (\(store.done.count))") { rows(store.done) }
                    }
                }
            }
            .navigationTitle("Daily Monitor")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { adding = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add task")
                }
            }
            .sheet(isPresented: $adding) { AddTaskView() }
        }
    }

    @ViewBuilder
    private func rows(_ items: [TaskItem]) -> some View {
        ForEach(items) { task in
            TaskRow(task: task)
        }
        .onDelete { offsets in
            let ids = offsets.map { items[$0].id }
            store.tasks.removeAll { ids.contains($0.id) }
        }
    }
}

struct RightNowCard: View {
    @EnvironmentObject var store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Right now").font(.subheadline).foregroundColor(.secondary)
            if let task = store.rightNow {
                Text(task.title).font(.title3.weight(.semibold))
                if !task.note.isEmpty { Text(task.note).font(.callout).foregroundColor(.secondary) }
                Button("Mark done") { store.toggle(task) }
                    .buttonStyle(.borderedProminent)
            } else {
                Text("Today's list is clear.").font(.title3.weight(.semibold))
                if let next = store.nextUp {
                    Text("Next up this week: \(next.title)").font(.callout).foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor, lineWidth: 2))
        .padding(.vertical, 4)
    }
}

struct TaskRow: View {
    @EnvironmentObject var store: Store
    let task: TaskItem
    @State private var expanded = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button { store.toggle(task) } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isDone ? "Reopen \(task.title)" : "Mark done: \(task.title)")

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .fontWeight(task.isDone ? .regular : .semibold)
                    .strikethrough(task.isDone)
                    .foregroundColor(task.isDone ? .secondary : .primary)
                if !task.note.isEmpty {
                    Text(task.note)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(expanded ? nil : 2)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { if !task.note.isEmpty { expanded.toggle() } }

            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 4) {
                if let due = task.due, !task.isDone {
                    let label = DueLabel.text(due)
                    Chip(text: label.text, tone: label.late ? .bad : .plain)
                }
                if task.status == .doing { Chip(text: "doing", tone: .warn) }
                if task.status == .blocked { Chip(text: "blocked", tone: .bad) }
            }
        }
        .padding(.vertical, 2)
    }
}

struct AddTaskView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var note = ""
    @State private var group: TaskGroup = .now
    @State private var hasDue = false
    @State private var due = Date()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task, like: Call PA UC about RESEA", text: $title)
                TextField("Note (optional)", text: $note, axis: .vertical)
                Picker("When", selection: $group) {
                    ForEach(TaskGroup.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
                Toggle("Due date", isOn: $hasDue)
                if hasDue { DatePicker("Due", selection: $due, displayedComponents: .date) }
            }
            .navigationTitle("New task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let t = title.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        store.tasks.append(TaskItem(title: t, note: note, group: group, due: hasDue ? due : nil))
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
