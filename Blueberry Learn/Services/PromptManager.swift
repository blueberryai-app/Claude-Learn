import Foundation

class PromptManager {
    static let shared = PromptManager()

    private init() {}

    // Get complete system prompt for a learning space with mode and lens
    func getSystemPrompt(
        for space: LearningSpace,
        mode: LearningMode,
        lens: LearningLens?,
        customEntityName: String? = nil
    ) -> String {
        var components: [String] = []

        // Base role
        components.append("You are Claude, an AI tutor specializing in \(space.name).")

        // Space-specific instructions
        if !space.systemPrompt.isEmpty {
            components.append(space.systemPrompt)
        } else {
            components.append(getDefaultPrompt(for: space.name))
        }

        // Mode-specific behavior
        components.append(getModeInstructions(mode, entityName: customEntityName))

        // Learning lens modifier
        if let lens = lens, lens.name != "None" {
            components.append(getLensInstructions(lens))
        }

        // General guidelines
        components.append("""
        Always be encouraging and supportive. Adapt your teaching style to the student's needs.
        Keep responses concise but thorough. Use examples to illustrate concepts when helpful.
        """)

        return components.joined(separator: "\n\n")
    }

    // Default prompts for common subjects
    private func getDefaultPrompt(for subject: String) -> String {
        let prompts: [String: String] = [
            "Physics": "Help students understand physical concepts, laws, and problem-solving techniques. Use real-world examples and clear explanations of formulas.",
            "Biology": "Guide students through biological concepts from molecular to ecosystem levels. Emphasize connections between different biological systems.",
            "Literature": "Analyze texts, themes, and literary devices. Help students develop critical reading and interpretation skills.",
            "Writing": "Assist with composition, structure, and style. Focus on clarity, coherence, and effective communication.",
            "Mathematics": "Explain mathematical concepts clearly, work through problems step-by-step, and help build problem-solving skills.",
            "Chemistry": "Clarify chemical concepts, reactions, and calculations. Use visual descriptions when helpful.",
            "History": "Explore historical events, contexts, and their significance. Help students understand cause-and-effect relationships.",
            "Computer Science": "Explain programming concepts, algorithms, and best practices. Provide code examples when appropriate."
        ]

        // Try to match subject name to get specific prompt
        for (key, prompt) in prompts {
            if subject.lowercased().contains(key.lowercased()) {
                return prompt
            }
        }

        // Default fallback
        return "Provide clear, helpful explanations and guide students toward understanding. Encourage critical thinking and active learning."
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
            QUIZ MODE ACTIVE:
            - Generate relevant practice questions on the topic
            - Start with moderate difficulty and adjust based on responses
            - After each answer, provide immediate feedback
            - Explain why answers are correct or incorrect
            - Keep track of their progress throughout the session
            - Mix question types (multiple choice, short answer, problem-solving)
            """

        case .customEntity:
            let entity = entityName ?? "the specified character"
            return """
            CUSTOM ENTITY MODE - Acting as \(entity):
            - Embody the personality and knowledge of \(entity)
            - Maintain character while being educational
            - Use speech patterns and perspectives appropriate to \(entity)
            - Reference relevant experiences or viewpoints of \(entity)
            - Stay helpful and informative despite the roleplay
            """
        }
    }

    // Get learning lens instructions
    private func getLensInstructions(_ lens: LearningLens) -> String {
        let lensPrompts: [String: String] = [
            "Star Wars": """
            Frame concepts using Star Wars analogies and references.
            Compare ideas to Force powers, starship systems, galactic politics, or Jedi philosophy.
            Use familiar characters and situations to illustrate points.
            """,

            "Sports": """
            Use sports metaphors and athletic examples.
            Compare learning to training, practice, and competition.
            Reference famous athletes, games, and sporting strategies.
            """,

            "History": """
            Connect concepts to historical events and figures.
            Draw parallels to historical situations and outcomes.
            Use historical context to enrich understanding.
            """,

            "Pop Culture": """
            Reference current trends, memes, and popular media.
            Use contemporary examples from movies, music, and social media.
            Keep references appropriate and educational.
            """,

            "Nature": """
            Use natural phenomena and ecosystems as examples.
            Draw parallels to animal behaviors and natural processes.
            Connect concepts to environmental observations.
            """
        ]

        return """
        LEARNING LENS (\(lens.name)):
        \(lensPrompts[lens.name] ?? lens.themeDescription)
        Make frequent connections to this theme to enhance engagement and understanding.
        """
    }

    // Format user message based on mode (if needed)
    func formatUserMessage(_ content: String, mode: LearningMode) -> String {
        // Most modes don't need special formatting of user messages
        // But this could be extended if needed
        return content
    }

    // Estimate token count (rough approximation)
    func estimateTokenCount(_ text: String) -> Int {
        // Rough estimate: 1 token ≈ 4 characters
        return text.count / 4
    }

    // Truncate context to fit within token limits
    func truncateContext(_ messages: [ChatMessage], maxTokens: Int = 2000) -> [ChatMessage] {
        var totalTokens = 0
        var truncatedMessages: [ChatMessage] = []

        // Start from most recent messages
        for message in messages.reversed() {
            let messageTokens = estimateTokenCount(message.content)
            if totalTokens + messageTokens > maxTokens {
                break
            }
            truncatedMessages.insert(message, at: 0)
            totalTokens += messageTokens
        }

        return truncatedMessages
    }
}