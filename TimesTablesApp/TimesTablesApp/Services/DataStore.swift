import SwiftUI
import SwiftData

/// アプリ全体のデータ管理を担当するシングルトンクラス
@MainActor
final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    let container: ModelContainer
    var context: ModelContext { container.mainContext }
    
    private init() {
        let schema = Schema([
            DifficultQuestion.self,
            UserPoints.self,
            PointHistory.self,
            PointSpending.self,
            AnswerTimeRecord.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
            ensureInitialData()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    /// アプリ起動時に必要な初期データを確実に作成
    private func ensureInitialData() {
        let pointsDescriptor = FetchDescriptor<UserPoints>()
        do {
            let existingPoints = try context.fetch(pointsDescriptor)
            if existingPoints.isEmpty {
                let initialPoints = UserPoints(totalEarnedPoints: 0, availablePoints: 0)
                context.insert(initialPoints)
                try context.save()
            }
        } catch {
            print("初期ポイントデータの作成に失敗: \(error)")
        }
    }
    
    /// データ保存を安全に実行
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("データ保存エラー: \(error)")
        }
    }
}

/// SwiftUIアプリでDataStoreを利用するためのEnvironmentKey
struct DataStoreKey: EnvironmentKey {
    @MainActor static let defaultValue = DataStore.shared
}

extension EnvironmentValues {
    var dataStore: DataStore {
        get { self[DataStoreKey.self] }
        set { self[DataStoreKey.self] = newValue }
    }
}