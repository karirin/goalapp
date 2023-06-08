//
//  CalendarView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/06/06.
//

import SwiftUI
import FSCalendar

struct CalendarView1: UIViewRepresentable {
    typealias UIViewType = FSCalendar
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // update your view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate {
        var parent: CalendarView1  // Change to CalendarView1
        
        init(_ parent: CalendarView1) {  // Change to CalendarView1
            self.parent = parent
        }
        
        // Implement FSCalendarDelegate methods here
    }
}

struct CalendarView: View {
    var body: some View {
        CalendarView1()
            .frame(height: 400)
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}



