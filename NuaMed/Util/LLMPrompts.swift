import Foundation

struct LLMPrompts {

    // ============================================================
    // 1️⃣ CATEGORY CLASSIFICATION — FIXED & ROBUST
    // ============================================================
    static func classifyCategory(name: String, description: String) -> String {
        """
        Your task is to classify a product into EXACTLY ONE of the following categories:

        • "Food Product"
        • "Cosmetic Item"
        • "Medication"
        • "Unknown"

        PRODUCT NAME: "\(name)"
        PRODUCT DESCRIPTION: "\(description)"

        -------------------------
        HARD CLASSIFICATION RULES
        -------------------------

        1. COSMETIC ITEM  
           If the name contains ANY of the following keywords (case-insensitive):  
           soap, body wash, shampoo, conditioner, cleanser, face wash, handwash,
           lotion, cream, moisturizer, shaving, deodorant, perfume, toner,
           sunscreen, serum, makeup, dettol, savlon, olay, nivea, ponds  
           → MUST return: "Cosmetic Item".

        2. MEDICATION  
           If the item is a tablet, capsule, syrup, injection, ointment, antibiotic,
           antihistamine, painkiller, or is meant to treat ANY medical condition  
           → MUST return: "Medication".

        3. FOOD PRODUCT  
           If the item is edible or drinkable (foods, snacks, beverages, spices,
           chocolates, juices, supplements, oils)  
           → MUST return: "Food Product".

        4. UNKNOWN (IMPORTANT)  
           If the item is NOT cosmetic, food, or medication:  
           Examples: chair, laptop, book, pillow, candle, charger, bottle, toy  
           → MUST return: "Unknown".  
           Do NOT force a wrong category.

        -------------------------
        OUTPUT STRICT JSON ONLY:
        -------------------------
        {
          "category": "<Food Product | Cosmetic Item | Medication | Unknown>"
        }

        No explanation. No extra text. JSON only.
        """
    }



    // ============================================================
    // 2️⃣ INGREDIENT EXTRACTION (STRICT & CLEAN)
    // ============================================================
    static func extractIngredients(raw query: String) -> String {
        """
        PRODUCT NAME: "\(query)"

        RULE:
        - If this product is NOT edible, drinkable, cosmetic, or medicinal,
          return an EMPTY ingredient list:
            { "ingredients": [] }

        Examples of NON-ingredient items:
        chair, sofa, phone, laptop, pillow, table, bag, shoes, charger, pen.

        Otherwise:
        - Infer 6–10 realistic ingredients found in typical products of this type.
        - ONLY real, common ingredients.
        - NO invented chemicals, NO formulas, NO quantities.

        OUTPUT STRICT JSON ONLY:
        {
          "ingredients": [
            { "name": "<ingredient>" }
          ]
        }
        """
    }



    // ============================================================
    // 3️⃣ INGREDIENT INFO (SAFE / CAUTION / UNSAFE)
    // ============================================================
    static func ingredientInfo(ingredients: [String]) -> String {
        """
        If the ingredient list is EMPTY:
        Return:
        { "ingredients": [] }

        Otherwise, for each ingredient in:
        \(ingredients)

        Provide:
        - safetyLevel: 0 = safe, 1 = caution, 2 = unsafe
        - info: short text

        STRICT JSON ONLY:
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
