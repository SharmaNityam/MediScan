import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { genkit } from 'genkit';
import { gemini20FlashExp, googleAI } from '@genkit-ai/googleai';
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
  model: gemini20FlashExp,
});

const analyzeMedicalReport = ai.defineFlow('analyzeMedicalReport', async (input) => {
  try {
    if (!input.text) {
      throw new Error("No valid input provided");
    }

    const prompt = `Analyze this medical report text: ${input.text}. Extract the following details in JSON format:
- patient_details: { name, age, gender }
- report_content: { date, chief_complaint, diagnosis, past_medical_history, vital_signs: { blood_pressure, heart_rate }, tests: string[], treatment_plan: { medications: string[], lifestyle_modifications: boolean }, follow_up: string }
- doctor_details: { name, age }

Respond only with valid JSON. Do not include any additional commentary or explanation. If any field is missing or unknown, set its value to null.`;

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

    // Validate the parsed response
    if (!parsedResponse.patient_details || !parsedResponse.report_content || !parsedResponse.doctor_details) {
      throw new Error("Invalid JSON structure in AI response.");
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

const analyzeMedicalImage = ai.defineFlow('analyzeMedicalImage', async (input) => {
  try {
    if (!input.imageUrl) {
      throw new Error("No valid input provided");
    }

    const prompt = `Analyze this medical image: ${input.imageUrl}. Extract the following details in JSON format:
- patient_details: { name, age, gender }
- report_content: { date, chief_complaint, diagnosis, past_medical_history, vital_signs: { blood_pressure, heart_rate }, tests: string[], treatment_plan: { medications: string[], lifestyle_modifications: boolean }, follow_up: string }
- doctor_details: { name, age }

Respond only with valid JSON. Do not include any additional commentary or explanation. If any field is missing or unknown, set its value to null.`;

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

    if (!parsedResponse.patient_details || !parsedResponse.report_content || !parsedResponse.doctor_details) {
      throw new Error("Invalid JSON structure in AI response.");
    }

    return parsedResponse;
  } catch (error) {
    console.error(" AI Processing Error:", error);
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

exports.analyzeImageReportHttp = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Received Image URL:", req.body.imageUrl);

    if (!req.body.imageUrl) {
      res.status(400).json({ error: 'No image URL provided' });
      return;
    }

    const analysis = await analyzeMedicalImage({ imageUrl: req.body.imageUrl });

    console.log("Image Analysis Success:", analysis);
    res.json(analysis);
  } catch (error) {
    console.error("Error in analyzeImageReportHttp:", error);
    res.status(500).json({ error: "Internal Server Error", details: error });
  }
});
