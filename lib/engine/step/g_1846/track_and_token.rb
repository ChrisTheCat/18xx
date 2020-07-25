# frozen_string_literal: true

require_relative '../track_and_token'
require_relative 'skip_if_presidentless'

module Engine
  module Step
    module G1846
      class TrackAndToken < TrackAndToken
        include SkipIfPresidentless
      end
    end
  end
end
