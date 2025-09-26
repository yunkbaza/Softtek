//
//  CheckInView.swift
//  SofttekApp
//
//  Created by yunkbaza on 26/09/25.
//

import SwiftUI

struct CheckInView: View {
    @State private var selectedEmotion: String?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false // Para mostrar um indicador de loading

    let emotions = ["😄", "😊", "😐", "😢", "😠"]

    var body: some View {
        VStack(spacing: 30) {
            Text("Como você está se sentindo agora?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                ForEach(emotions, id: \.self) { emotion in
                    Button(action: {
                        self.selectedEmotion = emotion
                    }) {
                        Text(emotion)
                            .font(.system(size: 50))
                            .padding()
                            .background(self.selectedEmotion == emotion ? Color.blue.opacity(0.3) : Color.clear)
                            .clipShape(Circle())
                    }
                }
            }
            
            Button(action: submitEmotion) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Registrar Emoção")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedEmotion == nil ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(selectedEmotion == nil || isSubmitting)
            
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func submitEmotion() {
        guard let emotion = selectedEmotion else { return }
        
        isSubmitting = true
        
        // Cria o modelo com os dados a serem enviados
        let emotionData = EmotionModel(
            emotion: emotion,
            timestamp: Date(),
            userId: "ANONYMOUS_USER_ID" // IMPORTANTE: Gerencie o ID do usuário de forma real no seu app
        )
        
        // Chama a função da API
        APIManager.shared.addEmotion(emotion: emotionData) { result in
            isSubmitting = false
            switch result {
            case .success:
                alertMessage = "Sua emoção foi registrada com sucesso!"
                print("Emoção enviada com sucesso para a API.")
            case .failure(let error):
                alertMessage = "Falha ao registrar emoção. Tente novamente."
                print("Erro ao enviar emoção: \(error.localizedDescription)")
            }
            showAlert = true
        }
    }
}

struct CheckInView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInView()
    }
}
