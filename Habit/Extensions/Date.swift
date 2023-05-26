//
//  Date.swift
//  Habit
//
//  Created by Andrei Krotov on 23/05/2023.
//

import Foundation.NSDate

public extension Date {

    var midnight: Date { Calendar.current.startOfDay(for: self) }

    func isSameDay(with date: Date) -> Bool { date.midnight == midnight }
}
