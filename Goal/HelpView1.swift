//
//  HelpView1.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/07/16.
//

import SwiftUI

struct HelpView1: View {
    @State private var isSheetPresented = false
    
    var body: some View {
        ZStack{
            Image(systemName: "circle.fill")
                .cornerRadius(30.0)
                .font(.system(size: 40))
                .foregroundColor(.white)
            VStack {
                Button(action: {
                    self.isSheetPresented = true
                }, label:  {
                    Image(systemName: "questionmark.circle")
                    
                        .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.8))
                        .cornerRadius(30.0)
                    
                        .font(.system(size: 40)) // --- 4
                    
                })
                .sheet(isPresented: $isSheetPresented, content: {
                    SwipeableView()
                    
                })
            }
        }
    }
}

struct SwipeableView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                FirstView()
                    .tag(0)
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

struct CustomPageIndicator: View {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.primary : Color.gray)
                    .frame(width: 10, height: 10)
                    .padding(.horizontal, 4)
            }
        }
    }
}

struct FirstView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .padding()
                Spacer()
                Text("チュートリアル")
                Spacer()
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("閉じる")
                }
                .opacity(0)
                Spacer()
            }
            .background(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.8))
            .foregroundColor(.white)
            Spacer()
            Image("チュートリアル１")
                .resizable()
                .scaledToFit()
            Spacer()
            VStack{
                Text("ホーム画面には、目標の進捗率と各中間目標の進捗が表示されています。")
                Text("中間目標に進捗がある場合は、プラスボタンまたはマイナスボタンをクリックすることで、それを反映できます。")
            }.padding()
                .padding(.bottom,20)
            }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView1()
    }
}
