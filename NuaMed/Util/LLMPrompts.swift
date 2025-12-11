import Foundation

struct LLMPrompts {

    // ============================================================
    // 1️⃣ CATEGORY CLASSIFICATION — FIXED & ROBUST
    // ============================================================
    static func classifyCategory(name: String, description: String) -> String {
        """
        You MUST classify this product into EXACTLY ONE of the following categories:

        • "Food Product"
        • "Cosmetic Item"
        • "Medication"

        PRODUCT NAME: "\(name)"
        PRODUCT DESCRIPTION: "\(description)"

        HARD RULES:
        - If it contains "soap", "body wash", "shampoo", "handwash", "detergent", "cleanser", 
          "face wash", "lotion", "cream", "moisturizer", "shaving", "deodorant", 
          "dettol", "savlon", "olay", "nivea", "ponds"
          → ALWAYS "Cosmetic Item".

        - If it contains "antiseptic", "disinfectant"
          → ALWAYS "Cosmetic Item".

        - If it treats a medical condition (tablet, capsule, syrup, antibiotic, ointment)
          → ALWAYS "Medication".

        - If it is edible or drinkable (any food, beverage, supplement, candy)
          → ALWAYS "Food Product".

        - NEVER classify non-edible items as food.

        YOU MUST RETURN VALID JSON ONLY:
        {
            "category": "<Food Product | Cosmetic Item | Medication>"
        }
        """
    }


    // ============================================================
    // 2️⃣ INGREDIENT EXTRACTION (STRICT & CLEAN)
    // ============================================================
    static func extractIngredients(raw query: String) -> String {
        """
        The product name is: "\(query)"

        TASK:
        - Infer a realistic list of 6–10 ingredients usually found in products of this type.
        - DO NOT hallucinate strange chemicals.
        - DO NOT repeat ingredients.
        - DO NOT include quantities or fake formulas.
        - ONLY include real-world common ingredients.

        OUTPUT STRICT JSON ONLY:
        {
          "ingredients": [
            { "name": "<ingredient>" }
          ]
        }

        NO explanation. NO text outside JSON. ONLY the ingredient list.
        """
    }


    // ============================================================
    // 3️⃣ INGREDIENT INFO (SAFE / CAUTION / UNSAFE)
    // ============================================================
    static func ingredientInfo(ingredients: [String]) -> String {
        """
        Provide concise safety info for EACH ingredient below:

        \(ingredients)

        RULES:
        - Return EXACTLY one entry per ingredient.
        - DO NOT mutate or rewrite ingredient names.
        - DO NOT add or remove ingredients.
        - safetyLevel values:
            0 = safe  
            1 = caution  
            2 = unsafe  
        - info MUST be short.

        RETURN STRICT JSON ONLY:
        {
          "ingredients": [
            { "name": "<ingredient>", "safetyLevel": 0, "info": "<short>" }
          ]
        }
        """
    }


    // ============================================================
    // 4️⃣ SAFETY CHECK (ALLERGY + CONDITIONS + MEDICATION)
    // ============================================================
    static func safetyCheck(
        ingredients: [String],
        allergies: [String],
        conditions: [String],
        meds: [String]
    ) -> String {

        """
        You are a medical-grade safety engine.

        INGREDIENTS: \(ingredients)
        USER ALLERGIES: \(allergies)
        USER CONDITIONS: \(conditions)
        USER MEDICATIONS: \(meds)

        --------------------------------------------------------------------
        RULES FOR ALERTS:
        --------------------------------------------------------------------
        1. ALLERGY MATCHING
           - Case-insensitive.
           - If ANY ingredient contains ANY allergen substring → FLAG IT.

        2. CONDITION WARNINGS
           Examples:
           - diabetes → flag: sugar, high fructose corn syrup, glucose, sucrose
           - hypertension → flag: sodium, salt, MSG
           - kidney disease → flag: potassium, creatine
           - GERD → flag: caffeine, mint
           - pregnancy → flag: retinol, salicylic acid, benzoyl peroxide

        3. MEDICATION INTERACTIONS
           Examples:
           - atorvastatin, simvastatin → NO grapefruit
           - metformin → caution with alcohol
           - antihistamines → avoid alcohol
           - SSRIs → avoid St. John’s Wort
           - blood thinners (warfarin) → avoid vitamin K rich additives
           - MAOIs → avoid tyramine (soy sauce, cheese extracts)

        IMPORTANT:
        - ONLY produce a warning if the ingredient ACTUALLY APPEARS.
        - DO NOT invent new ingredients.
        - DO NOT hallucinate diseases.
        - RETURN ONLY STRICT JSON.

        --------------------------------------------------------------------
        RETURN FORMAT:
        --------------------------------------------------------------------
        {
          "allergenMatches": ["..."],
          "warnings": [
            { "ingredient": "<ingredient>", "issue": "<why flagged>" }
          ],
          "category": "<Food Product | Cosmetic Item | Medication>"
        }
        --------------------------------------------------------------------
        JSON ONLY. NO TEXT OUTSIDE JSON.
        """
    }
}
