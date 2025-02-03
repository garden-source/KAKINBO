//
//  EditPresetSheet.swift
//  KAKINBO
//
//  Created by Apple on 2025/02/03.
//

import SwiftUI

struct EditPresetSheet: View {
    @Binding var editedValue: String
    var onCancel: () -> Void
    var onSave: () -> Void

    // 入力欄にフォーカスを当てるためのプロパティ
    @FocusState private var isFocused: Bool

    // 入力が有効かどうか（数字のみ、2～6桁、"0"は特別扱い）
    private var isValid: Bool {
        let trimmed = editedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        // "0" は有効（nil と同等の扱い）
        if trimmed == "0" { return true }
        guard let _ = Int(trimmed) else { return false }
        return (2...6).contains(trimmed.count)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                TextField("数字のみ（2～6桁）", text: $editedValue)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    // テキストフィールドにフォーカスを付与
                    .focused($isFocused)
                    .onAppear {
                        // 少し遅延させてフォーカスを当てる
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.isFocused = true
                        }
                    }
                
                // キャンセル／保存ボタンを大きめに配置
                HStack(spacing: 40) {
                    Button(action: {
                        onCancel()
                    }) {
                        Text("キャンセル")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        onSave()
                    }) {
                        Text("保存")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .disabled(!isValid)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("ボタンの数値の変更")
        }
    }
}

struct EditPresetSheet_Previews: PreviewProvider {
    @State static var value: String = "1500"
    static var previews: some View {
        EditPresetSheet(editedValue: $value, onCancel: {}, onSave: {})
    }
}
