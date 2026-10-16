import SwiftUI

/// A simple tap counter. The button's spoken label matches its visible text so Voice Control users can say "Tap me".
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(count)")
                .font(.largeTitle)
                .accessibilityIdentifier("countLabel")

            Button(action: { count += 1 }) {
                Text("Tap me")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Increases the count by one")
        }
        .padding()
    }
}
