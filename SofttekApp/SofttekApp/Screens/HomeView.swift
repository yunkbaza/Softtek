import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundSoft").ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    // Cabeçalho
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bem-vindo de volta 👋")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)

                        Text("Como você está se sentindo hoje?")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    // Menu com cartões
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            HomeCard(
                                title: "Check-in Diário",
                                subtitle: "Registre como você está",
                                icon: "smiley",
                                color: .blue,
                                destination: CheckInView()
                            )

                            HomeCard(
                                title: "Avaliação de Riscos",
                                subtitle: "Entenda sua rotina",
                                icon: "waveform.path.ecg",
                                color: .orange,
                                destination: RiskAssessmentView()
                            )

                            HomeCard(
                                title: "Recursos de Apoio",
                                subtitle: "Apoio e links úteis",
                                icon: "lifepreserver",
                                color: .mint,
                                destination: SupportResourcesView()
                            )

                            HomeCard(
                                title: "Meu Bem-Estar",
                                subtitle: "Veja seu progresso",
                                icon: "chart.bar.xaxis",
                                color: .purple,
                                destination: WellnessGraphView()
                            )

                            HomeCard(
                                title: "Motivação Diária",
                                subtitle: "Leia uma frase inspiradora",
                                icon: "sun.max",
                                color: .indigo,
                                destination: FrasesMotivacionaisView()
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }

                    Spacer()
                }
                .padding(.top)
            }
        }
    }
}

struct HomeCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    HomeView()
}
