import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from "express";
import * as cors from "cors";

// Inicializa o Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

const app = express();
app.use(cors({origin: true}));
app.use(express.json());

// --- [REQUISITO OBRIGATÓRIO: SEGURANÇA] ---
// Middleware de autenticação por API Key
const apiKeyMiddleware = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const apiKey = req.get("X-API-Key"); // O app deve enviar a chave neste cabeçalho
  
  // Defina sua chave de API secreta aqui. Pode ser qualquer string complexa.
  // O ideal é guardar isso nas configurações de ambiente do Firebase.
  const SECRET_API_KEY = "sua-chave-secreta-aqui-12345";

  if (apiKey && apiKey === SECRET_API_KEY) {
    // Chave válida, a requisição pode continuar
    next();
  } else {
    // Chave inválida ou ausente
    functions.logger.warn("Tentativa de acesso não autorizado", {ip: req.ip});
    res.status(401).send("Acesso não autorizado: Chave de API inválida ou ausente.");
  }
};

// Aplica o middleware de segurança em todas as rotas da API
app.use(apiKeyMiddleware);

// --- Endpoints da API ---

// Endpoint para registrar emoções (check-in de humor)
app.post("/emotions", async (req, res) => {
  try {
    const { emotion, userId, timestamp } = req.body;
    
    if (!emotion || !userId || !timestamp) {
      return res.status(400).send("Dados incompletos.");
    }

    const emotionData = { emotion, userId, timestamp: new Date(timestamp) };
    const docRef = await db.collection("emotions").add(emotionData);

    // --- [REQUISITO OBRIGATÓRIO: LOGS] ---
    functions.logger.info(`Nova emoção registrada com sucesso (ID: ${docRef.id})`, { data: emotionData });
    
    res.status(201).send({ id: docRef.id });
  } catch (error) {
    // --- [REQUISITO OBRIGATÓRIO: LOGS] ---
    functions.logger.error("Erro ao registrar emoção:", error);
    res.status(500).send("Erro interno ao registrar emoção.");
  }
});

// Endpoint para buscar todas as emoções
app.get("/emotions", async (req, res) => {
    try {
        const snapshot = await db.collection("emotions").orderBy("timestamp", "desc").get();
        const emotions: any[] = [];
        snapshot.forEach((doc) => {
            emotions.push({id: doc.id, ...doc.data()});
        });

        // --- [REQUISITO OBRIGATÓRIO: LOGS] ---
        functions.logger.info("Busca de histórico de emoções realizada.");

        res.status(200).json(emotions);
    } catch (error) {
        // --- [REQUISITO OBRIGATÓRIO: LOGS] ---
        functions.logger.error("Erro ao buscar emoções:", error);
        res.status(500).send("Erro interno ao buscar emoções.");
    }
});

// Endpoint para registrar avaliações de risco
app.post("/risks", async (req, res) => {
    try {
        const { question, answer, userId, timestamp } = req.body;

        if (!question || answer === undefined || !userId || !timestamp) {
            return res.status(400).send("Dados incompletos.");
        }

        const riskData = { question, answer, userId, timestamp: new Date(timestamp) };
        const docRef = await db.collection("riskAssessments").add(riskData);

        // --- [REQUISITO OBRIGATÓRIO: LOGS] ---
        functions.logger.info(`Nova avaliação de risco registrada (ID: ${docRef.id})`, { data: riskData });

        res.status(201).send({ id: docRef.id });
    } catch (error) {
        // --- [REQUISITO OBRIGATÓRIO: LOGS] ---
        functions.logger.error("Erro ao registrar avaliação de risco:", error);
        res.status(500).send("Erro interno ao registrar avaliação de risco.");
    }
});

// Adicione aqui outros endpoints (ex: /check-in) seguindo o mesmo padrão...

// Exporta a API como uma Cloud Function
export const api = functions.https.onRequest(app);
