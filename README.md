# MediScan - Medical Report Analysis App

MediScan is a Flutter-based mobile application designed to analyze medical reports using Firebase GenKit and Google's Gemini API. The app allows users to upload medical reports either as text or images, and it provides detailed analysis and follow-up question capabilities.

## Features
- **Text Analysis**: Upload medical report text and get a detailed analysis.
- **Image Analysis**: Upload medical report images and extract text for analysis.
- **Follow-up Questions**: Ask follow-up questions based on the analysis context.
- **Firebase Integration**: Secure and scalable backend using Firebase Firestore, Storage, and Authentication.
- **AI-Powered Insights**: Utilizes Google's Gemini API via Firebase GenKit for accurate medical report analysis.

## Installation

### Prerequisites
- Flutter SDK installed
- Firebase project set up
- Google AI Studio account for Gemini API key

### Steps

#### Clone the Repository
```bash
git clone https://github.com/yourusername/mediscan.git
cd mediscan
```

#### Install Dependencies
```bash
flutter pub get
```

#### Set Up Firebase
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Add your Android and iOS apps to the Firebase project.
3. Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files and place them in the appropriate directories.
4. Enable Firebase Authentication (Anonymous sign-in), Firestore, and Storage.

#### Set Up Firebase GenKit
Navigate to the functions directory:
```bash
cd functions
```
Install dependencies:
```bash
npm install
```
Set your Gemini API key from Google AI Studio in Firebase Functions config:
```bash
firebase functions:config:set googleai.apikey=YOUR_GEMINI_API_KEY
```
Deploy Firebase Functions:
```bash
firebase deploy --only functions
```

#### Run the App
```bash
flutter run
```

## Usage

### Upload Medical Report
1. Enter the medical report text in the provided text field or upload an image of the report.
2. Click on **"Analyze Report"** or **"Analyze Image"** to start the analysis.

### View Analysis
- The analysis result will be displayed in a structured JSON format.
- You can copy the analysis to the clipboard using the copy icon.

### Ask Follow-up Questions
1. Enter your follow-up question in the provided text field.
2. Click on **"Ask Question"** to get a detailed answer based on the analysis context.

## Project Structure
```
lib/
  screens/
    home_screen.dart    # Main screen with upload and analysis sections
  services/
    text_analysis_service.dart   # Service for text analysis
    image_analysis_service.dart  # Service for image analysis
  widgets/
    analysis_card.dart     # Widget to display analysis results
    upload_section.dart    # Widget for uploading text and images
    follow_up_section.dart # Widget for asking follow-up questions
  utils/
    response_formatter.dart # Utility for formatting JSON responses
  constants.dart   # App constants and configurations
  main.dart        # Main entry point of the app
functions/
  index.ts  # Firebase Functions for text and image analysis using Firebase GenKit and Gemini API
```

## Dependencies
- **Flutter**: UI framework for building the app.
- **Firebase**: Backend services including Firestore, Storage, and Authentication.
- **Firebase GenKit**: Integration with Google's Gemini API for AI-powered analysis.
- **Image Picker**: For selecting images from the gallery.
- **HTTP**: For making API requests to Firebase Functions.

## Contributing
Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments
- **Google** for the Gemini API and Firebase services.
- **Flutter community** for the extensive documentation and support.

## Contact
For any queries or support, please contact *sharmanityam03@gmail.com**.

> **Note**: This project is for educational purposes and should not be used for actual medical diagnosis without professional consultation.

