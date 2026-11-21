# ============================================================
# CraftSystem — Conditions
# ------------------------------------------------------------
# Condition evaluation.
# Responsible for:
#   - Single conditions (switch, variable, quest, recipe, item,
#     pokemon, manual)
#   - Operator conditions (and / or / not)
#   - Pokemon matching (party + PC)
# ============================================================

module CraftSystem
  module_function

  # Evaluate a condition structure.
  # @param condition [Hash, Array]
  # @return [Boolean]
  def condition_met?(condition)
    return true unless condition

    if condition.is_a?(Array)
      condition.all? { |c| condition_met?(c) }
    elsif condition.is_a?(Hash) && condition[:operator]
      evaluate_operator_conditions(condition)
    else
      evaluate_single_condition(condition)
    end
  end

  # Evaluate a single condition.
  # @param condition [Hash]
  # @return [Boolean]
  def evaluate_single_condition(condition)
    case condition[:type]
    when :switch
      $game_switches[condition[:id]]
    when :variable
      $game_variables[condition[:id]] >= condition.fetch(:value, 1)
    when :quest
      $quests&.finished?(condition[:id]) || false
    when :recipe
      key = condition[:key].to_sym
      state.key?(key) && unlocked?(key)
    when :item
      has_item_quantity?(condition[:item], condition.fetch(:quantity, 1))
    when :pokemon
      evaluate_pokemon_condition(condition)
    when :manual
      condition.fetch(:value, false)
    else
      false
    end
  end

  # Evaluate operator-based conditions (:and, :or, :not).
  # @param condition [Hash]
  # @return [Boolean]
  def evaluate_operator_conditions(condition)
    op = condition[:operator]
    conds = condition[:conditions] || []

    case op
    when :and, :all
      conds.all? { |c| condition_met?(c) }
    when :or, :any
      conds.any? { |c| condition_met?(c) }
    when :not, :none
      conds.none? { |c| condition_met?(c) }
    else
      false
    end
  end

  # Check if the player owns at least one Pokemon matching all specified attributes.
  # Searches both the party ($actors) and the PC storage ($storage).
  # All fields are optional — only the ones present in the condition are checked.
  #
  # Supported fields:
  #   :db_symbol      [Symbol]  Species db_symbol (e.g. :pikachu)
  #   :min_loyalty    [Integer] Minimum loyalty/happiness value (0–255)
  #   :min_level      [Integer] Minimum level
  #   :move           [Symbol]  db_symbol of a move the Pokemon must know
  #   :ability        [Symbol]  db_symbol of the ability the Pokemon must have
  #   :holding_item   [Symbol]  db_symbol of the item the Pokemon must hold
  #   :gender         [Integer] 0 = genderless, 1 = male, 2 = female
  #   :form           [Integer] Form index (e.g. 0 = default, 29 = Mega)
  #   :shiny          [Boolean] true = must be shiny, false = must not be shiny
  #
  # @param condition [Hash]
  # @return [Boolean]
  def evaluate_pokemon_condition(condition)
    all_player_pokemon.any? do |pokemon|
      next false unless pokemon
      next false if condition[:db_symbol]    && pokemon.db_symbol != condition[:db_symbol]
      next false if condition[:min_loyalty]  && pokemon.loyalty < condition[:min_loyalty]
      next false if condition[:min_level]    && pokemon.level < condition[:min_level]
      next false if condition[:move]         && pokemon.skills_set.none? { |s| s&.db_symbol == condition[:move] }
      next false if condition[:ability]      && pokemon.ability_db_symbol != condition[:ability]
      next false if condition[:holding_item] && pokemon.item_holding != data_item(condition[:holding_item])&.id
      next false if condition[:gender]       && pokemon.gender != condition[:gender]
      next false if condition.key?(:form)    && pokemon.form != condition[:form]
      next false if condition.key?(:shiny)   && pokemon.shiny? != condition[:shiny]
      true
    end
  end

  # Return all Pokemon owned by the player: party + PC storage.
  # Uses $storage.each_pokemon which is the official PSDK iteration API.
  # @return [Array<PFM::Pokemon>]
  def all_player_pokemon
    party = $actors.compact
    box   = []
    $storage&.each_pokemon { |pokemon| box << pokemon if pokemon }
    party + box
  end
end
