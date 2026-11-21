# ============================================================
# CraftSystem — Craft
# ------------------------------------------------------------
# Craft execution and inventory interaction.
# Responsible for:
#   - Ingredient checks
#   - Craft execution
#   - UI data formatting
# ============================================================

module CraftSystem
  module_function

  # Check if player has enough quantity of an item.
  # @param item [Symbol]
  # @param quantity [Integer]
  # @return [Boolean]
  def has_item_quantity?(item, quantity)
    return false if quantity <= 0
    $bag.item_quantity(item) >= quantity
  end

  # Return maximum craftable amount.
  # @param key [Symbol]
  # @return [Integer]
  def max_craft(key)
    recipe = Recipes[key]
    return 0 unless recipe && unlocked?(key)

    recipe[:ingredients].map do |item, qty|
      $bag.item_quantity(item) / qty
    end.min || 0
  end

  # Check if crafting is possible.
  # @param key [Symbol]
  # @param amount [Integer]
  # @return [Boolean]
  def can_craft?(key, amount = 1)
    max_craft(key) >= amount
  end

  # Craft a recipe.
  # @param key [Symbol]
  # @param amount [Integer]
  # @return [Boolean]
  def craft(key, amount = 1)
    return false unless can_craft?(key, amount)

    recipe = Recipes[key]

    recipe[:ingredients].each do |item, qty|
      $bag.remove_item(item, qty * amount)
    end

    $bag.add_item(recipe[:result], recipe[:quantity] * amount)
    true
  end

  # Craft maximum possible amount.
  # @param key [Symbol]
  # @return [Boolean]
  def craft_all(key)
    amount = max_craft(key)
    return false if amount <= 0
    craft(key, amount)
  end

  # Return formatted recipe data for UI usage.
  # @param key [Symbol]
  # @return [Hash, nil]
  def data_craft(key)
    recipe = Recipes[key]
    return nil unless recipe

    {
      ingredients: recipe[:ingredients],
      result: recipe[:result],
      quantity: recipe[:quantity],
      unlocked: unlocked?(key),
      max_craft: max_craft(key),
      category: recipe[:category]
    }
  end
end
