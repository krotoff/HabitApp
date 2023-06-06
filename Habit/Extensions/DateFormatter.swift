//
//  DateFormatter.swift
//  Habit
//
//  Created by Andrei Krotov on 05/06/2023.
//

import Foundation.NSDateFormatter

public extension DateFormatter {

    static let weekdayShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"

        return formatter
    }()
}
