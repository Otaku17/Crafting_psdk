# ============================================================
# PFM::Bag Craft Hook
# ------------------------------------------------------------
# Records persistent item unlocks at the exact moment an item
# enters the bag, so a recipe stays unlocked even if the item
# is lost before the crafting UI is opened.
# No polling: the check only runs when add_item is called.
# ============================================================

module CraftSystem
  module BagHook
    # Add an item, then record persistent unlocks that are now met.
    # @return [Object] original add_item result
    def add_item(*args, **kwargs, &block)
      result = super
      CraftSystem.check_persistent_unlocks! if $crafting_data && $bag.equal?(self)
      result
    end
  end
end

PFM::Bag.prepend(CraftSystem::BagHook)
