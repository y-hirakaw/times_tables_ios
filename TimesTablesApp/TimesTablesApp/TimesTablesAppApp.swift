import SwiftUI
import SwiftData

@main
struct TimesTablesAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DifficultQuestion.self,
            UserPoints.self,
            PointHistory.self,
            PointSpending.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                MultiplicationView()
                    .tabItem {
                        Label("九九チャレンジ", systemImage: "person.fill.questionmark")
                    }
                
                StatsView()
                    .tabItem {
                        Label("学習統計", systemImage: "chart.pie.fill")
                    }
            }
            .modelContainer(sharedModelContainer)
        }
    }
}
