import SwiftUI

struct WellnessGraphView: View {
    @State private var emotions: [Emotion] = []
    let negativeEmotions = ["Triste", "Bravo", "Assustado", "Estressado", "Cansado", "Chorando", "Pensativo"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 245/255, green: 250/255, blue: 255/255),
                    Color(red: 220/255, green: 235/255, blue: 255/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Text("Resumo do seu Bem-Estar")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.top)

                    if emotions.isEmpty {
                        Text("Nenhum registro ainda.")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        Text("Nível atual: \(wellnessLevel(from: emotions))")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(emotionCount(), id: \.emotion) { data in
                                VStack(alignment: .leading) {
                                    Text("\(data.emotion) (\(data.count))")
                                        .font(.caption)
                                        .padding(.bottom, 2)

                                    GeometryReader { geo in
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(color(for: data.emotion))
                                            .frame(width: min(CGFloat(data.count) * 25, geo.size.width), height: 20)
                                    }
                                    .frame(height: 20)
                                }
                            }
                        }
                        .padding(.horizontal)

                        Divider().padding(.vertical)

                        ForEach(emotions) { emotion in
                            HStack {
                                Text(emoji(for: emotion.emotion))
                                    .font(.largeTitle)
                                VStack(alignment: .leading) {
                                    Text(emotion.emotion)
                                        .font(.headline)
                                    Text(formattedDate(emotion.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.bottom)
            }
            .onAppear {
                emotions = DatabaseManager.shared.getAllEmotions()
            }
        }
        .navigationTitle("Meu Bem-Estar")
        .navigationBarTitleDisplayMode(.inline)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func emoji(for emotion: String) -> String {
        switch emotion {
        case "Alegre": return "😀"
        case "Triste": return "😔"
        case "Bravo": return "😠"
        case "Amoroso": return "😍"
        case "Assustado": return "😨"
        case "Confiante": return "😎"
        case "Estressado": return "😡"
        case "Cansado": return "😴"
        case "Chorando": return "😭"
        case "Pensativo": return "🤔"
        default: return "🙂"
        }
    }

    func emotionCount() -> [(emotion: String, count: Int)] {
        var counts: [String: Int] = [:]
        for emotion in emotions {
            counts[emotion.emotion, default: 0] += 1
        }
        return counts.map { ($0.key, $0.value) }
    }

    func color(for emotion: String) -> Color {
        switch emotion {
        case "Alegre": return Color.yellow.opacity(0.7)
        case "Triste": return Color.blue.opacity(0.6)
        case "Bravo": return Color.red.opacity(0.7)
        case "Amoroso": return Color.pink.opacity(0.7)
        case "Assustado": return Color.purple.opacity(0.6)
        case "Confiante": return Color.green.opacity(0.6)
        case "Estressado": return Color.orange.opacity(0.7)
        case "Cansado": return Color.gray.opacity(0.6)
        case "Chorando": return Color.cyan.opacity(0.7)
        case "Pensativo": return Color.gray.opacity(0.5)
        default: return Color.gray.opacity(0.4)
        }
    }

    // Novo cálculo de bem-estar com pesos para cada emoção
    func wellnessLevel(from emotions: [Emotion]) -> String {
        let emotionWeights: [String: Double] = [
            "Triste": 1.0,
            "Bravo": 1.0,
            "Assustado": 1.0,
            "Estressado": 0.9,
            "Cansado": 0.7,
            "Chorando": 1.1,
            "Pensativo": 0.6,
            "Alegre": -0.5,
            "Motivado": -0.3,
            "Animado": -0.4,
            "Satisfeito": -0.6
        ]

        var totalWeight: Double = 0
        var totalEmotions: Double = 0

        // Calcular o total de pesos e o número de emoções
        for emotion in emotions {
            if let weight = emotionWeights[emotion.emotion] {
                totalWeight += weight
            }
            totalEmotions += 1
        }

        // Média ponderada
        let averageWeight = totalWeight / totalEmotions

        // Categorizar o nível de bem-estar
        switch averageWeight {
        case _ where averageWeight < -0.7:
            return "Excelente"
        case _ where averageWeight < -0.4:
            return "Muito Bom"
        case _ where averageWeight < 0.0:
            return "Bom"
        case _ where averageWeight < 0.4:
            return "Leve"
        case _ where averageWeight < 0.7:
            return "Moderado"
        default:
            return "Agudo"
        }
    }
}

#Preview {
    WellnessGraphView()
}
