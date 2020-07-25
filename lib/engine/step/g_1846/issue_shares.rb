# frozen_string_literal: true

require_relative '../issue_shares'
require_relative 'skip_if_presidentless'

module Engine
  module Step
    module G1846
      class IssueShares < IssueShares
        include SkipIfPresidentless
      end
    end
  end
end
