# Claude Learn  
### A human-centered study companion powered by the Claude API



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

## Tech Stack

- **Platform**: iOS (SwiftUI)
- **AI Integration**: Anthropic Claude API via [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Storage**: Local persistence using UserDefaults and Codable
- **Language**: Swift

## Project Structure (simplified)

```
Blueberry Learn/
├── Models/
│   ├── ChatMessage.swift          # Chat message data model
│   ├── ChatSession.swift          # Chat session management
│   ├── LearningMode.swift         # Learning modes and lenses
│   ├── QuizModels.swift           # Quiz-related data structures
│   └── SessionTimer.swift         # Session timer logic
├── Views/
│   ├── MainView.swift             # Main screen with chat history
│   ├── ChatView.swift             # Chat interface
│   ├── ModeSelectionSheet.swift   # Mode and lens selection
│   ├── SettingsView.swift         # Settings and API key config
│   └── Quiz*.swift                # Quiz-related views
├── ViewModels/
│   ├── ChatViewModel.swift        # Chat logic and state management
│   └── MainViewModel.swift        # Main screen logic
├── Services/
│   ├── AnthropicService.swift     # Claude API integration
│   ├── APIConfiguration.swift     # API key and model configuration
│   ├── PromptManager.swift        # System prompts and instructions
│   └── StorageService.swift       # Local data persistence
└── Theme/
    └── Colors.swift               # App color scheme
```

---

© 2025 Daniel Matar · Built for Anthropic Education Labs
