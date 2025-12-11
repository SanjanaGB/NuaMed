import Foundation

final class GroqService {
    static let shared = GroqService()

    //private let apiKey = "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"
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "GROQ_API_KEY") as? String ?? ""

    private let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    private init() {}

    func run(prompt: String) async throws -> String {
        var lastError: Error?

        for _ in 0..<3 {
            do { return try await runOnce(prompt: prompt) }
            catch {
                lastError = error
                print("⚠️ Groq retry:", error)
                try? await Task.sleep(nanoseconds: 300_000_000)
            }
        }
        throw lastError ?? NSError(domain: "GroqError", code: 0)
    }

    private func runOnce(prompt: String) async throws -> String {
        let strictPrompt = """
        You must return ONLY VALID JSON — no text outside JSON, no comments.

        ABSOLUTE RULES:
        - Every ingredient must be returned as ONE dictionary.
        - NEVER split names such as "CAFFEINE(8", "3 mg/100 g)".
          → Instead produce: "CAFFEINE (8.3 mg/100g)"
        - Every ingredient MUST contain ALL 3 keys:
            "name": string
            "safetyLevel": number
            "info": string
        - Do not output trailing commas, duplicate keys, or malformed JSON.
        - If unsure, return: {"ingredients":[]}

        TASK:
        \(prompt)
        """

        let body: [String : Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [[
                "role": "user",
                "content": strictPrompt
            ]],
            "temperature": 0.1
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            var content = message["content"] as? String
        else {
            throw NSError(domain: "GroqError", code: 0)
        }

        content = sanitize(content)

        guard content.toJSONDict() != nil else {
            print("❌ Invalid JSON:", content)
            throw NSError(domain: "GroqParsing", code: 0)
        }

        return content
    }

    private func sanitize(_ raw: String) -> String {
        var t = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if t.contains("```") {
            t = t.replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
        }

        if let s = t.firstIndex(of: "{"), let e = t.lastIndex(of: "}") {
            t = String(t[s...e])
        }

        return t
    }
}

//extension String {
//    func toJSONDict() -> [String: Any]? {
//        let clean = trimmingCharacters(in: .whitespacesAndNewlines)
//        guard let data = clean.data(using: .utf8) else { return nil }
//        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
//    }
//}
