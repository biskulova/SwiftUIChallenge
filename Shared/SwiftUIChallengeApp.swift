import SwiftUI

@main
struct SwiftUIChallengeApp: App {
    @StateObject var model = Model()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
