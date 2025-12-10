import Foundation

class LLMService {
    static let shared = LLMService()

    func run(prompt: String) async throws -> String {
        return try await GroqService.shared.run(prompt: prompt)
    }
}
