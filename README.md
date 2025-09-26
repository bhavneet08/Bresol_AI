# 🤖 Bresol AI – AI Chatbot App

**Bresol AI** is a cross-platform AI chatbot application built with **Flutter**.  
It integrates **Google’s Gemini 2.0 Flash Lite** model, **Firebase Google Authentication**, and a **MySQL backend** for managing chat history and user data.

With smooth animations and a modern interface, **Bresol AI** offers a **fast, intelligent, and secure** chat experience.

---

## 🧠 Backend Repository

The Node.js backend for Bresol AI is available here:  
👉 [Bresol-AI-Backend](https://github.com/bhavneet08/Bresol_AI/tree/main/bresol_ai_server) 

---

## ✨ Features

- 🔐 **Firebase Google Auth** – Secure sign-in with Google accounts  
- 🧠 **Gemini 2.0 Flash Lite** – Fast and high-quality AI chatbot responses  
- 💾 **MySQL Database** – Persistent storage of chat history & user data  
- 💬 **Chat History** – View and manage past conversations  
- 🎨 **Flutter Animations** – Modern, smooth, and interactive UI/UX  
- 📱 **Cross-Platform** – Works seamlessly on Android, iOS, macOS, Windows, and Linux  

---

## 🛠️ Tech Stack

| Layer         | Technology                          |
|--------------|------------------------------------|
| **Frontend** | Flutter (Dart)                      |
| **Backend**  | Node.js + Express (REST API)       |
| **Database** | MySQL                               |
| **Auth**     | Firebase Google Authentication     |
| **AI Model** | Google Gemini 2.0 Flash Lite (via API) |

---

## 🚀 Getting Started

### 1. Prerequisites

Make sure you have the following installed:

- Flutter SDK (latest stable version)
- Node.js & npm
- MySQL server
- Firebase project (for Google Auth)
- Gemini API key

---

### 2. Clone the Repository                                       ```bash
            git clone https://github.com/bhavneet08/Bresol_AI.git
            cd Bresol_AI



### 3. Install Flutter Dependencies

Once you have cloned the project, install all Flutter dependencies:
         ```bash

            flutter pub get
        
### 4. Backend Setup

To connect your backend and database:

1. Configure a new MySQL database (e.g., bresol_ai).
2. Set up your backend with a .env file containing the following variables:
         ```env

            DB_HOST=localhost
            DB_USER=root
            DB_PASS=yourpassword
            DB_NAME=bresol_ai
            GEMINI_API_KEY=your_api_key
3. Install backend dependencies and start the server:
    ```bash
                  npm install
                  npm run start

### 5. Firebase Setup

To enable Google Sign-In authentication:
1. Create a Firebase project from the [Firebase Console](https://console.firebase.google.com/) 

2. Enable Google Authentication under the Authentication tab.
3. Download the configuration files:
   
    *   google-services.json for Android
    *   GoogleService-Info.plist for iOS
5. Place them into the respective platform directories:
   
   *   android/app/ for Android
   *   ios/Runner/ for iOS

### 6. Run the App                                                        ```bash
                flutter run

This will start the Bresol AI chatbot on your emulator or connected device.



🧠 AI Model Information

Bresol AI uses Gemini 2.0 Flash Lite, Google’s lightweight, real-time multimodal model designed for conversational AI applications.
This model provides low latency, fast inference, and high-quality responses, making it ideal for interactive chatbot apps.

Below is the code snippet for model initialization:              ```dart
         
      _model = GenerativeModel(
      model: "gemini-2.0-flash-lite",
      apiKey: apiKey,
      );
