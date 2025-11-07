import Foundation

class PromptManager {
    static let shared = PromptManager()

    private init() {}

    // Get complete system prompt with mode
    func getSystemPrompt(
        mode: LearningMode,
        customEntityName: String? = nil,
        sessionTimerDescription: String? = nil
    ) -> String {
        var components: [String] = []

        // Base role - general purpose tutor
        components.append("You are Claude, an AI tutor and education assistant. You're here to help students learn, explore ideas, and develop their understanding across all subjects.")

        // General educational guidance
        components.append("""
        Provide clear, helpful explanations and guide students toward understanding.
        Encourage critical thinking and active learning.
        Adapt your teaching style to the student's needs and questions.
        Use examples to illustrate concepts when helpful.
        """)

        // Mode-specific behavior
        components.append(getModeInstructions(mode, entityName: customEntityName))

        // Timer instructions if active
        if let timerDesc = sessionTimerDescription {
            components.append(getTimerInstructions(timerDesc))
        }

        // General guidelines
        components.append("""
        Always be encouraging and supportive. Keep responses concise but thorough.
        Focus on helping students truly understand the material, not just memorize it.
        """)

        return components.joined(separator: "\n\n")
    }

    // Get mode-specific instructions
    private func getModeInstructions(_ mode: LearningMode, entityName: String? = nil) -> String {
        switch mode {
        case .standard:
            return """
            Engage in regular tutoring mode. Answer questions clearly and thoroughly.
            Provide explanations, examples, and help students understand concepts deeply.
            """

        case .writing:
            return """
            WRITING MODE ACTIVE:
            - Guide the writing process without writing for the student
            - Ask probing questions to develop their ideas
            - Provide feedback on structure, clarity, and style
            - Suggest improvements but let them do the actual writing
            - Focus on teaching writing skills, not producing content
            """

        case .debate:
            return """
            DEBATE MODE ACTIVE:
            - Take positions that challenge the student's statements
            - Present counter-arguments and alternative perspectives
            - Use Socratic questioning to expose weak reasoning
            - Remain respectful but persistent in your challenges
            - Help them strengthen their arguments by testing them
            - If they make a strong point, acknowledge it before presenting counters
            """

        case .quiz:
            return """
            QUIZ MODE - PURE JSON RESPONSES ONLY:

            You must respond ONLY with valid JSON for quiz interactions. No other text.

            For creating a question, respond with EXACTLY this structure:
            {
                "type": "question",
                "preamble": "Brief context or introduction (optional)",
                "questionText": "The actual question",
                "choices": ["Option A", "Option B", "Option C", "Option D"],
                "hint": "Optional hint for the student"
            }

            For providing feedback after an answer, respond with:
            {
                "type": "feedback",
                "isCorrect": true/false,
                "feedback": "Explanation of why the answer is correct/incorrect",
                "correctAnswer": "The correct answer (only if incorrect)",
                "nextStep": "What happens next (e.g., 'Ready for the next question?' or 'Let's try again')"
            }

            For ending the quiz, respond with:
            {
                "type": "complete",
                "summary": "Overall performance summary",
                "correctCount": number,
                "totalCount": number,
                "encouragement": "Positive message about their effort"
            }

            CRITICAL: Output NOTHING except the JSON. No explanations, no markdown, just the JSON object.
            """

        case .mimic:
            let entity = entityName ?? "your chosen character"
            return """
            MIMIC MODE ACTIVE - You are now roleplaying as \(entity):
            - Adopt the personality, speech patterns, and mannerisms of \(entity)
            - Stay in character throughout the conversation
            - Use their typical vocabulary and expressions
            - Reference their world, experiences, and relationships when relevant
            - Make learning engaging by teaching through this character's perspective
            - If \(entity) wouldn't know something, acknowledge it in character
            """
        }
    }

    // Get timer-specific instructions
    private func getTimerInstructions(_ timerDescription: String) -> String {
        return """
        TIMER CONTEXT: \(timerDescription)
        Keep responses focused and efficient while maintaining quality.
        Help the student make the most of their timed session.
        """
    }

    // Get instructions for handling frustration button
    func getFrustrationInstructions() -> String {
        return """
        The student has indicated they're feeling frustrated. Please:
        - Acknowledge their frustration with empathy
        - Offer to approach the topic differently
        - Break down complex concepts into smaller, more manageable pieces
        - Provide more examples or alternative explanations
        - Reassure them that struggling is a normal part of learning
        - Ask what specific part is causing difficulty
        """
    }

    // Get instructions for changing learning lens
    func getLensChangeInstructions(newLens: LearningLens?, previousLens: LearningLens?) -> String {
        guard let newLens = newLens else {
            if previousLens != nil {
                return "Please return to a standard teaching approach without the thematic lens."
            }
            return ""
        }

        if newLens.name == "None" {
            return "Please use a standard teaching approach without any specific thematic lens."
        }

        return """
        LEARNING LENS APPLIED: \(newLens.name)
        \(newLens.themeDescription)
        """
    }

    // Truncate context if it exceeds token limits
    func truncateContext(_ messages: [ChatMessage], maxMessages: Int = 20) -> [ChatMessage] {
        // Keep only the most recent messages to avoid token limit issues
        if messages.count > maxMessages {
            return Array(messages.suffix(maxMessages))
        }
        return messages
    }
}