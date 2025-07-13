import SwiftUI
import SwiftData
import FirebaseCore

@main
struct TimesTablesAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MultiplicationView()
                    .tabItem {
                        Label("九九ティブ", systemImage: "person.fill.questionmark")
                    }
                
                StatsView()
                    .tabItem {
                        Label("学習統計", systemImage: "chart.pie.fill")
                    }
            }
            .modelContainer(DataStore.shared.container)
            .environment(\.dataStore, DataStore.shared)
            .environment(\.soundManager, SoundManager.shared)
        }
    }
}
