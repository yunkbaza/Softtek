import SwiftUI

struct RiskAssessmentView: View {
    struct Pergunta: Identifiable {
        let id = UUID()
        let texto: String
        let dica: String
    }

    let perguntas: [Pergunta] = [
        .init(texto: "Você tem dormido bem ultimamente?", dica: "Tente dormir em horários regulares e evitar telas antes de dormir."),
        .init(texto: "Tem se sentido sobrecarregado com responsabilidades?", dica: "Faça pausas ao longo do dia e priorize tarefas essenciais."),
        .init(texto: "Consegue tirar tempo para você mesmo?", dica: "Reserve pelo menos 15 minutos diários para algo que você goste."),
        .init(texto: "Sente que tem alguém com quem conversar?", dica: "Falar com alguém de confiança pode aliviar muito o peso emocional."),
        .init(texto: "Tem se alimentado de forma saudável?", dica: "Inclua frutas, vegetais e mantenha-se hidratado."),
        .init(texto: "Você se sente motivado ao acordar?", dica: "Comece o dia com algo leve e positivo, como música ou leitura."),
        .init(texto: "Você tem conseguido relaxar no seu dia?", dica: "Práticas como respiração profunda ou alongamento ajudam a relaxar."),
        .init(texto: "Está satisfeito com sua rotina atual?", dica: "Reflita sobre pequenas mudanças que poderiam trazer mais equilíbrio.")
    ]

    @State private var respostasNegativas: [Pergunta] = []
    @State private var perguntaAtualIndex = 0
    @State private var finalizado = false

    var body: some View {
        ZStack {
            Color("BackgroundSoft").ignoresSafeArea()

            VStack(spacing: 24) {
                if finalizado {
                    Text("Obrigado por responder 🧠")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)

                    if respostasNegativas.isEmpty {
                        Text("Você parece estar indo muito bem no momento. Continue cuidando de você! 💙")
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(respostasNegativas) { pergunta in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("🟡 \(pergunta.texto)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("💡 \(pergunta.dica)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                        }
                    }

                    Spacer()
                } else {
                    let perguntaAtual = perguntas[perguntaAtualIndex]

                    Text(perguntaAtual.texto)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()

                    HStack(spacing: 24) {
                        Button(action: {
                            avancarParaProxima(respostaFoiNegativa: false)
                        }) {
                            Text("Sim")
                                .font(.headline)
                                .frame(minWidth: 100, minHeight: 44)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(action: {
                            avancarParaProxima(respostaFoiNegativa: true)
                        }) {
                            Text("Não")
                                .font(.headline)
                                .frame(minWidth: 100, minHeight: 44)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }

                    Spacer()
                }
            }
            .padding()
        }
        .navigationTitle("Avaliação de Riscos")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func avancarParaProxima(respostaFoiNegativa: Bool) {
        if respostaFoiNegativa {
            respostasNegativas.append(perguntas[perguntaAtualIndex])
        }

        if perguntaAtualIndex < perguntas.count - 1 {
            perguntaAtualIndex += 1
        } else {
            finalizado = true
        }
    }
}

#Preview {
    RiskAssessmentView()
}
