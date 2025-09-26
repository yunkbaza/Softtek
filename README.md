# Projeto Completo — Challenge Softtek (Sprint 1 + Sprint 2)
Data: 2025-09-23

Este pacote reúne:
- **app-ios/** — App iOS (SwiftUI) da Sprint 1 (com SQLite e integrações)
- **backend-firebase/** — Backend Sprint 2 em Firebase (Firestore + Cloud Functions HTTPS)
- **docs/** — PDFs, Postman, materiais de apoio

## Como rodar o Backend (Firebase)
1) Instale as ferramentas:
   - `npm i -g firebase-tools`
   - `firebase login`
2) Edite `backend-firebase/.firebaserc` e coloque seu `YOUR_PROJECT_ID`.
3) Compile e faça deploy:
```bash
cd backend-firebase/functions
npm install
npm run build
cd ../..
firebase deploy --only functions,firestore:rules,firestore:indexes
```
4) Acesse a URL base:
```
https://us-central1-<seu-project-id>.cloudfunctions.net/api
```

## Como apontar o App para o Backend
- No Xcode, abra `app-ios/` e adicione (ou atualize) o arquivo `ios_additions/FirebaseIntegration.swift` (já incluso em `backend-firebase/ios_additions/`).
- Configure o Firebase no projeto iOS (GoogleService-Info.plist) e use **Auth anônimo**.
- Faça as chamadas REST para os endpoints da URL base acima.

## Testes
- Use o arquivo `docs/postman_collection_firebase.json` no Postman e troque `{baseUrl}`.
- Endpoints principais:
  - `POST /assessments` — {"sessionId","type","score","answers?"}
  - `GET /assessments/summary/:sessionId`
  - `POST /mood/checkin` — {"sessionId","mood","note?"}
  - `GET /mood/history/:sessionId`
  - `GET /support` | `POST /support`
  - `GET /history/:sessionId`

## Entrega na FIAP
- Compacte **app-ios/** (código do app) + gere **IPA/APK** do seu app.
- Compacte **backend-firebase/** (código do backend).
- Inclua a pasta **docs/** com PDF/PPT e Postman.
