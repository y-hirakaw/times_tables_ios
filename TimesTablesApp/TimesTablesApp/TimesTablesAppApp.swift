import SwiftUI
import SwiftData

@main
struct TimesTablesAppApp: App {
    // 明示的にModelContainerを作成し、適切に設定する
    let modelContainer: ModelContainer
    
    init() {
        do {
            // 明示的なModelContainerの設定
            let schema = Schema([DifficultQuestion.self, UserPoints.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false, // 永続化するためfalseに設定
                allowsSave: true             // 保存を許可
            )
            
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("SwiftData ModelContainer初期化完了")
        } catch {
            fatalError("SwiftData ModelContainerの初期化に失敗: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer) // 明示的に作成したcontainerを使用
    }
}
