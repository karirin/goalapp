////
////  TestView.swift
////  Goal
////
////  Created by hashimo ryoya on 2023/06/25.
////
//
//import SwiftUI
//
//struct TestView: View {
//    @State private var date = Date()
//    @Binding var goal: String
//    
//    var btnBack : some View {
//        Button(action: {
//            //self.presentationMode.wrappedValue.dismiss()
//        }) {
//            HStack {
//                Image(systemName: "chevron.left")
//                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(.black)
//                Text("戻る")
//                    .foregroundColor(.black)
//                    .font(.body)
//            }
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            HStack{
//            Text("目標を入力してください")
//                    .font(.system(size: 30))
//                    .fontWeight(.bold)
//            }
//            Text("このアプリで達成したい目標を入力してください")
//                    .font(.system(size: 18))
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding()
//            DatePicker("", selection: $date, displayedComponents: .date)
//                //.padding()
//
//            NavigationLink(destination: ThirdPage(goal: $goal, date: $date)) {
//                Text("次へ")
//            }.padding(.vertical,10)
//                .padding(.horizontal,25)
//                .font(.headline)
//                .foregroundColor(.white)
//                .background(RoundedRectangle(cornerRadius: 25).fill(Color(red: 1.0, green: 0.68, blue: 0.6, opacity: 1.0)))
//                .onAppear(perform: {
//                //router.updateProgress()
//            })
//            .padding()
//        }
//        //.navigationTitle("達成日入力画面")
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: btnBack)
//    }
//}
//
//struct TestView_Previews: PreviewProvider {
//    @Binding var goal: String
//    
//    static var previews: some View {
//        TestView(goal: "test")
//    }
//}
