//
//  PageView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/07.
//

import SwiftUI
import Firebase

struct FirstPage: View {
    @State private var goal: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("目標を入力してください", text: $goal)
                    .padding()

                NavigationLink(destination: SecondPage(goal: $goal)) {
                    Text("次へ")
                }
                .padding()
            }
            .navigationTitle("目標入力画面")
        }
    }
}

struct SecondPage: View {
    @Binding var goal: String
    @State private var date = Date()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var btnBack : some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
                Text("戻る")
                    .foregroundColor(.black)
                    .font(.body)
            }
        }
    }

    var body: some View {
        VStack {
            DatePicker("達成日を選択してください", selection: $date, displayedComponents: .date)
                .padding()

            NavigationLink(destination: ThirdPage(goal: $goal, date: $date)) {
                Text("次へ")
            }
            .padding()
        }
        .navigationTitle("達成日入力画面")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }
}

struct ThirdPage: View {
    @Binding var goal: String
    @Binding var date: Date
    @State private var milestones = [String]()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let ref = Database.database().reference()
    
    var btnBack : some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.black)
                Text("戻る")
                    .foregroundColor(.black)
                    .font(.body)
            }
        }
    }
    
    init(goal: Binding<String>, date: Binding<Date>) {
        _goal = goal
        _date = date
        _milestones = State(initialValue: [""])
    }

    var body: some View {
        VStack {
            ForEach(milestones.indices, id: \.self) { index in
                TextField("中間目標", text: $milestones[index])
            }

            Button(action: {
                self.milestones.append("")
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 24)) // --- 4
            }).frame(width: 60, height: 60)
                .background(Color(red: 0.2, green: 0.68, blue: 0.9, opacity: 1.0))
                .cornerRadius(30.0)
                .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)

            Button(action: {
                print("目標: \(self.goal)")
                print("達成日: \(self.date)")
                print("中間目標: \(self.milestones)")
                
                // 新しいpost IDを生成
                let postID = ref.child("posts").childByAutoId().key
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = formatter.string(from: now)
                
                // 保存するデータの作成
                let post = ["目標": self.goal,
                            "達成日": self.date.description, // 日付を文字列に変換
                            "中間目標": self.milestones,
                            "作成日": dateString] as [String : Any]

                // Firebase Realtime Databaseに保存
                let childUpdates = ["/posts/\(postID)": post]
                ref.updateChildValues(childUpdates)

            }) {
                Text("投稿")
            }
        }
        .navigationTitle("中間目標入力画面")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        FirstPage()
    }
}
