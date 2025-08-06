# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_1846/meta'

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      module Meta
        include Game::Meta
        include G1846::Meta
        DEV_STAGE = :alpha
        DEPENDS_ON = '1846'

        GAME_ALIASES = ['1846 BB'].freeze
        GAME_IS_VARIANT_OF = G1846::Meta
        GAME_RULES_URL = {
          '1846 Rules' => G1846::Meta::GAME_RULES_URL,
          '1846 Barons of the Backwater Variant Rules' => 'https://boardgamegeek.com/filepage/291500/1846bb-rules',
        }.freeze
        GAME_SUBTITLE = nil
        GAME_TITLE = '1846 Barons of the Backwaters'
        GAME_ISSUE_LABEL = '1846'
        GAME_VARIANTS = [].freeze

        PLAYER_RANGE = [3, 6].freeze
      end
    end
  end
end
