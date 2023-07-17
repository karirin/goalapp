//
//  HelpView3.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/07/16.
//

import SwiftUI

struct HelpView3: View {
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
                    //.foregroundColor(.black)
                    //.background(Color.blue)
                        .cornerRadius(30.0)
                    
                        .font(.system(size: 40)) // --- 4
                    
                })
                
                
                //.shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
                .sheet(isPresented: $isSheetPresented, content: {
                    SwipeableView3()
                })
            }
        }
    }
}

struct SwipeableView3: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                FirstView3()
                    .tag(0)
                SecondView3()
                    .tag(1)
//                ThirdView()
//                    .tag(2)
//                FourthView()
//                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            
            
            CustomPageIndicator(numberOfPages: 2, currentPage: $selectedTab)
                .padding(.bottom)
        }
    }
}

struct CustomPageIndicator3: View {
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

struct FirstView3: View {
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
            Image("チュートリアル５")
                .resizable()
                .scaledToFit()
            Spacer()
            VStack{
                Text("折れ線グラフを用いて、中間目標の進捗推移を視覚的に確認することができます。")
                Text("また、円状の進捗バーは中間目標の進捗率を表しています。")
            }.padding()
                .padding(.bottom,20)
            }
    }
}


struct SecondView3: View {
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
            HStack{
                Image("チュートリアル４")
                    .resizable()
                    .scaledToFit()
                Image("チュートリアル６")
                    .resizable()
                    .scaledToFit()
            }
                .padding()
            Spacer()
            Text("折れ線グラフは月毎に集計され、画面を左右にスライドすることで各月の進捗を確認できます。")
                .padding()
                .padding(.bottom,10)
        }
    }
}

struct ThirdView3: View {
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
                Text("")
                Spacer()
            }
            .background(Color(red: 0.2, green: 0.68, blue: 0.9, opacity: 1.0))
            .foregroundColor(.white)
            Spacer()
            Image("チュートリアル４")
                .resizable()
                .scaledToFit()
                .padding()
            Spacer()
            VStack{
                Text(" 折れ線グラフを用いて、中間目標の進捗推移を視覚的に確認することができます。")
                Text("また、円状の進捗バーは中間目標の進捗率を表しています。")
            }.padding()
                .padding(.bottom,10)
        }
    }
}

struct FourthView3: View {
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
                Text("")
                Spacer()
            }
            .background(Color(red: 0.2, green: 0.68, blue: 0.9, opacity: 1.0))
            .foregroundColor(.white)
            Spacer()
            VStack{
                Image("チュートリアル５")
                    .resizable()
                    .scaledToFit()
                //.frame(width: 500, height: 500)
                
            }
            .padding(.top,40)
            Spacer()
            VStack{
                Text("折れ線グラフは月毎に集計され、画面を左右にスライドすることで各月の進捗を確認できます。")
            }
            .padding()
            .padding(.bottom,10)
        }
    }
}


struct HelpView3_Previews: PreviewProvider {
    static var previews: some View {
        HelpView3()
    }
}
