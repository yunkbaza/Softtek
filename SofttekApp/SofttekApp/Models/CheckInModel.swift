//
//  CheckInModel.swift
//  SofttekApp
//
//  Created by yunkbaza on 26/09/25.
//

import Foundation

// Modelo para representar o check-in de sentimento (Como você se sente hoje?)
struct CheckInModel: Codable {
    let sentiment: String // Ex: "Estressado", "Motivado"
    let timestamp: Date
    let userId: String
}
