import SwiftUI
import SwiftData
import FirebaseCore

@main
struct TimesTablesAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DifficultQuestion.self,
            UserPoints.self,
            PointHistory.self,
            PointSpending.self,
            AnswerTimeRecord.self // 回答時間記録モデルを追加
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
                        Label("九九ティブ", systemImage: "person.fill.questionmark")
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
