import Foundation

extension String {

    /// Converts a cleaned LLM string into a JSON dictionary.
    /// Supports Llama/Groq quirks like extra whitespace or markdown.
    func toJSONDict() -> [String: Any]? {
        var t = self.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip code block wrappers
        if t.hasPrefix("```") {
            t = t.replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Extract JSON object only
        if let start = t.firstIndex(of: "{"),
           let end = t.lastIndex(of: "}") {
            t = String(t[start...end])
        }

        // Convert to Data
        guard let data = t.data(using: .utf8) else { return nil }

        // Parse JSON
        return try? JSONSerialization.jsonObject(with: data) as? [String : Any]
    }
}
