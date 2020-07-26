# frozen_string_literal: true

module Engine
  module Step
    module G1846
      module SkipIfPresidentless
        def actions(entity)
          entity.owner.pool? ? [] : super
        end
      end
    end
  end
end
