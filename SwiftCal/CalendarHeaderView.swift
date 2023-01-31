//
//  CalendarHeaderView.swift
//  SwiftCal
//
//  Created by Josafat Vicente Pérez on 31/1/23.
//

import SwiftUI

struct CalendarHeaderView: View {
    
    let daysOfWeek = [ "S", "M", "T","W", "T", "F", "S" ]
    var font: Font = .body
    var body: some View {
        HStack{
            ForEach(daysOfWeek, id: \.self) { dayOfWeek in
                Text(dayOfWeek)
                    .font(font)
                    .fontWeight(.black)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct CalendarHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarHeaderView()
    }
}
