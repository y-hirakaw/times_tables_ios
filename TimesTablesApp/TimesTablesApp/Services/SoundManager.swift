import SwiftUI
import AVFoundation

/// アプリ全体のサウンド管理を担当するシングルトンクラス
@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var isEnabled = true
    
    private var players: [SoundType: AVAudioPlayer] = [:]
    
    enum SoundType: String, CaseIterable {
        case correct = "Quiz-Correct_Answer02-2"
        case wrong = "Quiz-Wrong_Buzzer02-3"
        
        var filename: String { rawValue }
        var fileExtension: String { "mp3" }
    }
    
    private init() {
        setupPlayers()
    }
    
    /// 音声プレイヤーを初期化
    private func setupPlayers() {
        for soundType in SoundType.allCases {
            guard let url = Bundle.main.url(
                forResource: soundType.filename,
                withExtension: soundType.fileExtension
            ) else {
                print("警告: 音声ファイルが見つかりません: \(soundType.filename)")
                continue
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[soundType] = player
            } catch {
                print("音声プレイヤー作成エラー (\(soundType)): \(error)")
            }
        }
    }
    
    /// 指定されたサウンドを再生
    func play(_ soundType: SoundType) {
        guard isEnabled else { return }
        players[soundType]?.play()
    }
    
    /// サウンドの有効/無効を切り替え
    func toggleSound() {
        isEnabled.toggle()
        
        // 効果音がONになった時のフィードバック音を再生
        if isEnabled {
            play(.correct)
        }
    }
}

/// SwiftUIでSoundManagerを利用するためのEnvironmentKey
struct SoundManagerKey: EnvironmentKey {
    @MainActor static let defaultValue = SoundManager.shared
}

extension EnvironmentValues {
    var soundManager: SoundManager {
        get { self[SoundManagerKey.self] }
        set { self[SoundManagerKey.self] = newValue }
    }
}