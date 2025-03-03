//
//  TodayView.swift
//  KAKINBO
//
//  Created by Apple on 2025/01/31.
//

import SwiftUI

struct TodayView: View {
    // 値を入れないのであれば自動でイニシャライザ
    let todaySum: Int
    var onPrevious: () -> Void = {}
    var onNext: () -> Void = {}

    var body: some View {
        ZStack {
            Color.green
                .ignoresSafeArea(edges: .horizontal)
            VStack {
                // TODAYを左に配置
                HStack {
                    Text("TODAY")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // 金額は中央に表示
                Text("¥\(todaySum)")
                    .font(.title)
                    .padding(.top, 4)
                
                // 最下段に三角形ボタンとYENを配置
                HStack {
                    // 三角形ボタンを左側に配置
                    HStack(spacing: 12) {
                        // 左向き三角（戻る）
                        Button(action: onPrevious) {
                            TriangleButton(direction: .left)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                        
                        // 右向き三角（進む）
                        Button(action: onNext) {
                            TriangleButton(direction: .right)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                    }
                    
                    Spacer()
                    
                    // YENを右側に
                    Text("YEN")
                        .font(.subheadline)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .foregroundColor(.black)
        }
        .frame(height: 100)
    }
}

// 三角形のボタン形状
struct TriangleButton: View {
    enum Direction {
        case left, right
    }
    
    var direction: Direction
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
            
            if direction == .left {
                Triangle()
                    .fill(Color.black)
                    .frame(width: 10, height: 10)
                    .rotationEffect(.degrees(270))
                    .offset(x: -1)
            } else {
                Triangle()
                    .fill(Color.black)
                    .frame(width: 10, height: 10)
                    .rotationEffect(.degrees(90))
                    .offset(x: 1)
            }
        }
    }
}

// 三角形の形状
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(todaySum: 7890)
    }
}
