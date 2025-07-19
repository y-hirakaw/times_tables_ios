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
                        Label(NSLocalizedString("九九ティブ", comment: "Times Tables"), systemImage: "person.fill.questionmark")
                    }
                
                StatsView()
                    .tabItem {
                        Label(NSLocalizedString("学習統計", comment: "Learning Statistics"), systemImage: "chart.pie.fill")
                    }
            }
            .modelContainer(DataStore.shared.container)
            .environment(\.dataStore, DataStore.shared)
            .environment(\.soundManager, SoundManager.shared)
        }
    }
}
