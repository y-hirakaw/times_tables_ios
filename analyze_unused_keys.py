#!/usr/bin/env python3
import json

# 使用されているキーを読み込み
with open('used_keys.txt', 'r', encoding='utf-8') as f:
    used_keys = set(line.strip() for line in f if line.strip())

print('=== UI.xcstrings 未使用キーの詳細調査 ===\n')

# 機能別にキーを分類
categories = {
    'PIN関連': ['PIN', 'pin'],
    'ポイント・履歴関連': ['ポイント', '履歴', '消費', '獲得'],
    'メッセージ・コミュニケーション関連': ['メッセージ', 'ほごしゃ', 'おしらせ'],
    '設定・管理関連': ['設定', '管理', '実行', '確認'],
    'データ・統計関連': ['データ', 'グラフ', '統計'],
    'その他': []
}

with open('TimesTablesApp/UI.xcstrings', 'r', encoding='utf-8') as f:
    ui_data = json.load(f)
    ui_keys = set(ui_data.get('strings', {}).keys())

unused_ui_keys = ui_keys - used_keys

# カテゴリ別に分類
categorized = {cat: [] for cat in categories}

for key in sorted(unused_ui_keys):
    key_data = ui_data['strings'].get(key, {})
    localizations = key_data.get('localizations', {})
    has_english = 'en' in localizations
    
    if has_english:
        en_value = localizations['en']['stringUnit']['value']
        
        categorized_flag = False
        for category, keywords in categories.items():
            if category != 'その他' and any(keyword in key for keyword in keywords):
                categorized[category].append((key, en_value))
                categorized_flag = True
                break
        
        if not categorized_flag:
            categorized['その他'].append((key, en_value))

# 結果表示
for category, items in categorized.items():
    if items:
        print(f'【{category}】 ({len(items)}個)')
        for key, en_value in items[:10]:  # 最大10個まで表示
            print(f'  {key} → {en_value}')
        if len(items) > 10:
            print(f'  ... 他 {len(items) - 10} 個')
        print()

print(f'\n=== 要約 ===')
print(f'UI.xcstrings 総キー数: {len(ui_keys)}')
print(f'使用済みキー数: {len(used_keys & ui_keys)}')
print(f'未使用キー数: {len(unused_ui_keys)}')
print(f'未使用率: {len(unused_ui_keys)/len(ui_keys)*100:.1f}%')