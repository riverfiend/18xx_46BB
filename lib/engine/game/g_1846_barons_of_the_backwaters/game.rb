# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1846/game'

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      class Game < G1846::Game
        include Entities
        include_meta(G1846BaronsOfTheBackwaters::Meta)
        def num_extra_minors(players)
          players.size > 5 ? 2 : 1
        end
        def num_random_privates(players)
          2 + 2 * (players > 3) + 2 * (players > 4) + (players > 5)
        end
        def num_pass_companies(players)
          players.size
        end
        def create_passes(players)
          companies = super
          passes = Array.new(num_pass_companies(players)) do |i|
            name = "Pass (#{i + 1})"
            Company.new(
              sym: name,
              name: name,
              value: 0,
              desc: "Choose this card if you don't want to purchase any of the offered companies this turn.",
            )
          end
          passes
        end
        def setup
          @turn = setup_turn
          @second_tokens_in_green = {}

          # When creating a game the game will not have enough to start
          unless (player_count = @players.size).between?(*self.class::PLAYER_RANGE)
            raise GameError, "#{self.class::GAME_TITLE} does not support #{player_count} players"
          end

          remove_from_group!(orange_group, @companies) do |company|
            ability_with_icons = company.abilities.find { |ability| ability.type == 'tile_lay' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            company.close!
            @round.active_step.companies.delete(company)
          end
          remove_from_group!(blue_group, @companies) do |company|
            ability_with_icons = company.abilities.find { |ability| ability.type == 'assign_hexes' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            company.close!
            @round.active_step.companies.delete(company)
          end

          corporation_removal_groups.each do |group|
            remove_from_group!(group, @corporations) do |corporation|
              place_home_token(corporation)
              ability_with_icons = corporation.abilities.find { |ability| ability.type == 'tile_lay' }
              remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[corporation.id]) if ability_with_icons
              abilities(corporation, :reservation) do |ability|
                corporation.remove_ability(ability)
              end
              place_second_token(corporation, **place_second_token_kwargs(corporation))
            end
          end
          @log << "Privates in the game: #{@companies.reject { |c| c.name.include?('Pass') }.map(&:name).sort.join(', ')}"
          @log << "Corporations in the game: #{@corporations.map(&:name).sort.join(', ')}"

          @cert_limit = init_cert_limit

          setup_company_price_up_to_face

          @draft_finished = false

          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[0].place_token(minor, minor.next_token, free: true)
          end

          @last_action = nil
        end
      end
    end
  end
end