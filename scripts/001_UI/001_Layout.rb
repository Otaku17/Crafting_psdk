# ============================================================
# UI::CraftSystemUI::Layout
# ------------------------------------------------------------
# Module handling the base layout creation of the Craft System UI.
# Responsible for building all static interface sprites such as
# frame, grid background, ingredient box, scroll bar and buttons.
# ============================================================

module UI
  module CraftSystemUI
    module Layout

      # Create the base crafting UI layout.
      # Initializes and positions all static sprites composing
      # the interface structure.
      #
      # Elements created:
      # - Main frame (language dependent)
      # - Recipe grid background
      # - Ingredient display box
      # - Vertical scroll bar
      # - Left and right navigation buttons
      # - Scroll knob sprite
      #
      # @return [Hash{Symbol => Sprite}] collection of created UI sprites
      def create_box
        {
          frame: add_sprite(
            0, 0,
            'crafting/frames'
          ).src_rect.set(
            0,
            $options.language == 'fr' ? 28 : 0,
            320,
            28
          ),

          grid: add_sprite(4, 34, 'crafting/grid'),

          ing_box: add_sprite(156, 34, 'crafting/ing_box'),

          scroll_bar: add_sprite(147, 35, 'crafting/scroll'),

          left: add_sprite(
            20, 43,
            'crafting/inputs'
          ).src_rect.set(0, 0, 12, 12),

          right: add_sprite(
            116, 43,
            'crafting/inputs'
          ).src_rect.set(12, 0, 12, 12),

          knob: add_sprite(
            146,
            Constants::KNOB_BASE_Y,
            'crafting/knob'
          )
        }
      end
    end
  end
end
