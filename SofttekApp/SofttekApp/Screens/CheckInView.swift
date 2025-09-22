import SwiftUI

struct CheckInView: View {
    let emotions: [(String, String)] = [
        ("😀", "Alegre"), ("😔", "Triste"), ("😠", "Bravo"), ("😍", "Amoroso"),
        ("😨", "Assustado"), ("😎", "Confiante"), ("😡", "Estressado"),
        ("😴", "Cansado"), ("😭", "Chorando"), ("🤔", "Pensativo"),
        ("😞", "Solitário"), ("🙏", "Grato")
    ]

    @State private var selectedEmotion: (emoji: String, name: String)? = nil
    @State private var showSavedMessage = false

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

            VStack(spacing: 24) {
                // Título
                VStack(spacing: 6) {
                    Text("Como você está se sentindo agora?")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black)

                    Text("Escolha uma emoção abaixo para registrar seu estado.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top)

                // Destaque da emoção selecionada com cor personalizada
                if let emotion = selectedEmotion {
                    VStack(spacing: 6) {
                        Text(emotion.0)
                            .font(.system(size: 60))
                        Text(emotion.name)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(emotionColor(emotion.name)) // ✅ apenas aqui
                    }
                    .transition(.opacity.combined(with: .scale))
                }

                // Grid de emoções com texto neutro
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 20) {
                    ForEach(emotions, id: \.1) { emotion in
                        Button(action: {
                            withAnimation {
                                selectedEmotion = emotion
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(emotion.0)
                                    .font(.system(size: 30))
                                Text(emotion.1)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary) // 👈 mantém texto neutro
                            }
                            .frame(width: 90, height: 90)
                            .background(
                                emotionColor(emotion.1)
                                    .opacity(selectedEmotion?.name == emotion.1 ? 0.5 : 0.15)
                            )
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                        }
                    }
                }
                .padding(.horizontal)

                // Botão de registrar com azul clarinho
                if selectedEmotion != nil {
                    Button(action: {
                        if let name = selectedEmotion?.name {
                            DatabaseManager.shared.addEmotion(name)
                            withAnimation {
                                showSavedMessage = true
                                selectedEmotion = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSavedMessage = false
                            }
                        }
                    }) {
                        Text("Registrar Sentimento")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.4, green: 0.7, blue: 1.0)) // azul clarinho
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }

                // Feedback visual
                if showSavedMessage {
                    Text("✅ Sentimento salvo com sucesso!")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.green)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Check-in Diário")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Cor personalizada por emoção
    func emotionColor(_ name: String) -> Color {
        switch name {
        case "Alegre": return .yellow
        case "Triste": return .blue
        case "Bravo": return .red
        case "Amoroso": return .pink
        case "Assustado": return .purple
        case "Confiante": return .green
        case "Estressado": return .orange
        case "Cansado": return .gray
        case "Chorando": return .cyan
        case "Pensativo": return .indigo
        case "Solitário": return .mint
        case "Grato": return .teal
        default: return .gray
        }
    }
}

#Preview {
    CheckInView()
}

