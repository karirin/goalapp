//
//  PageView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/07.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct Milestone {
    var goal: String
    var value: Int
    var unit: String
    var progress: Int = 0
}

struct Reward {
    var name: String
    var progress: Int
}

class NavigationRouter: ObservableObject {
    enum Page {
        case first
        case second
        case third
        case fourth
        case content
    }
    
    @Published var currentPage: Page = .first
    @Published var progress: Float = 0.0  // 追加した進捗バー
    func updateProgress() {
        switch currentPage {
        case .first:
            progress = 0.25
        case .second:
            progress = 0.5
        case .third:
            progress = 0.75
        case .fourth, .content:
            progress = 1.0
        }
    }

}

struct ProgressBar: View {
    @Binding var value: Float

    var body: some View {
        ProgressView(value: value)
    }
}

struct CenteredTitleView: View {
    var title: String

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

class AppState: ObservableObject {
    @Published var goal: String = ""
    @Published var date: Date = Date()
    @Published var milestones: [Milestone] = [Milestone(goal: "", value: 0, unit: "")]
    @Published var hasPosts: Bool = false
    // Add other states as needed

    init() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        let postsRef = Database.database().reference().child("posts")
        postsRef.queryOrdered(byChild: "userId").queryEqual(toValue: currentUserId).observeSingleEvent(of: .value) { snapshot in
            // Set hasPosts to true if there are any posts for the current user
            self.hasPosts = snapshot.exists()
        }
    }
}

struct RootView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            ProgressBar(value: $router.progress)
            switch router.currentPage {
            case .first:
                FirstPage()
            case .second:
                SecondPage(goal: $appState.goal)
            case .third:
                ThirdPage(goal: $appState.goal, date: $appState.date)
            case .fourth:
                FourthPage(goal: $appState.goal, date: $appState.date, milestones: $appState.milestones)
            case .content:
                TopView()
            }
        }
    }
}


struct FirstPage: View {
    @State private var goal: String = ""
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        NavigationView {
            VStack {
                HStack{
                Text("目標を入力してください")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                }
                Text("このアプリで達成したい目標を入力してください")
                        .font(.system(size: 18))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                HStack {
                    Spacer()
                TextField("目標", text: $goal)
                    .font(.system(size: 30))
                    Spacer() // this will push the TextField to the center
                                    }
                    .padding()

                NavigationLink(destination: SecondPage(goal: $goal)) {
                    Text("次へ")
                }
                .padding(.vertical,10)
                .padding(.horizontal,25)
                .font(.headline)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 25).fill(Color(red: 1.0, green: 0.68, blue: 0.6, opacity: 1.0)))
                .onAppear(perform: {
                    router.updateProgress()
                })
                .padding()
            }
        }
    }
}

struct SecondPage: View {
    @Binding var goal: String
    @State private var date = Date()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var router: NavigationRouter
    
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
            HStack{
            Text("達成日を入力してください")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
            }
            Text("目標に対していつまでに達成したいかを入力してください")
                    .font(.system(size: 18))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            HStack{
                Spacer()
                Image(systemName: "calendar")
                DatePicker("", selection: $date, displayedComponents: .date)
                Spacer()
                //.padding()
            }.frame(width:50)
            NavigationLink(destination: ThirdPage(goal: $goal, date: $date)) {
                Text("次へ")
            }.padding(.vertical,10)
                .padding(.horizontal,25)
                .font(.headline)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 25).fill(Color(red: 1.0, green: 0.68, blue: 0.6, opacity: 1.0)))
                .onAppear(perform: {
                router.updateProgress()
            })
            .padding()
        }
        //.navigationTitle("達成日入力画面")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
        //Spacer()
    }
}

struct ThirdPage: View {
    @Binding var goal: String
    @Binding var date: Date
    @State private var milestones: [Milestone] = [Milestone(goal: "", value: 0, unit: "")]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var router: NavigationRouter
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
        _milestones = State(initialValue: [Milestone(goal: "", value: 0, unit: "")])
    }

    var body: some View {
        VStack {
            HStack{
            Text("中間目標を入力してください")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
            }
            Text("目標に対しての中間目標を入力してください")
                    .font(.system(size: 18))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            ForEach(milestones.indices, id: \.self) { index in
                HStack{
                    TextField("中間目標", text: $milestones[index].goal)
                        .font(.system(size: 22))
                    TextField("値", text: Binding<String>(
                        get: { String(self.milestones[index].value) },
                        set: { self.milestones[index].value = Int($0) ?? 0 }
                    ))
                    .font(.system(size: 22))
                    TextField("単位", text: $milestones[index].unit)
                        .font(.system(size: 22))
                }.padding()
            }
            HStack{
                Spacer()
                Button(action: {
                    self.milestones.append(Milestone(goal: "", value: 0, unit: ""))
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24)) // --- 4
                }).frame(width: 60, height: 60)
                    .background(Color(red: 1.0, green: 0.68, blue: 0.6, opacity: 1.0))
                    .cornerRadius(30.0)
                    .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding()

            NavigationLink(destination: FourthPage(goal: $goal, date: $date, milestones: $milestones)) {
                Text("次へ")
            }.padding(.vertical,10)
                .padding(.horizontal,25)
                .font(.headline)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 25).fill(Color(red: 1.0, green: 0.68, blue: 0.6, opacity: 1.0)))
        }
        //.navigationTitle("中間目標入力画面")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }
}

