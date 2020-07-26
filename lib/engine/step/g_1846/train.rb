# frozen_string_literal: true

require_relative '../train'

module Engine
  module Step
    module G1846
      class Train < Train
        def setup
          super
          @issued = false
        end

        def actions(entity)
          return [] if entity.minor? || entity.company?

          return [] if entity.receivership?

          if entity.corporation? && must_buy_train?(entity)
            actions_ = %w[buy_train]
            actions_ += %w[buy_shares sell_shares] if can_issue?(entity)
            return actions_
          elsif entity == current_entity.owner
            return %w[sell_shares] unless can_issue?(current_entity)
          end

          return %w[buy_train pass] if can_buy_train?(entity)

          []
        end

        def skip!
          @round.receivership_train_buy(self, :process_buy_train)
        end

        # ugly hack since the view for IssueShares keys off the buy_shares
        # action being included
        def redeemable_shares(_entity)
          []
        end

        def issuable_shares(entity)
          # Done via Sell Shares
          num_shares = entity.num_player_shares - entity.num_market_shares
          bundles = entity.bundles_for_corporation(entity)

          bundles.reject! { |bundle| bundle.num_shares > num_shares }

          bundles.each do |bundle|
            directions = [:left] * (1 + bundle.num_shares)
            bundle.share_price = @game.stock_market.find_share_price(entity, directions).price
          end

          # cannot issue shares that generate no money; this is errata from BGG
          # and differs from the GMT rulebook
          # https://boardgamegeek.com/thread/2094996/article/30495755#30495755
          bundles.reject! { |bundle| bundle.price.zero? }

          if bundles.any? { |b| (entity.cash + b.price) >= @depot.min_depot_train.price }
            bundles.reject! { |b| (entity.cash + b.price) < @depot.min_depot_train.price }
          end

          bundles
        end

        def process_sell_shares(action)
          return process_issue_shares(action) if action.entity.corporation?

          if can_issue?(@round.current_entity)
            raise GameError, 'President may not sell shares while corporation can issues shares.'
          end

          super
        end

        private

        def can_issue?(entity)
          return false unless entity.corporation?
          return false unless entity.cash < @depot.min_depot_train.price
          return false unless issuable_shares(entity).any?
          return false if @issued

          true
        end

        def process_issue_shares(action)
          corporation = action.entity
          bundle = action.bundle

          if !can_issue?(corporation) || !issuable_shares(corporation).include?(bundle)
            raise GameError, "#{corporation.name} cannot issue share bundle: #{bundle.shares}"
          end

          @game.share_pool.sell_shares(bundle)

          price = corporation.share_price.price
          bundle.num_shares.times { @game.stock_market.move_left(corporation) }
          @game.log_share_price(corporation, price)

          @issued = true
        end
      end
    end
  end
end
