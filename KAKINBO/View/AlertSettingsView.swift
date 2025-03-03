//
//  AlertSettingsView.swift
//  KAKINBO
//
//  Created by Apple on 2025/03/03.
//

import SwiftUI

struct AlertSettingsView: View {
    // アラートレベルの設定値
    @Binding var alertLevel1: Int
    @Binding var alertLevel2: Int
    @Binding var alertLevel3: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Alert level set")
                .font(.title)
                .padding(.top)
            
            Text("mode 2")
                .font(.headline)
            
            // レベル1の設定
            VStack(alignment: .leading) {
                Text("Alert message level 1")
                    .font(.headline)
                
                TextField("", value: $alertLevel1, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(4)
            }
            
            // レベル2の設定
            VStack(alignment: .leading) {
                Text("Alert message level 2")
                    .font(.headline)
                
                TextField("", value: $alertLevel2, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(4)
            }
            
            // レベル3の設定
            VStack(alignment: .leading) {
                Text("Alert message level 3")
                    .font(.headline)
                
                TextField("", value: $alertLevel3, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.pink.opacity(0.5))
                    .cornerRadius(4)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Alert Settings", displayMode: .inline)
    }
}

struct AlertSettingsView_Previews: PreviewProvider {
    @State static var level1 = 15000
    @State static var level2 = 50000
    @State static var level3 = 100000
    
    static var previews: some View {
        NavigationView {
            AlertSettingsView(
                alertLevel1: $level1,
                alertLevel2: $level2,
                alertLevel3: $level3
            )
        }
    }
}
