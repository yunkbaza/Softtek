import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection!
    
    // Tabela das emoções
    private var emotionsTable: Table!
    
    // Colunas da tabela
    private var id: SQLite.Expression<Int64>!
    private var emotionColumn: SQLite.Expression<String>!
    private var timestampColumn: SQLite.Expression<String>!

    private init() {
        do {
            let fileUrl = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("SofttekApp.sqlite")
            
            db = try Connection(fileUrl.path)

            // Definir a tabela
            emotionsTable = Table("emotions")
            id = SQLite.Expression<Int64>("id") // << Corrigido AQUI
            emotionColumn = SQLite.Expression<String>("emotion") // << Corrigido AQUI
            timestampColumn = SQLite.Expression<String>("timestamp") // << Corrigido AQUI
            
            try db.run(emotionsTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(emotionColumn)
                t.column(timestampColumn)
            })
        } catch {
            print("Erro ao configurar o banco de dados: \(error)")
        }
    }
    
    func addEmotion(_ emotion: String) {
        let formatter = ISO8601DateFormatter()
        let timestampString = formatter.string(from: Date())
        
        let insert = emotionsTable.insert(
            self.emotionColumn <- emotion,
            self.timestampColumn <- timestampString
        )
        
        do {
            try db.run(insert)
            print("Emoção registrada: \(emotion)")
        } catch {
            print("Erro ao registrar emoção: \(error)")
        }
    }
    
    func getAllEmotions() -> [Emotion] {
        var emotions = [Emotion]()
        do {
            for row in try db.prepare(emotionsTable) {
                let emotionID = row[id] // Int64
                let emotionText = row[emotionColumn] // String
                let timestampText = row[timestampColumn] // String
                
                // Converte o timestampText para Date
                let formatter = ISO8601DateFormatter()
                let timestampDate = formatter.date(from: timestampText) ?? Date()
                
                let emotion = Emotion(
                    id: emotionID,
                    emotion: emotionText,
                    timestamp: timestampDate
                )
                emotions.append(emotion)
            }
        } catch {
            print("Erro ao carregar emoções: \(error)")
        }
        return emotions
    }
}
