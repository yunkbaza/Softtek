//
//  EmotionModel.swift
//  SofttekApp
//
//  Created by yunkbaza on 26/09/25.
//

import Foundation

// Modelo para representar o check-in de humor (emojis)
struct EmotionModel: Codable, Identifiable {
    var id: String? // Opcional, pois o ID é gerado pelo Firestore no back-end
    let emotion: String
    let timestamp: Date
    let userId: String
}
