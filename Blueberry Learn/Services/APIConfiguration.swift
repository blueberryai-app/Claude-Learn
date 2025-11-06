import Foundation

// IMPORTANT: This is for POC only. In production, use a secure method like Keychain or environment variables, or something like AIProxy.
struct APIConfiguration {
    // For prototyping, this holds my personal key (not commited to github, but encrypted in the testflight distributed app)
    // Key from: https://console.anthropic.com/account/keys
    static let anthropicAPIKey = ""

    // Optional: Set to true to use mock responses instead of real API calls (for testing UI)
    static let useMockResponses = false

    // Optional: Set the Claude model to use
    static let claudeModel = "claude-sonnet-4-5"

    // Optional: Set max tokens for responses
    static let maxTokens = 8056
}

/*
 HOW TO SET UP YOUR API KEY:

 1. Go to https://console.anthropic.com and sign in or create an account
 2. Navigate to Account Settings > API Keys
 3. Create a new API key
 4. Copy the key (it starts with "sk-ant-")
 5. Replace "sk-ant-YOUR-API-KEY-HERE" above with your actual key
 6. Build and run the app

 SECURITY NOTE:
 - Never commit your actual API key to version control
 - For production apps, use secure storage methods like iOS Keychain
 - Consider using a proxy server to hide the API key from the client

 TESTING WITHOUT API KEY:
 - Set useMockResponses to true to test the UI without making real API calls
 */
