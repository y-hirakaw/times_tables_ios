import Foundation

/// ゲーム全体の設定値を管理する構造体
struct GameConstants {
    
    // MARK: - Timer Settings
    struct Timer {
        /// 問題の制限時間（秒）
        static let questionTimeLimit: Double = 10.0
        /// タイマーの更新間隔（秒）
        static let updateInterval: Double = 0.1
    }
    
    // MARK: - Answer Choices Settings
    struct AnswerChoices {
        /// 選択肢の固定数
        static let fixedChoices = 9
        /// 正解に近い値の範囲
        static let nearbyRange = -10...10
        /// ランダム値の範囲
        static let randomRange = 1...100
    }
    
    // MARK: - Difficulty Settings
    struct Difficulty {
        /// 苦手問題と判定される最小試行回数
        static let minAttemptsForDifficulty = 3
        /// 苦手問題と判定される不正解率の閾値（%）
        static let difficultyThresholdPercentage = 30.0
        /// 一問あたりの最大ボーナスポイント
        static let maxBonusPerQuestion = 10
        /// ボーナス計算の倍率
        static let bonusMultiplier = 0.5
    }
    
    // MARK: - Points Settings
    struct Points {
        /// 基本ポイント
        static let basePoints = 1
        /// ボーナスポイント計算式
        static func calculateBonus(from basePoints: Int) -> Int {
            Int(Double(basePoints) * Difficulty.bonusMultiplier) + 1
        }
        /// 苦手問題克服時のボーナス
        static let difficultyOvercomeBonus = 5
    }
    
    // MARK: - Animation Settings
    struct Animation {
        /// 正解時の結果表示時間（秒）
        static let correctAnswerDisplayDuration: TimeInterval = 1.5
        /// 不正解時の結果表示時間（秒）
        static let incorrectAnswerDisplayDuration: TimeInterval = 2.0
        /// フィードバックアニメーション時間（秒）
        static let feedbackAnimationDuration: TimeInterval = 0.8
    }
    
    // MARK: - Sequential Mode Settings
    struct Sequential {
        /// 段ごとモードの問題数
        static let questionsPerTable = 9
        /// 段ごとモードで進む最大段数
        static let maxTable = 9
        /// 段ごとモードで開始する段数
        static let minTable = 1
    }
    
    // MARK: - UI Settings
    struct UI {
        /// 回答ボタンのサイズ
        static let answerButtonSize: CGFloat = 80
        /// 問題カードの最大幅
        static let questionCardMaxWidth: CGFloat = .infinity
        /// タイマーバーの高さ
        static let timerBarHeight: CGFloat = 8
    }
}

/// ゲーム設定の列挙型
enum GameMode {
    case random
    case sequential(table: Int)
    case tableSpecific(table: Int)
    case holePunch
    
    var description: String {
        switch self {
        case .random:
            return "ランダム"
        case .sequential(let table):
            return "\(table)の段（順番）"
        case .tableSpecific(let table):
            return "\(table)の段"
        case .holePunch:
            return "虫食い"
        }
    }
}