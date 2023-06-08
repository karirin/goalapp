//
//  ContentView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/06.
//

import SwiftUI

struct ContentView: View {
    @State var date = Date()
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $date)
                .datePickerStyle(GraphicalDatePickerStyle())
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
