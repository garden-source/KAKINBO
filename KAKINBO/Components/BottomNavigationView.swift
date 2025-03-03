//
//  BottomNavigationView.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import SwiftUI

struct BottomNavigationView: View {
    // 選択されているタブを追跡
    @Binding var selectedTab: Int
    
    // 現在のモード（1または2）
    @Binding var currentMode: Int
    
    var body: some View {
        HStack {
            // 左：MODEボタン
            Button(action: {
                // モードを切り替え (1 <-> 2)
                currentMode = currentMode == 1 ? 2 : 1
            }) {
                Text("MODE\(currentMode)")
                    .padding()
                    .frame(minWidth: 100)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // 中央：HOMEボタン
            Button(action: {
                selectedTab = 0
            }) {
                Text("HOME")
                    .padding()
                    .frame(minWidth: 100)
                    .background(selectedTab == 0 ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Spacer()
            
            // 右：CALENDARボタン
            Button(action: {
                selectedTab = 1
            }) {
                Text("CALENDAR")
                    .padding()
                    .frame(minWidth: 100)
                    .background(selectedTab == 1 ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

struct BottomNavigationView_Previews: PreviewProvider {
    @State static var selectedTab = 0
    @State static var currentMode = 1
    
    static var previews: some View {
        BottomNavigationView(selectedTab: $selectedTab, currentMode: $currentMode)
    }
}
