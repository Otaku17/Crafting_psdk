# ============================================================
# GamePlay Craft System Entry
# ------------------------------------------------------------
# Provides access to the Craft System UI scene.
# ============================================================

module GamePlay
  class << self

    # Craft System UI class reference.
    # @return [Class]
    attr_accessor :craft_system_class

    # Open the Craft System UI scene.
    # @param categories [Array<Symbol>, nil] Optional list of category symbols to display.
    #   If nil, all categories are shown including the :all tab.
    #   If a single category is passed, the :all tab is hidden automatically.
    #   If 2+ categories are passed, the :all tab is shown alongside them.
    # @return [void]
    #
    # @example Show all categories (with :all tab)
    #   GamePlay.open_craft_system_ui
    #
    # @example Show only ball and medical (with :all tab)
    #   GamePlay.open_craft_system_ui([:ball, :medical])
    #
    # @example Show a single category (no :all tab)
    #   GamePlay.open_craft_system_ui([:tm])
    def open_craft_system_ui(categories = nil)
      resolved = resolve_categories(categories)
      current_scene.call_scene(craft_system_class, resolved)
    end

    private

    # Resolve which categories to pass to the UI.
    # Strips :all — it is added automatically when 2+ categories are visible.
    # @param categories [Array<Symbol>, nil]
    # @return [Array<Symbol>, nil]
    def resolve_categories(categories)
      return nil if categories.nil?

      filtered = Array(categories).map(&:to_sym).reject { |c| c == :all }
      return filtered if filtered.size <= 1

      [:all] + filtered
    end

  end
end