struct FourthPage: View {
    @Binding var goal: String
    @Binding var date: Date
    @Binding var milestones: [Milestone]
    @State private var rewards: [Reward] = [Reward(name: "", progress: 0)]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let ref = Database.database().reference()
    @EnvironmentObject var router: NavigationRouter
    
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

    init(goal: Binding<String>, date: Binding<Date>, milestones: Binding<[Milestone]>) {
        _goal = goal
        _date = date
        _milestones = milestones
        _rewards = State(initialValue: [Reward(name: "", progress: 0)])
    }

    var body: some View {
        VStack {
            HStack{
            Text("ご褒美を入力してください")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
            }
            Text("目標の進捗率によってご褒美を設定してモチベーションを保ちましょう")
                    .font(.system(size: 18))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            ForEach(rewards.indices, id: \.self) { index in
                HStack{
                    Text("達成率")
                    TextField("進捗率", text: Binding<String>(
                        get: { String(self.rewards[index].progress) },
                        set: { self.rewards[index].progress = Int($0) ?? 0 }
                    ))
                    .frame(width:30)
                    Text("％")
                        
                    TextField("ご褒美名", text: $rewards[index].name)
                }
                .font(.system(size: 28))
                .padding(.horizontal)
            }
            
            HStack{
                Spacer()
                Button(action: {
                    self.rewards.append(Reward(name: "", progress: 0))
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }).frame(width: 60, height: 60)
                    .background(Color(red: 1.0, green: 0.68, blue: 0.6, opacity: 1.0))
                    .cornerRadius(30.0)
                    .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding()
            Button(action: {
                // 新しいpost IDを生成
                let postID = ref.child("posts").childByAutoId().key
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString_now = formatter.string(from: now)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: self.date)
                            
                // Get current user id
                guard let currentUserId = AuthManager.shared.user?.uid else {
                    print("No current user found")
                    return
                }
                            
                // 保存するデータの作成
                let post = ["userId": currentUserId,
                            "goal": self.goal,
                            "achievement_date": dateString,
                            "intermediate_goal": self.milestones.map { ["goal": $0.goal, "value": $0.value, "unit": $0.unit, "progress": $0.progress] },
                            "rewards": self.rewards.map { ["name": $0.name, "progress": $0.progress] },
                            "creation_date": dateString_now,
                            "progress_rate": 0] as [String : Any]
                // Firebase Realtime Databaseに保存
                let childUpdates = ["/posts/\(postID)": post]
                ref.updateChildValues(childUpdates)

                // Transition to ContentView
                self.presentationMode.wrappedValue.dismiss()
                router.currentPage = .content
            }) {
                Text("投稿")
            }
            .padding(.vertical,10)
                .padding(.horizontal,25)
                .font(.headline)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 25).fill(Color(red: 1.0, green: 0.68, blue: 0.6, opacity: 1.0)))
                        
            Button(action: {
                // 新しいpost IDを生成
                let postID = ref.child("posts").childByAutoId().key
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString_now = formatter.string(from: now)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: self.date)
                            
                // Get current user id
                guard let currentUserId = AuthManager.shared.user?.uid else {
                    print("No current user found")
                    return
                }
                            
                // 保存するデータの作成
                let post = ["userId": currentUserId,
                            "goal": self.goal,
                            "achievement_date": dateString,
                            "intermediate_goal": self.milestones.map { ["goal": $0.goal, "value": $0.value, "unit": $0.unit, "progress": $0.progress] },
                            "rewards": "",
                            "creation_date": dateString_now,
                            "progress_rate": 0] as [String : Any]
                // Firebase Realtime Databaseに保存
                let childUpdates = ["/posts/\(postID)": post]
                ref.updateChildValues(childUpdates)
                self.presentationMode.wrappedValue.dismiss()
                router.currentPage = .content
            }) {
                Text("スキップ")
            }
            .padding(.vertical,10)
                .padding(.horizontal,25)
                .font(.headline)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 25).fill(Color(red: 1.0, green: 0.68, blue: 0.6, opacity: 1.0)))
        }
        //.navigationTitle("ご褒美入力画面")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }
}

struct PostView: App {
    @StateObject var router = NavigationRouter()
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(appState)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(NavigationRouter()).environmentObject(AppState())
    }
}
