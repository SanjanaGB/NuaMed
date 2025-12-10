import Foundation

struct SafetyScoring {

    static func compute(ingredients: [Ingredient], user: User?) -> Int {

        var baseScores: [Int] = []

        // IngredientSafety enum rawValue already 0 = safe, 1 = caution, 2 = avoid
        for ing in ingredients {
            switch ing.safety {
            case .safe:
                baseScores.append(100)
            case .caution:
                baseScores.append(65)
            case .unsafe:
                baseScores.append(20)
            }
        }

        // Mean ingredient safety
        let ingredientScore = baseScores.isEmpty
            ? 50
            : baseScores.reduce(0,+) / baseScores.count

        var finalScore = Int(Double(ingredientScore) * 0.7)

        // Count avoid-level ingredients
        let avoidCount = ingredients.filter { $0.safety == .unsafe }.count
        finalScore -= avoidCount * 5   // each red-flag reduces score

        // User allergy penalties
        if let user = user {
            let allergies = user.allergies.map { $0.lowercased() }
            for ing in ingredients {
                if allergies.contains(where: { ing.name.lowercased().contains($0) }) {
                    finalScore -= 20      // heavy penalty
                }
            }
        }

        return max(0, min(100, finalScore))   // clamp 0–100
    }
}
