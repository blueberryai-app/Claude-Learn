# [Claude Learn]([https://github.com/jamesrochabrun/SwiftAnthropic](http://claudelearn.com))  
### A human-centered study companion powered by the Claude API
_By Daniel Matar_



<img width="798" height="433" alt="Screenshot 2025-11-10 at 10 34 36 AM" src="https://github.com/user-attachments/assets/980b72d8-9dad-4c2e-b31b-91eaae0486b4" />


Claude Learn reimagines how people learn with AI.  
Instead of removing friction, it helps learners work *through* it — turning challenges into growth moments.  
Designed for Anthropic’s **Education Labs Take-Home Assignment (Option B)**.

---

## Overview
Most AI tools give quick answers. Claude Learn builds understanding.  
It’s a personalized study tutor that supports learners at any age through dialogue, reflection, and structure.

> “Claude Learn is designed to work alongside you, not for you.”

---

## Core Features

### Play — Chat Modes
Learn through interactive dialogue: debate, quiz, or role-play with Claude.  
Modes include *Debate Me*, *Mimic*, *Quiz Me*, and *Learning Lens*.

- **Debate Me**: Engage in constructive debates to deepen understanding
- **Mimic Mode**: Chat with custom characters or personalities to make learning fun
- **Quiz Me**: Test knowledge with multiple-choice and open-ended questions
- **Learning Lenses:** Apply thematic lenses to make learning more relatable and engaging

### Structure — Timeboxing
Set focused study sessions (15–120 mins). 
Claude manages pacing, breaks, and goals to keep learning sustainable, and offer breaks.

### Emotion — Frustration Button
- Signal when you're struggling, and Claude adapts its teaching approach

### Additional Features
- **Chat History**: Access and resume previous learning sessions
- **Streaming Responses**: Real-time AI responses for natural conversation flow
- **Quiz Analytics**: Track performance with detailed feedback and improvement plans

---

## Technical Architecture

### Core Stack
- **Platform**: Native iOS 15+ with SwiftUI
- **Language**: Swift 5.9+
- **AI Provider**: Anthropic Claude API (Sonnet 4.5)
- **SDK**: [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic) for type-safe API integration

### Architecture & Design Patterns

**MVVM (Model-View-ViewModel)**
- Clean separation of concerns with reactive state management
- `@StateObject` and `@ObservedObject` for unidirectional data flow
- View models handle business logic and API orchestration
- Models are pure Swift structs conforming to `Codable` for serialization

**Service Layer**
- `AnthropicService`: Manages streaming responses and API communication
- `PromptManager`: Centralized prompt engineering with mode-specific system instructions
- `StorageService`: Local persistence layer with atomic writes and data integrity checks
- `APIConfiguration`: Secure credential management and model configuration

### Front-End Implementation

**SwiftUI Components**
- Fully declarative UI with no UIKit dependencies
- Custom markdown rendering for formatted AI responses
- Real-time streaming message display with typing indicators
- Adaptive layouts supporting iPhone and iPad (portrait/landscape)

**State Management**
- Reactive architecture using Combine framework
- `@Published` properties for automatic UI updates
- Debounced input handling for optimal performance

### AI Integration

**Streaming Architecture**
- Server-Sent Events (SSE) for real-time response streaming
- Incremental message rendering with sub-second latency
- Graceful error handling and automatic retry logic
- Token-efficient context management (maintains conversation history without redundancy)

**Prompt Engineering**
- Dynamic system prompts tailored to each learning mode
- Context-aware adaptations based on user frustration signals
- Session timer integration for pacing recommendations
- Quiz mode with structured JSON response parsing

### Data Persistence

**Local-First Architecture**
- `UserDefaults` for lightweight session and settings storage
- `Codable` protocol for type-safe serialization
- Automatic chat history persistence across app launches
- Configurable data retention policies

**Data Models**
- `ChatSession`: Conversation threads with metadata (mode, timestamp, message count)
- `ChatMessage`: Individual messages with role-based typing and streaming state
- `QuizModels`: Structured quiz questions, answers, and analytics
- `SessionTimer`: Time-boxed learning sessions with break management

### Security & Configuration
- Secure API key storage with in-app configuration
- No telemetry or external analytics (privacy-first design)
- Client-side only processing (no intermediate servers)

---

## Project Structure

```swift
Blueberry Learn/
├── Models/                        # Data layer (Codable structs)
│   ├── ChatMessage.swift          # Message data with streaming support
│   ├── ChatSession.swift          # Session metadata and persistence
│   ├── LearningMode.swift         # Mode/lens enumerations and properties
│   ├── QuizModels.swift           # Quiz questions, answers, analytics
│   └── SessionTimer.swift         # Timer state and logic
├── Views/                         # SwiftUI presentation layer
│   ├── MainView.swift             # Session list and navigation
│   ├── ChatView.swift             # Real-time chat interface
│   ├── ModeSelectionSheet.swift   # Mode picker with descriptions
│   ├── SettingsView.swift         # API configuration
│   └── Quiz*.swift                # Quiz UI components
├── ViewModels/                    # Business logic and state
│   ├── ChatViewModel.swift        # Chat orchestration, API calls, message handling
│   └── MainViewModel.swift        # Session management
├── Services/                      # Infrastructure layer
│   ├── AnthropicService.swift     # Claude API client wrapper
│   ├── APIConfiguration.swift     # Credentials and model settings
│   ├── PromptManager.swift        # System prompt templates
│   └── StorageService.swift       # Persistence utilities
└── Theme/
    └── Colors.swift               # Design tokens and color palette
```

---

© 2025 Daniel Matar · Built for Anthropic Education Labs
