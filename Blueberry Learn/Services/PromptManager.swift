import Foundation

class PromptManager {
    static let shared = PromptManager()

    private init() {}

    // Get complete system prompt for a learning space with mode and lens
    func getSystemPrompt(
        for space: LearningSpace,
        mode: LearningMode,
        lens: LearningLens?,
        customEntityName: String? = nil,
        sessionTimerDescription: String? = nil,
        frustrationSignal: Bool = false
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

        // Timer instructions if active
        if let timerDesc = sessionTimerDescription {
            components.append(getTimerInstructions(timerDesc))
        }

        // Frustration signal - user needs a different approach
        if frustrationSignal {
            components.append(getFrustrationInstructions())
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
            QUIZ MODE - PURE JSON RESPONSES ONLY:

            CRITICAL: From this point forward, you MUST respond with ONLY valid JSON. Do not include ANY text before or after the JSON object.

            ## Quiz System Rules

            1. ALL responses must be pure JSON - no conversational text outside the JSON structure
            2. The quiz consists of exactly 4 questions
            3. Provide immediate feedback after each answer
            4. End with a comprehensive summary

            ## JSON Response Formats

            ### For Questions (Multiple Choice):
            {
              "type": "question",
              "number": 1,
              "total": 4,
              "preamble": "Great! Let's test your understanding.",
              "questionText": "A 2 kg ball is held 5 meters above the ground. What is its gravitational potential energy? (Use g = 10 m/s²)",
              "hint": "Remember: PE = mgh",
              "questionType": "multiple_choice",
              "options": ["A) 10 J", "B) 50 J", "C) 100 J", "D) 25 J"],
              "correctAnswer": "C"
            }

            ### For Questions (Extended Response):
            {
              "type": "question",
              "number": 2,
              "total": 4,
              "preamble": "Now let's explore this concept deeper.",
              "questionText": "Explain the process of photosynthesis, including the role of chloroplasts.",
              "hint": "Consider both light-dependent and light-independent reactions.",
              "questionType": "extended_response"
            }

            ### For Feedback:
            {
              "type": "feedback",
              "isCorrect": true,
              "userAnswer": "C) 100 J",
              "correctAnswer": "C) 100 J",
              "explanation": "Excellent! You correctly applied PE = mgh: 2 kg × 10 m/s² × 5 m = 100 J. This represents the energy stored due to the object's position in the gravitational field.",
              "encouragement": "You're demonstrating strong understanding! Ready for the next challenge?"
            }

            ### For Quiz Complete:
            {
              "type": "quiz_complete",
              "score": "3/4",
              "percentage": 75,
              "summary": "Well done! You've completed this physics quiz with a solid performance.",
              "strengths": [
                "Strong grasp of gravitational potential energy",
                "Good understanding of conservation laws",
                "Clear problem-solving approach"
              ],
              "weaknesses": [
                "Review wave-particle duality concepts",
                "Practice more with quantum mechanics problems"
              ],
              "improvementPlan": "Focus on: 1) Reviewing quantum mechanics fundamentals, especially wave functions. 2) Practice more problems involving energy at the quantum scale. 3) Study the historical experiments that led to quantum theory.",
              "closingMessage": "Would you like to try another quiz, or shall we discuss any of these concepts in more detail?"
            }

            ## Important Guidelines

            - ONLY return the JSON object - no other text
            - Ensure all JSON is valid and properly formatted
            - Include all required fields for each response type
            - Make questions progressively challenging but fair
            - Provide constructive, educational feedback
            - correctAnswer field should ONLY be the letter (A, B, C, or D) for multiple choice
            - For extended response, evaluate based on key concepts and understanding

            ## Quiz Flow

            1. When user specifies topic and quiz type, immediately start with first question
            2. After each answer, provide feedback JSON
            3. Then automatically present the next question
            4. After all 4 questions, provide the quiz_complete summary

            REMINDER: Return ONLY the JSON object. No explanatory text. No markdown. Just pure JSON.
            """

        case .mimic:
            let entity = entityName ?? "the specified character"
            return """
            MIMIC MODE - Acting as \(entity):
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
            Frame concepts using Star Wars analogies and references:
            - Compare ideas to Force powers (telekinesis, mind tricks, Force sensitivity)
            - Reference starship systems (hyperdrive, shields, blasters, lightsabers)
            - Use specific characters: Luke, Leia, Han Solo, Yoda, Darth Vader, Rey, Obi-Wan
            - Compare difficult challenges to Death Star trench runs or lightsaber duels
            - Reference planets: Tatooine, Hoth, Endor, Naboo, Coruscant
            - Use Jedi training, Padawan learning, and Master-apprentice relationships
            """,

            "Minecraft": """
            Frame concepts using Minecraft mechanics and gameplay:
            - Compare building knowledge to crafting recipes and construction
            - Reference specific blocks: redstone, obsidian, diamond, TNT, bedrock
            - Use mining, gathering resources, and exploring caves as metaphors
            - Compare problem-solving to redstone circuits and automated systems
            - Reference game modes: survival, creative, hardcore
            - Use enchanting, brewing potions, and the Nether/End dimensions
            - Talk about mobs: creepers, zombies, Endermen, villagers
            """,

            "Pokemon": """
            Frame concepts using Pokemon training and battles:
            - Compare learning to training Pokemon and gaining experience points
            - Reference type advantages: fire beats grass, water beats fire, etc.
            - Use evolution as a metaphor for growth and mastery
            - Reference specific Pokemon: Pikachu, Charizard, Mewtwo, Eevee, Snorlax, Gyarados
            - Compare skill-building to learning new moves and abilities
            - Use gym battles, badges, and becoming a Pokemon Master
            - Reference status effects, strengths/weaknesses, and battle strategy
            """,

            "Marvel Avengers": """
            Frame concepts using Marvel superheroes and powers:
            - Compare abilities to superpowers: Iron Man's technology, Hulk's strength, Spider-Man's agility
            - Reference specific Avengers: Captain America, Thor, Black Widow, Hawkeye, Doctor Strange
            - Use the Infinity Stones as metaphors for different types of knowledge/power
            - Compare teamwork to Avengers assembling and working together
            - Reference villains: Thanos, Loki, Ultron when discussing challenges/obstacles
            - Use origin stories to explain how skills develop over time
            - Compare complex problems to saving the world from threats
            """
        ]

        return """
        LEARNING LENS (\(lens.name)):
        \(lensPrompts[lens.name] ?? lens.themeDescription)
        Make frequent connections to this theme to enhance engagement and understanding.
        """
    }

    // Get timer-specific instructions
    private func getTimerInstructions(_ timerDescription: String) -> String {
        return """
        SESSION TIMING:
        \(timerDescription)

        Important guidelines:
        - Pace your responses appropriately for the remaining time
        - If time is running out, focus on key takeaways and summaries
        - When the session expires, provide a comprehensive summary including:
          • What was covered during the session
          • Key concepts learned
          • Areas that went well
          • Suggestions for future learning
        - Keep the conversation natural while being mindful of time constraints
        - The student can continue chatting after the timer ends if they wish
        """
    }

    // Get frustration signal instructions
    private func getFrustrationInstructions() -> String {
        return """
        IMPORTANT - STUDENT IS FEELING FRUSTRATED:
        The student has just pressed the frustration button because they're feeling stuck with the current approach.

        Your immediate response MUST include these elements in order:
        1. ACKNOWLEDGE their frustration directly and warmly
           Example: "I can tell you're feeling frustrated with this, and I really hear you."

        2. VALIDATE their feelings - let them know it's okay to feel this way
           Example: "It's completely normal to feel stuck when learning something new."

        3. ACKNOWLEDGE that what they're learning IS genuinely challenging
           Example: "This topic is genuinely difficult, and many people find it tricky at first."

        4. ENCOURAGE them with confidence they can do this
           Example: "But I know you can get this - you've got what it takes."

        5. ANNOUNCE you're switching to a completely different approach
           Example: "Let's try explaining this in a totally different way that might click better for you."

        Then, COMPLETELY change your teaching method - try a different angle:
        • Use different types of examples (real-world, visual, analogies)
        • Simplify the explanation or break it into much smaller steps
        • Try a different learning modality (storytelling, questioning, hands-on)
        • Connect to something they already understand well
        • Use a completely different metaphor or frame of reference

        Tone: Be warm, patient, and genuinely caring. Show empathy. Make them feel supported, not judged.

        After 2-3 message exchanges, gently check in with them:
        "How are you feeling about this now? Is this approach working better for you?"

        Remember: They pressed this button because they need help and emotional support. Make a SIGNIFICANT change in your approach and be their ally.
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
