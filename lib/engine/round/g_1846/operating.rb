# frozen_string_literal: true

require_relative '../operating'
require_relative '../../action/dividend'
require_relative '../../action/run_routes'

module Engine
  module Round
    module G1846
      class Operating < Operating
        def select_entities
          corporations = @game.corporations.select(&:floated?)
          if @game.turn == 1 && @round_num == 1
            corporations.sort_by! do |c|
              sp = c.share_price
              [sp.price, sp.corporations.find_index(c)]
            end
          else
            corporations.sort!
          end
          @game.minors + corporations
        end

        def after_process(action)
          if (entity = @entities[@entity_index]).owner.pool?
            case action
            when Engine::Action::Bankrupt
              attempt_to_buy_train_no_president(self, :process_action) unless @game.bankruptcy_limit_reached?
            when Engine::Action::RunRoutes
              process_action(Engine::Action::Dividend.new(entity, kind: 'withhold'))
            end
          end

          super
        end

        def attempt_to_buy_train_no_president(obj, method)
          entity = @entities[@entity_index]

          return unless entity.owner.pool?

          return unless entity.trains.empty?

          train = @game.depot.min_depot_train
          name, variant = train.variants.min_by { |_, v| v[:price] }
          price = variant[:price]

          return if entity.cash < price

          action = Action::BuyTrain.new(
            entity,
            train: train,
            price: price,
            variant: name,
          )

          obj.send(method, action)
        end
      end
    end
  end
end
