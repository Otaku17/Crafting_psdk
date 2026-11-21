# ============================================================
# CraftSystem — Unlock
# ------------------------------------------------------------
# Unlock logic.
# Responsible for:
#   - Unlock checks (live and persistent)
#   - Persistent unlock recording
#   - Recursive refresh of unlock states
#   - Unlocked / locked recipe lists
#
# Persistent unlock:
#   A recipe whose root unlock_condition has "persistent": true stays
#   unlocked forever once its condition has been met one time, even if
#   the condition stops being true later (item lost, switch OFF...).
# ============================================================

module CraftSystem
  module_function

  # Check if recipe is unlocked.
  # @param key [Symbol]
  # @return [Boolean]
  def unlocked?(key)
    key = key.to_sym
    recipe = Recipes[key]
    return false unless recipe

    cond = recipe[:unlock_condition]
    return true unless cond
    return state[key] == true if cond[:type] == :manual
    return condition_met?(cond) unless persistent?(key)
    return true if state[key] == true

    met = condition_met?(cond)
    state[key] = true if met
    met
  end

  # Check if a recipe uses a persistent unlock.
  # @param key [Symbol]
  # @return [Boolean]
  def persistent?(key)
    cond = Recipes[key.to_sym]&.dig(:unlock_condition)
    return false unless cond.is_a?(Hash)

    cond[:persistent] == true && cond[:type] != :manual
  end

  # Record every persistent recipe whose condition is currently met.
  # Called automatically when an item is added to the bag.
  # Call it from an event right after changing a switch, a variable,
  # finishing a quest or giving a Pokemon if the condition can
  # become false again before the next crafting check.
  # @return [Array<Symbol>] recipes newly unlocked
  def check_persistent_unlocks!
    return [] if @checking_persistent
    @checking_persistent = true
    newly = []

    loop do
      found = Recipes.keys.select do |key|
        persistent?(key) && state[key] != true && condition_met?(Recipes[key][:unlock_condition])
      end
      break if found.empty?

      found.each { |key| state[key] = true }
      newly.concat(found)
    end

    newly
  ensure
    @checking_persistent = false
  end

  # Refresh unlock states recursively.
  # Persistent recipes already unlocked are never locked back.
  # @param skip_sync [Boolean]
  # @return [void]
  def refresh_unlocks!(skip_sync: false)
    return if @refreshing
    @refreshing = true
    refresh_needed = !skip_sync

    while refresh_needed
      refresh_needed = false

      Recipes.keys.each do |key|
        cond = Recipes[key][:unlock_condition]
        next unless cond
        next if cond[:type] == :manual
        next if persistent?(key) && state[key] == true

        met = condition_met?(cond)
        if state[key] != met
          state[key] = met
          refresh_needed = true
        end
      end
    end

    @refreshing = false
  end

  # Return unlocked recipes.
  # @return [Array<Symbol>]
  def available_recipes
    Recipes.keys.select { |key| unlocked?(key) }
  end

  # Return locked recipes.
  # @return [Array<Symbol>]
  def locked_recipes
    Recipes.keys.reject { |key| unlocked?(key) }
  end

  # Return unlocked recipes for a category.
  # @param category [Symbol]
  # @return [Array<Symbol>]
  def recipes_by_category(category)
    Recipes.keys.select do |key|
      r = Recipes[key]
      r[:category] == category.to_sym && unlocked?(key)
    end
  end
end
