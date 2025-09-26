import SwiftUI

struct SupportResourcesView: View {
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
                VStack(alignment: .leading, spacing: 24) {
                    Text("Recursos de Apoio")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.top)

                    Text("Se estiver passando por um momento difícil, procure ajuda:")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)

                    VStack(spacing: 16) {
                        SupportCard(
                            title: "CVV - Centro de Valorização da Vida",
                            description: "Ligue 188 (24h, gratuito)\nwww.cvv.org.br"
                        )
                        SupportCard(title: "SAMU", description: "Emergência médica: 192")
                        SupportCard(title: "Bombeiros", description: "Emergências diversas: 193")
                        SupportCard(title: "Polícia", description: "Em caso de risco: 190")
                        SupportCard(
                            title: "Hospitais de Saúde Mental",
                            description: "Consulte os especializados na sua região."
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Apoio")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SupportCard: View {
    let title: String
    let description: String
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.blue)

            Text(description)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading) // ⬅️ Alinhamento à esquerda
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isPressed = false
                }
            }
        }
    }
}
