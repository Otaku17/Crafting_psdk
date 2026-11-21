# ============================================================
# CraftSystem — State
# ------------------------------------------------------------
# Core crafting system manager (state part).
# Responsible for:
#   - Crafting state access
#   - Manual lock / unlock
#   - State synchronization with the recipe list
#   - Invalidation of recipes depending on deleted ones
# ============================================================

module CraftSystem
  module_function

  # Return crafting state hash.
  # @return [Hash{Symbol => Boolean}]
  def state
    $crafting_data ||= {}
    sync_state!
    $crafting_data
  end

  # Retrieve recipe definition.
  # @param key [Symbol]
  # @return [Hash, nil]
  def recipe(key)
    Recipes[key]
  end

  # Return all recipe keys.
  # @return [Array<Symbol>]
  def all_recipes
    Recipes.keys
  end

  # Manually unlock a recipe.
  # On a persistent recipe, the unlock is kept even if the condition is not met.
  # @param key [Symbol]
  # @return [void]
  def unlock(key)
    key = key.to_sym
    sync_state!
    state[key] = true if Recipes[key]
    refresh_unlocks!
  end

  # Manually lock a recipe.
  # On a persistent recipe, this resets the saved unlock: the recipe stays
  # unlocked only if its condition is still met right now.
  # @param key [Symbol]
  # @return [void]
  def lock(key)
    key = key.to_sym
    sync_state!
    state[key] = false if Recipes[key]
    refresh_unlocks!
  end

  # Synchronize crafting state with current recipes.
  # @return [void]
  def sync_state!
    return if @syncing_state
    @syncing_state = true

    $crafting_data ||= {}
    current_keys = Recipes.keys.map(&:to_sym)

    $crafting_data.keys.each do |key|
      unless current_keys.include?(key)
        $crafting_data.delete(key)
        invalidate_dependent_recipes!(key)
      end
    end

    current_keys.each do |key|
      next if $crafting_data.key?(key)
      cond = Recipes[key][:unlock_condition]

      if cond && cond[:type] == :manual
        $crafting_data[key] = cond.fetch(:value, false)
      else
        $crafting_data[key] = false
      end
    end

    refresh_unlocks!(skip_sync: true)
    @syncing_state = false
  end

  # Invalidate recipes depending on a deleted recipe.
  # @param deleted_key [Symbol]
  # @return [void]
  def invalidate_dependent_recipes!(deleted_key)
    Recipes.keys.each do |key|
      next unless state.key?(key)
      cond = Recipes[key][:unlock_condition] rescue nil
      next unless cond

      if depends_on_recipe?(cond, deleted_key)
        state[key] = false
        invalidate_dependent_recipes!(key)
      end
    end
  end

  # Check if condition depends on a recipe.
  # @param condition [Hash, Array]
  # @param target_key [Symbol]
  # @return [Boolean]
  def depends_on_recipe?(condition, target_key)
    return false unless condition
    if condition.is_a?(Array)
      condition.any? { |c| depends_on_recipe?(c, target_key) }
    elsif condition.is_a?(Hash) && condition[:operator]
      condition[:conditions].any? { |c| depends_on_recipe?(c, target_key) }
    else
      condition[:type] == :recipe && condition[:key].to_sym == target_key
    end
  end
end
