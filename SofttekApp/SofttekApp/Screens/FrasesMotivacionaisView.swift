import SwiftUI

struct FrasesMotivacionaisView: View {
    @State private var frase: String = "Carregando frase..."
    @State private var autor: String = ""
    @State private var carregando = true

    var body: some View {
        ZStack {
            Color("BackgroundSoft").ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Frase Motivacional")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                if carregando {
                    ProgressView()
                } else {
                    VStack(spacing: 12) {
                        Text("“\(frase)”")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()

                        if !autor.isEmpty {
                            Text("– \(autor)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                Button(action: {
                    carregarNovaFrase()
                }) {
                    Text("Nova frase")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Motivação")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            carregarNovaFrase()
        }
    }

    func carregarNovaFrase() {
        carregando = true
        frase = ""
        autor = ""

        guard let url = URL(string: "https://zenquotes.io/api/random") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                  let quote = json.first?["q"] as? String,
                  let author = json.first?["a"] as? String else {
                DispatchQueue.main.async {
                    frase = "Erro ao carregar frase."
                    carregando = false
                }
                return
            }

            traduzirFrase(quote) { traducao in
                DispatchQueue.main.async {
                    self.frase = traducao
                    self.autor = author
                    self.carregando = false
                }
            }

        }.resume()
    }

    func traduzirFrase(_ texto: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://libretranslate.de/translate") else {
            completion(texto)
            return
        }

        let body: [String: Any] = [
            "q": texto,
            "source": "en",
            "target": "pt",
            "format": "text"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let translated = json["translatedText"] as? String {
                completion(translated)
            } else {
                completion(texto)
            }
        }.resume()
    }
}


#Preview {
    FrasesMotivacionaisView()
}
