# frozen_string_literal: true

module Engine
  module Step
    module G1846
      module SkipIfPresidentless
        def actions(entity)
          return [] if entity.owner == @game.share_pool

          super(entity)
        end
      end
    end
  end
end
