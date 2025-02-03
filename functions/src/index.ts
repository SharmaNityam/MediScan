import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { genkit } from 'genkit';
import { gemini15Flash, googleAI } from '@genkit-ai/googleai';
import { enableFirebaseTelemetry } from '@genkit-ai/firebase';

enableFirebaseTelemetry();
admin.initializeApp();

const GOOGLE_API_KEY = functions.config().googleai.apikey;
if (!GOOGLE_API_KEY) {
  throw new Error(
    "GOOGLE_API_KEY is missing! Set it with 'firebase functions:config:set googleai.apikey=YOUR_GEMINI_API_KEY'"
  );
}

const ai = genkit({
  plugins: [googleAI({ apiKey: GOOGLE_API_KEY })],
  model: gemini15Flash,
});

const analyzeMedicalReport = ai.defineFlow('analyzeMedicalReport', async (input) => {
  try {
    if (!input.text) {
      throw new Error("No valid input provided");
    }

    const prompt = `Analyze this medical report text: ${input.text}. Extract patient details, report content, and doctor details in JSON format.
Respond only with valid JSON without any additional commentary or explanation.`;

    const { text } = await ai.generate(prompt);

    let parsedResponse: any;
    try {
      parsedResponse = JSON.parse(text);
    } catch (parseError) {
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        try {
          parsedResponse = JSON.parse(jsonMatch[0]);
        } catch (innerError) {
          console.error(" Inner JSON parsing error:", innerError);
          throw new Error("Failed to parse valid JSON from the AI response.");
        }
      } else {
        console.error(" No JSON block found in AI response.");
        throw new Error("No JSON block found in the AI response.");
      }
    }
    return parsedResponse;
  } catch (error) {
    console.error("AI Processing Error:", error);
    throw new functions.https.HttpsError('internal', 'AI processing failed', {
      message: error,
      stack: error,
    });
  }
});

exports.analyzeTextReportHttp = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Received Text:", req.body.text);

    if (!req.body.text) {
      res.status(400).json({ error: 'No text provided' });
      return;
    }

    const analysis = await analyzeMedicalReport({ text: req.body.text });

    console.log("Analysis Success:", analysis);
    res.json(analysis);
  } catch (error) {
    console.error("Error in analyzeTextReportHttp:", error);
    res.status(500).json({ error: "Internal Server Error", details: error });
  }
});

exports.analyzeTextReport = functions.firestore
  .document('texts/{docId}')
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      if (!data.text) return;

      console.log(" Firestore Trigger for Text:", data.text);
      const analysis = await analyzeMedicalReport({ text: data.text });

      await snap.ref.update({ analysis });

      console.log("Firestore Text Analysis Saved.");
    } catch (error) {
      console.error(" Error in Firestore Text Trigger:", error);
    }
  });
