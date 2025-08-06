# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1846/game'

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      class Game < G1846::Game
        include_meta(G1846BaronsOfTheBackwaters::Meta)
      end
    end
  end
end
