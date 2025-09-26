//
//  APIManager.swift
//  SofttekApp
//
//  Created by yunkbaza on 26/09/25.
//

import Foundation

// Enum para um tratamento de erros de rede mais claro e profissional.
enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case encodingError(Error)
}

// Classe final para gerenciar toda a comunicação com a API RESTful.
final class APIManager {
    
    // Padrão Singleton para garantir uma única instância em todo o app.
    static let shared = APIManager()
    
    // URL base da sua API no Firebase Functions.
    // Lembre-se de colocar a URL do seu deploy aqui quando publicar.
    private let baseURL = "http://127.0.0.1:5001/softtek-challenge/us-central1/api"
    
    // Construtor privado.
    private init() {}
    
    // MARK: - Funções Genéricas de Requisição
    
    /// Função genérica para realizar requisições POST
    private func postRequest<T: Encodable>(path: String, body: T, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    /// Função genérica para realizar requisições GET
    private func getRequest<T: Decodable>(path: String, completion: @escaping (Result<[T], NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601 // Para converter datas automaticamente
                    let decodedData = try decoder.decode([T].self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        task.resume()
    }

    // MARK: - Endpoints Específicos
    
    /// Envia um novo registro de check-in (sentimento) para o servidor.
    func addCheckIn(checkIn: CheckInModel, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        postRequest(path: "/check-in", body: checkIn, completion: completion)
    }
    
    /// Envia uma nova avaliação de risco para o servidor.
    func addRiskAssessment(risk: RiskAssessmentModel, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        postRequest(path: "/risks", body: risk, completion: completion)
    }

    /// Envia o registro de uma emoção (check-in de humor) para o servidor.
    func addEmotion(emotion: EmotionModel, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        postRequest(path: "/emotions", body: emotion, completion: completion)
    }
    
    /// Busca o histórico de emoções do servidor.
    func getAllEmotions(completion: @escaping (Result<[EmotionModel], NetworkError>) -> Void) {
        getRequest(path: "/emotions", completion: completion)
    }
}
