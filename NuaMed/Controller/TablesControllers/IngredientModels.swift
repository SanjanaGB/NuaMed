import Foundation

enum IngredientSafety: Int {
    case safe
    case unsafe
    case caution
}

struct Ingredient {
    let name: String
    let safety: IngredientSafety
    let infoText: String
}
