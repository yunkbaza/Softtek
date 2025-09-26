// FirebaseIntegration.swift
import Foundation
import FirebaseCore
import FirebaseAuth

final class FirebaseSetup {
    static func configure() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        // Sign-in anônimo
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error { print("Auth anon error:", error) }
            }
        }
    }
}

// REST client para chamar a Function HTTPS
struct API {
    static var base: URL { URL(string: "https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/api")! }
}

enum APIError: Error { case badResponse }

final class RestClient {
    static let shared = RestClient()
    private init() {}

    func post(path: String, json: [String: Any]) async throws -> Data {
        let url = API.base.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: json)
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200...299 ~= http.statusCode else { throw APIError.badResponse }
        return data
    }

    func get(path: String) async throws -> Data {
        let url = API.base.appendingPathComponent(path)
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, 200...299 ~= http.statusCode else { throw APIError.badResponse }
        return data
    }
}

// Exemplo de uso no app:
@MainActor
func enviarCheckin(sessionId: String, mood: String, note: String?) async {
    do {
        let body: [String: Any] = ["sessionId": sessionId, "mood": mood, "note": note ?? ""]
        _ = try await RestClient.shared.post(path: "/mood/checkin", json: body)
    } catch { print("Falha ao enviar check-in:", error) }
}
