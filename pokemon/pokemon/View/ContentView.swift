import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Pokemon")
            .onAppear {
                onAppear()
            }
    }

    private func onAppear() {
    }
}

#Preview {
    ContentView()
}
