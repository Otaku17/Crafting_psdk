# ============================================================================
# CraftSystemUI - Layout Module
# ============================================================================
# Définit la structure visuelle de l'interface de crafting en créant
# tous les sprites nécessaires (cadres, grilles, boîtes d'ingrédients, etc.).
#
# ============================================================================

module UI
  module CraftSystemUI
    # Module responsable de la création de la mise en page visuelle
    #
    # Ce module est inclus dans Composition et fournit la méthode
    # create_box qui initialise tous les éléments graphiques de base.
    module Layout
      # Crée tous les sprites de l'interface de crafting
      #
      # Initialise les composants graphiques suivants :
      # - Cadre principal avec support multilingue (FR/EN)
      # - Grille de recettes
      # - Boîte d'ingrédients
      # - Barre de défilement
      # - Boutons de navigation (gauche/droite)
      # - Bouton de défilement (knob)
      #
      # @return [Hash{Symbol => Sprite}] Hash contenant tous les sprites créés
      # @option return [Sprite] :frame Cadre principal de l'interface
      # @option return [Sprite] :grid Grille de recettes
      # @option return [Sprite] :ing_box Boîte d'affichage des ingrédients
      # @option return [Sprite] :scroll_bar Barre de défilement verticale
      # @option return [Sprite] :left Bouton de navigation gauche
      # @option return [Sprite] :right Bouton de navigation droite
      # @option return [Sprite] :knob Bouton de défilement mobile
      #
      # @example
      #   @ui = create_box
      #   @ui[:frame]  # => Sprite du cadre
      #   @ui[:grid]   # => Sprite de la grille
      #
      # @note Les sprites sont automatiquement ajoutés au viewport parent
      def create_box 
        {
          frame: add_sprite(
            0, 0,
            'crafting/frames'
          ).src_rect.set(0, $options.language == 'fr' ? 28 : 0, 320, 28),
          grid: add_sprite(4, 34, 'crafting/grid'),
          ing_box: add_sprite(156, 34, 'crafting/ing_box'),
          scroll_bar: add_sprite(147, 35, 'crafting/scroll'),
          left: add_sprite(20, 43, 'crafting/inputs').src_rect.set(0, 0, 12, 12),
          right: add_sprite(116, 43, 'crafting/inputs').src_rect.set(12, 0, 12, 12),
          knob: add_sprite(146, Constants::KNOB_BASE_Y, 'crafting/knob')
        }
      end
    end
  end
end
