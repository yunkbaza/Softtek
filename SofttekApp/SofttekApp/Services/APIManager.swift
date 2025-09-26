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
    case unauthorized // Erro específico para falha de autenticação
    case invalidResponse
    case decodingError(Error)
    case encodingError(Error)
}

// Classe final para gerenciar toda a comunicação com a API RESTful.
final class APIManager {
    
    // Padrão Singleton para garantir uma única instância em todo o app.
    static let shared = APIManager()
    
    // URL base da sua API no Firebase Functions.
    private let baseURL = "http://127.0.0.1:5001/softtek-challenge/us-central1/api"
    
    // --- [REQUISITO OBRIGATÓRIO: SEGURANÇA] ---
    // A Chave de API que o app usará para se autenticar no back-end.
    // DEVE ser a mesma chave definida no seu arquivo index.ts!
    private let apiKey = "sua-chave-secreta-aqui-12345"
    
    // Construtor privado.
    private init() {}
    
    // MARK: - Funções Genéricas de Requisição
    
    /// Função genérica para realizar requisições, agora com o cabeçalho de autenticação.
    private func createRequest(path: String, method: String) -> URLRequest? {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // --- [REQUISITO OBRIGATÓRIO: SEGURANÇA] ---
        // Adiciona a chave de API ao cabeçalho de todas as requisições.
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        return request
    }
    
    /// Função genérica para realizar requisições POST
    private func postRequest<T: Encodable>(path: String, body: T, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard var request = createRequest(path: path, method: "POST") else {
            completion(.failure(.invalidURL))
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }
        
        executeTask(with: request, completion: completion)
    }
    
    /// Função genérica para realizar requisições GET
    private func getRequest<T: Decodable>(path: String, completion: @escaping (Result<[T], NetworkError>) -> Void) {
        guard let request = createRequest(path: path, method: "GET") else {
            completion(.failure(.invalidURL))
            return
        }
        
        executeTask(with: request, completion: completion)
    }
    
    /// Função genérica para executar a tarefa de rede e tratar as respostas.
    private func executeTask<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                // Trata o erro de chave de API inválida
                if httpResponse.statusCode == 401 {
                    completion(.failure(.unauthorized))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.invalidResponse))
                    return
                }

                // Se a resposta for apenas de sucesso (sem corpo), como em um POST
                if T.self == Void.self {
                    if let success = () as? T {
                         completion(.success(success))
                    }
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let decodedData = try decoder.decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        task.resume()
    }

    // MARK: - Endpoints Específicos
    
    func addEmotion(emotion: EmotionModel, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        postRequest(path: "/emotions", body: emotion, completion: completion)
    }
    
    func getAllEmotions(completion: @escaping (Result<[EmotionModel], NetworkError>) -> Void) {
        getRequest(path: "/emotions", completion: completion)
    }

    func addRiskAssessment(risk: RiskAssessmentModel, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        postRequest(path: "/risks", body: risk, completion: completion)
    }
}
