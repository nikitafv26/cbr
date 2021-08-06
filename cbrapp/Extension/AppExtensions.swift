//
//  DateHelper.swift
//  cbrapp
//
//  Created by Nikita Fedorenko on 05.08.2021.
//

import Foundation

extension Date{
    func getFormattedDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension String{
    func getFormattedDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: self)
    }
}

