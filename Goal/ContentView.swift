//
//  ContentView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/06.
//

import SwiftUI
import GoogleMobileAds

struct BannerView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UIViewController {
        let viewController = GADBannerViewController()
        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

class GADBannerViewController: UIViewController, GADBannerViewDelegate {
    var bannerView: GADBannerView!
    let adUnitID = "ca-app-pub-3940256099942544/2934735716"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBanner()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            self.loadBanner()
        }
    }

    private func loadBanner() {
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID

        bannerView.delegate = self
        bannerView.rootViewController = self

        let bannerWidth = view.frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth)

        let request = GADRequest()
        request.scene = view.window?.windowScene
        bannerView.load(request)

        setAdView(bannerView)
    }

    func setAdView(_ view: GADBannerView) {
        bannerView = view
        self.view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        let viewDictionary = ["_bannerView": bannerView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_bannerView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary
            )
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_bannerView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary
            )
        )
    }
}

struct ProgressRingView: View {
    var progress: Double
    var goal: String
    var intermediate_goals: [GoalViewModel.IntermediateGoal]
    var updateProgressInFirebase: (Int, Int, Date, Bool) -> Void
    @State private var showingAlert = false
    @State private var showingIntermediateAlert = false  // Add this line
    @State private var showAlert: Bool = false
    @State private var achievedIntermediateGoalIndex: Int?
    @EnvironmentObject private var viewModel: GoalViewModel
    @State private var showPostView = false
    @StateObject var router = NavigationRouter()
    @StateObject var appState = AppState()
    
    init(progress: Double, goal: String, intermediate_goals: [GoalViewModel.IntermediateGoal], updateProgressInFirebase: @escaping (Int, Int, Date, Bool) -> Void) {
        self.progress = progress
        self.goal = goal
        self.intermediate_goals = intermediate_goals
        self.updateProgressInFirebase = updateProgressInFirebase
    }

    func checkIntermediateGoals(for index: Int) {
        print("checkIntermediateGoals index:\(index)")
        if index < intermediate_goals.count {
            let goal = intermediate_goals[index]
            if goal.progress + 1 == goal.value {
                achievedIntermediateGoalIndex = index
                showingIntermediateAlert = true
            }
        } else {
            // indexが範囲外の場合の処理を書く
            print("Index out of range1")
        }
    }

    var body: some View {
        VStack{
            HStack{
                HelpView1()
                    .opacity(0)
                Spacer()
                Text("目標")
                    .fontWeight(.bold) // <- Change this line
                Spacer()
                HelpView1()
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.8))
            .foregroundColor(.white)
            .frame(height:50)
            .font(.system(size: 20))
            VStack {
                //.frame(height: 40)
                ZStack {
                    Circle()
                        .stroke(lineWidth: 15)
                        .opacity(0.3)
                        .padding(-20)
                        .padding(.leading,5)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90))
                        .padding(-20)
                        .padding(.leading,5)
                        .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 1))
                    
                    VStack {
                        Text(goal)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .onChange(of: progress) { newValue in
                                if newValue == 1.0 {
                                    showingAlert = true
                                }
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text("目標達成"), message: Text("おめでとうございます！目標達成です！"), dismissButton: .default(Text("OK")))
                            }
                    }
                }
                
                ScrollView {
                    VStack {
                        ForEach(0..<intermediate_goals.count, id: \.self) { index in
                            if index < intermediate_goals.count {
                                let intermediate_goal = intermediate_goals[index]
                                
                                HStack{
                                    //Text("index: \(intermediate_goals.count)")
                                    Text(intermediate_goal.goal)
                                        .font(.system(size: 24))
                                        .padding(.top)
                                        .padding(.bottom,1)
                                    Spacer()
                                }
                                .padding(.leading)
                                HStack{
                                    Button(action: {
                                        let currentDate = Date()
                                        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { return }
                                        //print("Next day: \(nextDay)")
                                        updateProgressInFirebase(index, intermediate_goal.progress - 1, currentDate, false) // Remove isProgressIncreased label
                                        print("currentDate:\(currentDate)")
                                    }) {
                                        Image(systemName: "minus.circle")
                                    }
                                    .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.5))
                                    .padding(.leading)
                                    .font(.system(size: 30))
                                    
                                    Spacer()
                                    VStack {
                                        HStack {
                                            Text("\(intermediate_goal.progress)")
                                            Text(" / ")
                                            Text("\(intermediate_goal.value)")
                                            Text(intermediate_goal.unit)
                                        }
                                    }
                                    .font(.system(size: 25))
                                    //.padding(.bottom)
                                    Spacer()
                                    Button(action: {
                                        let currentDate = Date()  // Get current date
                                        checkIntermediateGoals(for: index)
                                        updateProgressInFirebase(index, intermediate_goal.progress + 1, currentDate, true)
                                        print("currentDate:\(currentDate)")
                                    }) {
                                        Image(systemName: "plus.circle")
                                    }
                                    .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.5))
                                    .padding(.trailing)
                                    .font(.system(size: 30))
                                }
                                .alert(isPresented: $showingIntermediateAlert) {
                                    // Make sure the index is valid before trying to access the goal
                                    guard let index = achievedIntermediateGoalIndex, intermediate_goals.indices.contains(index) else {
                                        return Alert(title: Text("エラー"), message: Text("達成した中間目標を表示できませんでした。"), dismissButton: .default(Text("OK")))
                                    }
                                    
                                    // Access the achieved goal
                                    let achievedGoal = intermediate_goals[index]
                                    print("index:\(index)")
                                    return Alert(title: Text("中間目標を達成"), message: Text("おめでとうございます！\n中間目標の\(achievedGoal.goal)を達成しました！"), dismissButton: .default(Text("OK")))
                                }
                            } else {
                                // indexが範囲外の場合の処理を書く
                                Text("Index out of range1")
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .padding(.top,20)
            .background(Color(red: 0.99, green: 0.99, blue: 0.99, opacity: 1.0))
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var viewModel: GoalViewModel
    
    var body: some View {
            Group {
                if viewModel.dataFetched {
                    //Text("\(viewModel.dataFetched)")
                    
                    ProgressRingView(
                        progress: viewModel.progress,
                        goal: viewModel.goal,
                        intermediate_goals: viewModel.intermediateGoals,
                        updateProgressInFirebase: { index, newProgress, date, isProgressIncreased in
                            print("updateIntermediateProgress呼び出し前のindex:\(index)")
                            if index < viewModel.intermediateGoals.count {
                                viewModel.updateIntermediateProgress(index, newProgress, date, isProgressIncreased: isProgressIncreased)
                            } else {
                                // indexが範囲外の場合の処理を書く
                                print("Index out of range1")
                            }
                        }
                    )
                } else {
                    // Display a loading indicator or placeholder here
                    ZStack {
                    LoadingView()
                            .frame(width: 100, height: 100)  // ローディングビューのサイズを設定します。
                            .position(x: UIScreen.main.bounds.width / 2.0, y: UIScreen.main.bounds.height / 2.2)  // ローディングビューを画面の中央に配置します。
                    }
                }
            }
            .onAppear {
                    viewModel.fetchGoal(){
                        promptForReview()
                    }
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GoalViewModel())
    }
}
