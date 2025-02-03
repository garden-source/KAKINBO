//
//  BottomNavigationView.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import SwiftUI

struct BottomNavigationView: View {
    var onCalendar: () -> Void = {}
    var onLevel3: () -> Void = {}
    var onMode2: () -> Void = {}

    var body: some View {
        HStack {
            Button("CALENDAR", action: onCalendar)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            
            Spacer()
            
            Button("LEVEL3", action: onLevel3)
                .padding()
                .background(Color.gray)
                .foregroundColor(.black)
                .cornerRadius(8)
            
            Spacer()
            
            Button("To Mode2", action: onMode2)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

struct BottomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavigationView()
    }
}
