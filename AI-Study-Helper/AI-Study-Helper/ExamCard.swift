//
//  ExamCard.swift
//  AI-Study-Helper
//
//  Created by Luis M on 2025-03-16.
//

import Foundation

struct ExamCard: Identifiable, Codable {
    var id = UUID()
    var question: String
    var answer: String
}
