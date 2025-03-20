import Foundation

// PINコードの管理クラス
class PINManager {
    private static let pinKey = "parentDashboardPIN"
    private static let service = "com.timestables.app.parentPin"
    
    // KeyChainへのアクセス関数
    private static func saveToKeychain(pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: pinKey,
            kSecValueData: data,
            kSecAttrSynchronizable: kCFBooleanFalse,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly // アプリ削除時に消えるように設定
        ]
        
        // 既存のデータを削除
        SecItemDelete(query as CFDictionary)
        
        // 新しいデータを保存
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private static func loadFromKeychain() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: pinKey,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecAttrSynchronizable: kCFBooleanFalse
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data, let pin = String(data: data, encoding: .utf8) {
            return pin
        }
        return nil
    }
    
    // PINが設定されているかチェック
    static func isPINSet() -> Bool {
        return loadFromKeychain() != nil
    }
    
    // PINを設定
    static func setPin(_ pin: String) -> Bool {
        guard pin.count == 4, pin.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        return saveToKeychain(pin: pin)
    }
    
    // PINを検証
    static func verifyPin(_ pin: String) -> Bool {
        guard let savedPin = loadFromKeychain() else {
            return false
        }
        
        return savedPin == pin
    }
    
    // PINをリセット（デバッグ用）
    static func resetPin() {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: pinKey,
            kSecAttrSynchronizable: kCFBooleanFalse
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}