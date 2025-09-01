## AI in the Development Process

Beyond the user-facing features, AI (especially GitHub Copilot and ChatGPT) acted like a pair programmer throughout Mediscan’s development. It helped me move faster, reduce repetitive work, and debug tricky issues that would have otherwise slowed me down.

### 1. Scaffolding and Boilerplate Reduction

One of the biggest productivity boosts was avoiding repetitive boilerplate.  

For example, when I needed a reusable card layout, instead of manually writing out the whole widget structure, I prompted Copilot:  

> "Create a stateless Flutter widget called AnalysisCard that takes a title and a child widget. It should have a Card layout with some padding and elevation."  

That gave me a working `AnalysisCard` widget in seconds. Normally I’d spend 10–15 minutes setting up the same code. It meant I could focus more on app logic instead of copy-pasting standard Flutter patterns.

### 2. Data Model Generation

While building the backend integration, I had to create several Dart models (`MedicalReport`, `PatientDetails`, `ReportContent`, etc.) for a fairly nested JSON response coming from a GenKit function.  

Instead of writing all the constructors and `fromJson` methods by hand, I pasted the JSON into Copilot and asked:  

> "Generate Dart classes with fromJson factory constructors for the following JSON structure:"  

In seconds, it generated all the model classes with proper parsing logic. That saved me easily half an hour of typing and avoided the small mistakes that creep in with manual JSON mapping.

### 3. Unit Test Generation

I also leaned on AI for writing tests. For example, I needed to test my `analyzeMedicalReport` GenKit flow in `functions/src/index.ts`. Rather than starting from scratch, I asked Copilot:  

> "Generate a unit test for the 'analyzeMedicalReport' GenKit flow using Jest. Mock the 'ai.generate' call to return a predefined JSON string and assert that the flow's output is the correctly parsed object."  

It gave me a complete test file structure with mocks and assertions. I still had to tweak it, but having a solid starting point made writing tests much faster and less intimidating.

### 4. Code Explanation and Refactoring

Sometimes, coming back to a file after a break, I’d feel lost in a big widget tree. In `report_analysis_screen.dart`, I highlighted the `FutureBuilder` and asked ChatGPT to explain how it worked and what each connection state meant. That quick refresher helped me get back into flow instantly.  

AI also spotted patterns I was missing. For instance, it suggested breaking down a large, repetitive widget into the smaller, reusable `AnalysisCard`. That refactor made the UI code cleaner, more modular, and easier to maintain.

### 5. Debugging Assistance

When I ran into a type mismatch bug in my `fromJson` constructor, the app kept crashing. I copied both the Dart code and the sample JSON into ChatGPT and asked what was wrong.  

It immediately pointed out that one field expected a `List<String>` but was sometimes `null` in the JSON. The suggestion was simple: add a null check with a default value (`?? []`). That fixed the crash instantly and saved me from wasting more time manually

## Project Overview video- https://youtu.be/K4jX4xdmF5c
