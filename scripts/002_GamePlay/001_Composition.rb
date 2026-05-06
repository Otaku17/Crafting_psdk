# ============================================================
# UI::CraftSystemUI::Composition
# ------------------------------------------------------------
# Main composition class of the Craft System UI.
# Coordinates layout, navigation, grid rendering,
# ingredient display and summary panel.
# ============================================================

module UI
  module CraftSystemUI
    class Composition < SpriteStack
      include Constants
      include DataProvider
      include Layout
      include Texts
      include RecipeGrid
      include RecipeDetail
      include Navigation
      include Summary

      attr_reader :recipes, :recipe_index

      # Initialize the crafting UI composition.
      # @param viewport [Viewport]
      # @param categories [Array<Symbol>, nil] Optional category filter.
      #   If nil, all categories defined in the config are shown.
      # @return [void]
      def initialize(viewport, categories = nil)
        super(viewport, 0, 0, default_cache: :interface)

        @allowed_categories = categories&.map(&:to_sym)

        @mode = :select
        @category_index = 0
        @recipe_index   = 0
        @scroll_row     = 0

        @categories = filtered_categories
        @recipes    = recipes_for(current_category)

        @ui = create_box
        create_texts
        create_recipe_grid

        @ingredient_rows = []

        refresh
      end

      # Update animated elements.
      # @return [void]
      def update
        @cursor&.update
      end

      # Always active (engine compatibility).
      # @return [Boolean]
      def done?
        true
      end

      # Change the current UI mode.
      # @param value [Symbol]
      # @return [void]
      def mode=(value)
        return if @mode == value
        @mode = value
        on_mode_changed
      end

      # Handle mode transitions.
      # @return [void]
      def on_mode_changed
        case @mode
        when :select
          exit_information_mode
        when :information
          enter_information_mode
        end
      end

      # Enter information mode.
      # Displays the summary panel.
      # @return [void]
      def enter_information_mode
        show_summary(current_recipe)
      end

      # Exit information mode.
      # Restores grid and ingredient display.
      # @return [void]
      def exit_information_mode
        show_grid
        show_ingredients
        hide_summary
      end

      # Hide recipe grid and cursor.
      # @return [void]
      def hide_grid
        @cursor.visible = false
      end

      # Show recipe grid and cursor.
      # @return [void]
      def show_grid
        @recipe_slots.each { |s| s[:sprite]&.visible = true if s[:sprite] }
        @cursor.visible = true
      end

      # Hide ingredient rows.
      # @return [void]
      def hide_ingredients
        @ingredient_rows.each(&:hide)
      end

      # Show ingredient rows.
      # @return [void]
      def show_ingredients
        @ingredient_rows.each(&:show)
      end

      # Return the currently selected recipe.
      # @return [Symbol, nil]
      def current_recipe
        @recipes[@recipe_index]
      end

      # Return formatted data of the selected recipe.
      # @return [Hash, nil]
      def current_recipe_data
        recipe_data(current_recipe)
      end

      # Perform crafting and refresh UI.
      # @param amount [Integer]
      # @return [Boolean]
      def craft(amount)
        return false unless CraftSystem.craft(current_recipe, amount)
        refresh
        true
      end

      # Refresh grid and ingredient display.
      # @return [void]
      def refresh
        return if @recipes.empty?

        refresh_recipe_grid(@recipes)

        data = current_recipe_data
        refresh_ingredients(data) if data
      end

      # Return current category symbol.
      # @return [Symbol]
      def current_category
        @categories[@category_index]
      end

      # Return formatted category name.
      # @return [String]
      def category_name
        CraftSystem::Recipes.category_name(current_category)
      end

      private

      # Return categories to display in the UI.
      # If @allowed_categories is set (resolved by GamePlay.open_craft_system_ui),
      # use that list directly — :all inclusion is already handled at call site.
      # If nil, return all categories from config.
      # @return [Array<Symbol>]
      def filtered_categories
        return categories unless @allowed_categories
        @allowed_categories
      end
    end
  end
end
