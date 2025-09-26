//
//  RiskAssessmentModel.swift
//  SofttekApp
//
//  Created by yunkbaza on 26/09/25.
//

import Foundation

// Modelo para representar as respostas da Avaliação de Risco
struct RiskAssessmentModel: Codable {
    let question: String
    let answer: Int // A nota de 1 a 5
    let timestamp: Date
    let userId: String
}
