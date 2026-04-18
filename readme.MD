# AgriSense

AgriSense is a full-stack agri-intelligence platform with:

- a Python AI backend for crop disease diagnosis, intelligence reports, and voice/chat workflows
- a Flutter mobile app for farmers and lenders
- a Next.js web dashboard for farm operations and management workflows

The repository contains multiple stacks under one workspace, while the Python backend lives in Model/online.

## 1) High-Level Architecture

AgriSense is split into three major layers:

- AI + API Layer (Python/FastAPI): image inference, severity estimation, remediation guidance, STT/TTS, chatbot context
- Mobile Experience (Flutter): role-aware agricultural workflow for field users
- Web Experience (Next.js): dashboard-style management interface and web modules

Core backend entry points:

- Model/online/main.py
- Model/online/model_loader.py
- Model/online/intelligence_engine.py

Core frontend roots:

- App/frontend/lib
- Frontend/Website Dev/src

## 2) Model Stack (Two Models)

### Model A: Online PyTorch Inference (Primary Runtime)

- Framework: PyTorch
- Backbone: MobileNetV2
- Weights file: Model/online/mobilenetv2_plant.pth
- Loader/inference: Model/online/model_loader.py
- Classes supported: 38 PlantVillage classes
- Current API integration: fully integrated with FastAPI /predict flow

What this model powers today:

- disease class prediction
- confidence score and top-k results
- downstream intelligence report generation (severity, action plan, economics, weather-aware suggestions)

### Model B: Keras Quantized Variant (~21 MB)

- Framework: TensorFlow/Keras (quantized lightweight variant)
- Intended use: smaller footprint deployments (edge-friendly usage pattern)
- Training and Keras pipeline references: Model/offline/Fine_tuned_model.py

Notes:

- The primary production API flow in this repo is currently wired to the PyTorch MobileNetV2 runtime.
- The Keras quantized model path is documented and can be used for lightweight deployment profiles.

## 3) Where Project Files Belong

Because this repository contains Flutter, Next.js, and Python together, Python project metadata should be scoped to the Python backend directory.

Recommended location:

- pyproject.toml in Model/online
- .python-version in Model/online

This keeps backend dependency and Python runtime tooling isolated from non-Python stacks.

## 4) Switching Between Both Models

There are two practical switching modes:

1. Deployment-level switch (recommended now)
- Run current FastAPI service with Model A (PyTorch MobileNetV2) for full API functionality.
- Run Keras quantized inference path as a lightweight alternative profile where required.

2. Runtime switch through a common adapter (recommended next improvement)
- Add a model abstraction layer with a single predict interface.
- Route to either:
	- PyTorch loader (existing model_loader.py)
	- Keras quantized loader (new adapter for quantized model artifact)
- Control selection via environment variable, for example MODEL_BACKEND=pytorch or MODEL_BACKEND=keras.

Current status in this repository:

- PyTorch path is implemented end-to-end in FastAPI.
- Keras path is available as model/training/inference workflow material and can be plugged into the API adapter.

## 5) Backend Features (Python + FastAPI)

Implemented capabilities include:

- health and service introspection endpoints
- leaf image disease prediction from file or base64
- top-k confidence predictions
- intelligence post-processing with dynamic severity logic
- economic impact estimation (yield and loss)
- chatbot response pipeline with session memory
- voice pipelines:
	- speech-to-text
	- text-to-speech
	- speech -> chatbot -> speech roundtrip

Important API routes are defined in Model/online/main.py:

- GET /api/v1/health
- GET /api/v1/endpoints
- POST /api/v1/predict
- POST /api/v1/chatbot/reply
- POST /api/v1/voice/stt
- POST /api/v1/voice/tts
- POST /api/v1/voice/pipeline
- POST /api/v1/voice/chatbot-pipeline
- GET /api/v1/voice/download/{filename}

## 6) Flutter App Features (Mobile)

The mobile app includes a broad agri-feature set organized under App/frontend/lib/features.

Major feature modules present:

- authentication (login/signup)
- home and role-aware shells
- scan workflows
- disease detection and disease result reporting
- pest detection result flow
- disease risk insights
- soil module
- crop module
- weather module
- yield module
- market module
- schemes eligibility and schemes list
- community feed/thread/post flows
- IoT module
- satellite module
- voice module
- tools and utilities

Navigation and role behavior are managed in:

- App/frontend/lib/core/router/app_router.dart

Role-aware routing supports differentiated experiences for:

- farmer
- lender

## 7) Web Dashboard Features (Next.js)

The web app is in Frontend/Website Dev and includes dashboard-focused UX under src/app.

Dashboard scope includes:

- farm overview cards (plots, crops, area, plants)
- task completion and pending snapshot
- weather summary card
- soil health panel with nutrient indicators
- farm performance visualization
- task/activity cards
- map-side panel visual space
- theme toggle (light/dark)

Dashboard implementation:

- Frontend/Website Dev/src/app/Dashboard/page.tsx

Additional web app routes/modules include:

- login
- signup
- profile
- users
- verify email
- API route area

## 8) Repository Structure (Important Paths)

- Model/online: active backend service and online inference stack
- Model/offline: training and alternate model experimentation workflows
- App/frontend: Flutter mobile application
- Frontend/Website Dev: Next.js web platform

## 9) Running the Backend (Typical)

From Model/online:

1. install dependencies from root requirements.txt
2. configure .env values for optional providers (for example Sarvam/Gemini integrations)
3. start FastAPI app via uvicorn using main:app

The backend warms up model and intelligence components during startup.

## 10) What Makes This Project Different

AgriSense combines:

- AI disease prediction
- agronomic actionability (not only labels)
- economic reasoning
- weather-aware and context-aware guidance
- multilingual voice-enabled interaction
- both mobile and web operational experiences

This design enables both field-level usage (app) and management-level visibility (dashboard).


