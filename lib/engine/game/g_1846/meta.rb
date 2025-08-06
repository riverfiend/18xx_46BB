# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1846
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Thomas Lehmann'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1846'
        GAME_LOCATION = 'Midwest, USA'
        GAME_PUBLISHER = %i[gmt_games golden_spike].freeze
        GAME_RULES_URL = 'https://gmtwebsiteassets.s3.us-west-2.amazonaws.com/1846/1846-RULES-2021.pdf'
        GAME_SUBTITLE = 'The Race for the Midwest'
        GAME_VARIANTS = [
          {
            sym: :two_player,
            name: '2p Variant',
            title: '1846 2p Variant',
            desc: 'unofficial rules for two players',
          },
          {
            sym: :barons_of_the_backwaters,
            name: 'Barons of the Backwaters',
            title: '1846 Barons of the Backwaters',
            desc: 'TEST fan expansion by KingZombieGames',
          },
        ].freeze

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :first_ed,
            short_name: '1st Edition Private Companies',
            desc: 'Exclude the 2nd Edition companies Boomtown and Little Miami',
            players: [2, 3, 4, 5],
            
          },
          {
            sym: :second_ed_co,
            short_name: 'Guarantee 2E and C&O',
            desc: 'Ensure that Boomtown, Little Miami, and Chesapeake & Ohio Railroad are not removed during setup.',
            players: [2, 3, 4, 5],
          },
        ].freeze

        MUTEX_RULES = [
          %i[first_ed second_ed_co],
].freeze

        def self.check_options(options, _min_players, _max_players)
          optional_rules = (options || []).map(&:to_sym)
          return unless (optional_rules & %i[first_ed second_ed_co]).length == 2

          { error: 'Cannot guarantee 2nd Edition companies if using 1st Edition' }
        end
      end
    end
  end
end
