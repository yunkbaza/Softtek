// functions/src/index.ts
import * as functions from 'firebase-functions';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { z } from 'zod';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

initializeApp();
const db = getFirestore();

const APP_ORIGINS = [
  /^https:\/\/(.*\.)?seu-dominio\.com$/,
  'http://localhost:5173',
  'http://localhost:3000',
];

const API_KEY = process.env.API_KEY;

// ---------- App ----------
const app = express();
app.disable('x-powered-by');
app.use(helmet());
app.use(cors({ origin: APP_ORIGINS, credentials: false }));
app.use(express.json({ limit: '100kb' }));

// API Key simples
app.use((req, res, next) => {
  const key = req.header('x-api-key');
  if (!API_KEY || key !== API_KEY) return res.status(401).json({ error: 'unauthorized' });
  next();
});

// Rate limit básico
app.use(
  rateLimit({
    windowMs: 60_000,
    max: 60,
    standardHeaders: true,
  }),
);

// ---------- Utils ----------
const logEvent = async (sessionId: string, action: string, meta: Record<string, any> = {}) => {
  await db.collection('events').add({
    sessionId,
    action,
    meta,
    createdAt: FieldValue.serverTimestamp(),
  });
};

const severityFromScore = (score: number) => {
  if (score <= 24) return 'neutral';
  if (score <= 49) return 'mild';
  if (score <= 74) return 'moderate';
  return 'severe';
};

// ---------- Schemas ----------
const SessionId = z.string().min(8).max(128);

const AssessmentSchema = z.object({
  sessionId: SessionId,
  type: z.enum(['anxiety', 'depression', 'burnout']),
  score: z.number().int().min(0).max(100),
  answers: z.record(z.unknown()).optional(),
});

const MoodCheckinSchema = z.object({
  sessionId: SessionId,
  mood: z.enum(['very_bad', 'bad', 'neutral', 'good', 'very_good']),
  notes: z.string().max(500).optional(),
});

const SupportResourceSchema = z.object({
  category: z.enum(['therapy', 'group', 'wellbeing', 'education']),
  title: z.string().min(2).max(100),
  url: z.string().url(),
});

// ---------- Health ----------
app.get('/health', (_req, res) => res.json({ ok: true }));

// ---------- Assessments ----------
app.post('/assessments', async (req, res) => {
  try {
    const parsed = AssessmentSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ error: 'invalid_payload', details: parsed.error.flatten() });
    }
    const { sessionId, type, score, answers } = parsed.data;

    const doc = await db.collection('assessments').add({
      sessionId,
      type,
      score,
      severity: severityFromScore(score),
      answers: answers ?? {},
      createdAt: FieldValue.serverTimestamp(),
    });

    await logEvent(sessionId, 'assessment_submitted', { id: doc.id, type, score });
    return res.status(201).json({ id: doc.id });
  } catch (err) {
    console.error('[assessments] error', err);
    return res.status(500).json({ error: 'internal_error' });
  }
});

// ---------- Mood Check-ins ----------
app.post('/mood-checkins', async (req, res) => {
  try {
    const parsed = MoodCheckinSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ error: 'invalid_payload', details: parsed.error.flatten() });
    }
    const { sessionId, mood, notes } = parsed.data;

    const doc = await db.collection('mood_checkins').add({
      sessionId,
      mood,
      notes: notes ?? '',
      createdAt: FieldValue.serverTimestamp(),
    });

    await logEvent(sessionId, 'mood_checkin_submitted', { id: doc.id, mood });
    return res.status(201).json({ id: doc.id });
  } catch (err) {
    console.error('[mood-checkins] error', err);
    return res.status(500).json({ error: 'internal_error' });
  }
});

// ---------- Histórico ----------
app.get('/history/:sessionId', async (req, res) => {
  try {
    const sessionId = req.params.sessionId;
    if (!SessionId.safeParse(sessionId).success) {
      return res.status(400).json({ error: 'invalid_session' });
    }

    const [assessSnap, moodSnap] = await Promise.all([
      db
        .collection('assessments')
        .where('sessionId', '==', sessionId)
        .orderBy('createdAt', 'desc')
        .limit(200)
        .get(),
      db
        .collection('mood_checkins')
        .where('sessionId', '==', sessionId)
        .orderBy('createdAt', 'desc')
        .limit(200)
        .get(),
    ]);

    const assessments = assessSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
    const mood = moodSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

    await logEvent(sessionId, 'history_fetched', { assessments: assessments.length, mood: mood.length });
    return res.json({ assessments, mood });
  } catch (err) {
    console.error('[history] error', err);
    return res.status(500).json({ error: 'internal_error' });
  }
});

// ---------- Recursos de Apoio ----------
app.get('/support/resources', async (_req, res) => {
  try {
    const snap = await db.collection('support_resources').orderBy('title').limit(200).get();
    const items = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    return res.json({ items });
  } catch (err) {
    console.error('[resources:list] error', err);
    return res.status(500).json({ error: 'internal_error' });
  }
});

app.post('/support/resources', async (req, res) => {
  try {
    const parsed = SupportResourceSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json({ error: 'invalid_payload', details: parsed.error.flatten() });
    }
    const doc = await db.collection('support_resources').add({
      ...parsed.data,
      createdAt: FieldValue.serverTimestamp(),
    });
    return res.status(201).json({ id: doc.id });
  } catch (err) {
    console.error('[resources:create] error', err);
    return res.status(500).json({ error: 'internal_error' });
  }
});

// ---------- Export ----------
export const api = functions.https.onRequest(app);
