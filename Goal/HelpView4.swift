//
//  HelpView4.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/07/16.
//

import SwiftUI

struct HelpView4: View {
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
                    SwipeableView4()
                    
                })
            }
        }
    }
}

struct SwipeableView4: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                FirstView4()
                    .tag(0)
//                ThirdView()
//                    .tag(2)
//                FourthView()
//                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            
            
            //CustomPageIndicator(numberOfPages: 4, currentPage: $selectedTab)
                //.padding(.bottom)
        }
    }
}

struct CustomPageIndicator4: View {
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

struct FirstView4: View {
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
            Image("チュートリアル７")
                .resizable()
                .scaledToFit()
            Spacer()
            VStack{
                Text("ご褒美画面では、投稿時に設定したご褒美に対する進捗率が表示されています。")
            }.padding()
                .padding(.bottom,20)
            }
    }
}


struct SecondView4: View {
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
            .background(Color(red: 1, green: 0.4, blue: 0.4, opacity: 0.8))
            .foregroundColor(.white)
            Spacer()
            Image("チュートリアル３")
                .resizable()
                .scaledToFit()
                .padding()
            Spacer()
            Text("また、中間目標は青色、目標は赤色で表示されます。")
                .padding()
                .padding(.bottom,10)
        }
    }
}

struct ThirdView4: View {
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
            Image("チュートリアル4")
                .resizable()
                .scaledToFit()
                .padding()
            Spacer()
            VStack{
                Text("ご褒美画面では、投稿時に設定したご褒美に対する進捗率が表示されています。")
            }.padding()
                .padding(.bottom,10)
        }
    }
}

struct FourthView4: View {
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
                Image("チュートリアル４")
                    .resizable()
                    .scaledToFit()
            }
            .padding(.top,40)
            Spacer()
            VStack{
                Text("ご褒美画面では、投稿時に設定したご褒美に対する進捗率が表示されています。")
            }
            .padding()
            .padding(.bottom,10)
        }
    }
}


struct HelpView4_Previews: PreviewProvider {
    static var previews: some View {
        HelpView4()
    }
}
