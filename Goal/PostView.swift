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
    @State private var milestones: [Milestone] = [Milestone(goal: "", value: 0, unit: "")]
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
        _milestones = State(initialValue: [Milestone(goal: "", value: 0, unit: "")])
    }

    var body: some View {
        VStack {
            ForEach(milestones.indices, id: \.self) { index in
                TextField("中間目標", text: $milestones[index].goal)
                TextField("値", text: Binding<String>(
                    get: { String(self.milestones[index].value) },
                    set: { self.milestones[index].value = Int($0) ?? 0 }
                ))
                TextField("単位", text: $milestones[index].unit)
            }

            Button(action: {
                self.milestones.append(Milestone(goal: "", value: 0, unit: ""))
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 24)) // --- 4
            }).frame(width: 60, height: 60)
                .background(Color(red: 0.2, green: 0.68, blue: 0.9, opacity: 1.0))
                .cornerRadius(30.0)
                .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)

            NavigationLink(destination: FourthPage(goal: $goal, date: $date, milestones: $milestones)) {
                Text("次へ")
            }
        }
        .navigationTitle("中間目標入力画面")
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
            ForEach(rewards.indices, id: \.self) { index in
                TextField("ご褒美名", text: $rewards[index].name)
                TextField("進捗率", text: Binding<String>(
                    get: { String(self.rewards[index].progress) },
                    set: { self.rewards[index].progress = Int($0) ?? 0 }
                ))
            }

            Button(action: {
                self.rewards.append(Reward(name: "", progress: 0))
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            }).frame(width: 60, height: 60)
                .background(Color(red: 0.2, green: 0.68, blue: 0.9, opacity: 1.0))
                .cornerRadius(30.0)
                .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)

            Button(action: {
                // 新しいpost IDを生成
                let postID = ref.child("posts").childByAutoId().key
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = formatter.string(from: now)
                            
                // Get current user id
                guard let currentUserId = AuthManager.shared.user?.uid else {
                    print("No current user found")
                    return
                }
                            
                // 保存するデータの作成
                let post = ["userId": currentUserId,
                            "goal": self.goal,
                            "achievement_date": self.date.description,
                            "intermediate_goal": self.milestones.map { ["goal": $0.goal, "value": $0.value, "unit": $0.unit, "progress": $0.progress] },
                            "rewards": self.rewards.map { ["name": $0.name, "progress": $0.progress] },
                            "creation_date": dateString,
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
                        
            Button(action: {
                // 新しいpost IDを生成
                let postID = ref.child("posts").childByAutoId().key
                let now = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = formatter.string(from: now)
                            
                // Get current user id
                guard let currentUserId = AuthManager.shared.user?.uid else {
                    print("No current user found")
                    return
                }
                            
                // 保存するデータの作成
                let post = ["userId": currentUserId,
                            "goal": self.goal,
                            "achievement_date": self.date.description,
                            "intermediate_goal": self.milestones.map { ["goal": $0.goal, "value": $0.value, "unit": $0.unit, "progress": $0.progress] },
                            "rewards": "",
                            "creation_date": dateString,
                            "progress_rate": 0] as [String : Any]
                // Firebase Realtime Databaseに保存
                let childUpdates = ["/posts/\(postID)": post]
                ref.updateChildValues(childUpdates)
                self.presentationMode.wrappedValue.dismiss()
                router.currentPage = .content
            }) {
                Text("スキップ")
            }
        }
        .navigationTitle("ご褒美入力画面")
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
