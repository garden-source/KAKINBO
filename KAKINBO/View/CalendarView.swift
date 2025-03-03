// KAKINBO/View/CalendarView.swift
import SwiftUI
import SwiftData

struct CalendarView: View {
    @ObservedObject var viewModel: KAKINBOViewModel
    @State private var selectedMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var editAmount: String = ""
    
    // 編集モードフラグ
    @State private var isEditing: Bool = false
    
    // 曜日の配列
    private let weekdays = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ヘッダー部分（月切り替え）- 小さくする
                HStack {
                    Button(action: {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                        viewModel.loadItemsForMonth(selectedMonth)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)  // サイズを小さく
                            .padding(.horizontal, 8)  // 横の余白を小さく
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: selectedMonth))
                        .font(.title2)  // サイズを小さく
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                        viewModel.loadItemsForMonth(selectedMonth)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title3)  // サイズを小さく
                            .padding(.horizontal, 8)  // 横の余白を小さく
                    }
                }
                .padding(.vertical, 4)  // 上下の余白を小さく
                
                // 月間合計表示 - 高さを小さく
                VStack(alignment: .leading) {
                    Text("Monthly total")
                        .font(.headline)
                    
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 48)  // 高さを小さく
                        
                        Text("\(viewModel.monthlyTotal)")
                            .font(.system(size: 30, weight: .bold))  // フォントサイズを小さく
                            .padding(.horizontal)
                    }
                    
                    Text("YEN")
                        .font(.subheadline)  // フォントサイズを指定
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 2)  // トップの余白を小さく
                }
                .padding(.horizontal)
                .padding(.vertical, 4)  // 上下の余白を小さく
                
                // 月間合計表示 - 共通コンポーネントを使用
                MonthlyTotalView(monthlyTotal: viewModel.monthlyTotal)
                    .frame(height: 80)  // 高さを小さく調整
                    .padding(.vertical, 4)  // 上下の余白を小さく
                
                // カレンダー表示 - 全体的に小さく
                VStack(spacing: 0) {
                    // 曜日ヘッダー
                    HStack(spacing: 0) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption)  // フォントサイズを小さく
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)  // 縦の余白を小さく
                                .background(Color.gray.opacity(0.2))
                                .border(Color.black, width: 0.5)
                        }
                    }
                    
                    // 日付グリッド
                    let daysInMonth = getDaysInMonth()
                    let firstWeekday = getFirstWeekday()
                    
                    ForEach(0..<6) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<7) { column in
                                let day = column + 1 + (row * 7) - firstWeekday
                                
                                if day > 0 && day <= daysInMonth {
                                    let date = getDate(day: day)
                                    let daySum = viewModel.getDaySum(for: date)
                                    
                                    Button(action: {
                                        selectedDate = date
                                        editAmount = daySum > 0 ? "\(daySum)" : ""
                                        isEditing = true
                                    }) {
                                        VStack(spacing: 0) {  // 内部の余白をなくす
                                            Text("\(day)")
                                                .font(.caption2)  // フォントサイズを小さく
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.top, 2)
                                                .padding(.leading, 2)  // 左余白を小さく
                                            
                                            if daySum > 0 {
                                                Text("\(daySum)")
                                                    .font(.caption2)  // フォントサイズを小さく
                                                    .frame(maxWidth: .infinity)
                                            }
                                            
                                            Spacer()
                                        }
                                        .frame(height: 35)  // セルの高さを小さく
                                        .border(Color.black, width: 0.5)
                                    }
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 35)  // セルの高さを小さく
                                        .border(Color.black, width: 0.5)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isEditing) {
                editDaySheet
            }
            .onAppear {
                viewModel.loadItemsForMonth(selectedMonth)
            }
        }
    }
    
    // 金額編集用シート
    private var editDaySheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                if let date = selectedDate {
                    Text(dayDateString(from: date))
                        .font(.headline)
                }
                
                TextField("Amount", text: $editAmount)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                HStack(spacing: 40) {
                    Button(action: {
                        isEditing = false
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        if let date = selectedDate, let amount = Int(editAmount) {
                            viewModel.updateOrAddItemForDate(date: date, amount: amount)
                            isEditing = false
                        }
                    }) {
                        Text("Save")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .disabled(editAmount.isEmpty || Int(editAmount) == nil)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Amount")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // 日付関連のヘルパーメソッド
    private func getDaysInMonth() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)
        return range?.count ?? 30
    }
    
    private func getFirstWeekday() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        let firstDayOfMonth = calendar.date(from: components)!
        
        // 月の最初の日の曜日を取得 (1: 日曜日, 2: 月曜日, ...)
        var firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 2
        
        // 月曜始まりに調整
        if firstWeekday < 0 {
            firstWeekday += 7
        }
        
        return firstWeekday
    }
    
    private func getDate(day: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: selectedMonth)
        components.day = day
        return calendar.date(from: components)!
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func dayDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    let previewViewModel = KAKINBOViewModel()
    return CalendarView(viewModel: previewViewModel)
        .modelContainer(for: [Item.self, Preset.self], inMemory: true)
}
