struct LLMPrompts {

    static func classifyCategory(name: String, description: String) -> String {
        return """
        You MUST classify the following product into EXACTLY one category:
        - "Cosmetics Items"
        - "Food Products"
        - "Medications"

        Rules:
        - If it is skincare, shampoo, soap, lotion → Cosmetics Items.
        - If it is edible or drinkable → Food Products.
        - If it treats a medical condition or contains active drug ingredients → Medications.

        Respond ONLY in JSON:
        {
            "category": "<cosmetics | food | medication>"
        }

        Product: \(name)
        Description: \(description)
        """
    }


    static func extractIngredients(raw: String) -> String {
        """
        Extract ingredients from the raw text.
        
        ⚠️ IMPORTANT PARSING RULES:
        - Never split an ingredient into multiple items.
        - Keep numbers, ranges, parentheses, and units together.
        - Example: “Caffeine (8.3 mg/100g)” MUST be returned as a SINGLE ingredient.

        Return JSON:
        {
          "ingredients": ["...", "..."]
        }

        Raw:
        \(raw)
        """
    }


    static func ingredientInfo(ingredients: [String]) -> String {
        """
        For each ingredient return safetyLevel + info.

        RULES:
        - NEVER split an ingredient into multiple strings even if it contains commas, numbers, or parentheses.
        - Treat the full text of each ingredient exactly as provided.
        - Never output broken JSON.
        - safetyLevel must be: 0 = safe, 1 = caution, 2 = unsafe.

        Return ONLY this structure:
        {
          "ingredients": [
            { "name": "<full-ingredient-name>", "safetyLevel": 0, "info": "<short explanation>" }
          ]
        }

        Ingredients: \(ingredients)
        """
    }


    static func safetyCheck(
        ingredients: [String],
        allergies: [String],
        conditions: [String],
        meds: [String]
    ) -> String {
        """
        You are an expert in food safety, cosmetic safety, and medication interactions.

        You MUST return STRICT JSON ONLY in this exact format:

        {
          "overallSafetyScore": <0-100>,
          "allergenMatches": ["allergen1", "allergen2"],
          "warnings": [
            { "ingredient": "ingredientName", "issue": "explanation" }
          ],
          "category": "food | cosmetic | medication"
        }

        RULES:
        - NEVER include explanations outside JSON.
        - ALWAYS classify the product strictly as **food**, **cosmetic**, or **medication**.
        - Detect allergens by checking if ANY ingredient contains ANY user allergy substring (case-insensitive).
        - List ALL matching allergens in "allergenMatches".
        - If an allergen matches, also add a warning entry for that ingredient.
        - Ingredient names MUST NOT be split or malformed.
        - If an ingredient contains commas, keep it as a single string.
        - NEVER output invalid JSON like `"ingredient": "A", "B"`.

        Compute safety score as:
        - Start from 100.
        - Subtract 20 for each ingredient matching a user allergy.
        - Subtract 10 for ingredients likely to cause irritation (e.g., alcohols, fragrances, parabens).
        - Clamp between 0 and 100.

        Ingredients: \(ingredients)
        User Allergies: \(allergies)
        Medical Conditions: \(conditions)
        Medications: \(meds)
        """
    }

}
