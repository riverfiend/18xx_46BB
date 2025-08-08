# frozen_string_literal: true

require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative '../g_1846/game'

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      class Game < G1846::Game
        include Entities
        include Map
        include_meta(G1846BaronsOfTheBackwaters::Meta)

        BANK_CASH = { 3 => 8000, 4 => 9500, 5 => 11000, 6 => 13000 }.freeze

        CERT_LIMIT = {
          3 => { 5 => 14, 4 => 11 },
          4 => { 7 => 14, 6 => 12, 5 => 10, 4 => 8 },
          5 => { 8 => 13, 7 => 12, 6 => 10, 5 => 8, 4 => 6 },
          6 => { 8 => 12, 7 => 10, 6 => 8, 5 => 7, 4 => 6 },
        }.freeze

        STARTING_CASH = { 3 => 400, 4 => 400, 5 => 400, 6 => 400 }.freeze

        MARKET = [
          %w[0c 10 20 30
             40p 50p 60p 70p 80p 90p 100p 112p 124p 137p 150p
             165 180 195 210 225 240 258 276 315 335 355 375 400 430 430 460 500 580 620 660 700 750 800],
           ].freeze

        REMOVABLE_MAJORS_GROUP = [
          'PRR',
          'ERIE',
          'C&O',
          'B&O',
          'IC',
        ].freeze

        REMOVABLE_MINORS_GROUP = [
          'Big 4',
          'Nashville and Northwestern',
          'Virginia Coal Company',
          'Buffalo, Rochester, and Pittsburgh',
          'Cleveland, Columbus, and Cincinnati',
        ].freeze

        MINOR_PRIVATES_GROUP = [
          'Big 4 (Minor)',
          'Nashville and Northwestern (Minor)',
          'Virginia Coal Company (Minor)',
          'Buffalo, Rochester, and Pittsburgh (Minor)',
          'Cleveland, Columbus, and Cincinnati (Minor)',
        ]

        REMOVABLE_PRIVATES_GROUP = [
          'Louisville, Cincinnati, and Lexington Railroad',
          'Bridging Company',
          'Grain Mill Company',
          'Southwestern Steamboat Company',
          'Oil and Gas Company',
          'Steamboat Company',
          'Boomtown',
          'Tunnel Blasting Company',
          'Meat Packing Company',
          'Lake Shore Line',
          'Michigan Central',
          'Ohio & Indiana',
          'Little Miami',
        ].freeze

        #def removable_majors_group
        #  @removable_majors_group ||= self.class::REMOVABLE_MAJORS_GROUP
        #end

        #def removable_minors_group
        #  @removable_minors_group ||= self.class::REMOVABLE_MINORS_GROUP
        #end

        def num_excluded_majors(players)
          case players.size
          when 3
            3
          when 4
            1
          else
            0
          end
        end

        def num_excluded_minors(players)
          4 + (players.size < 6 ? 1 : 0)
        end

        def num_random_privates(players) #
          2 + (2 * (players.size > 3 ? 1 : 0)) + (2 * (players.size > 4? 1 : 0)) + (players.size > 5 ? 1 : 0)
        end

        def num_pass_companies(players)
          players.size
        end

        def create_passes(players)
          Array.new(num_pass_companies(players)) do |i|
            name = "Pass (#{i + 1})"
            Company.new(
              sym: name,
              name: name,
              value: 0,
              desc: "Choose this card if you don't want to purchase any of the offered companies this turn.",
            )
          end
        end

        def num_removals(group)
          case group
          when REMOVABLE_MAJORS_GROUP then num_excluded_majors(players)
          when REMOVABLE_MINORS_GROUP
            num_to_remove = num_excluded_minors(players)
            puts "removing #{num_to_remove} minors"
            num_to_remove
          when REMOVABLE_PRIVATES_GROUP
            num_to_remove = group.size - num_random_privates(players)
            puts "removing #{num_to_remove} privates"
            num_to_remove
          else
            puts "buggy removal"
            0
          end
        end

        def remove_from_group!(group, entities)
          removals_group = group.dup
          removals = removals_group.sort_by { rand }.take(num_removals(group))
          return if removals.empty?

          @log << "Removing #{removals.join(', ')}"
          puts "Removing #{removals.join('; ')}"
          entities.reject! do |entity|
            if removals.include?(entity.name) || removals.include?(entity.name[0..-8])
              puts "attempting to remove #{entity.name}"
              yield entity if block_given?
              @removals << entity
              true
            else
              false
            end
          end
        end

        def setup
          @turn = setup_turn

          # When creating a game the game will not have enough to start
          unless (player_count = @players.size).between?(*self.class::PLAYER_RANGE)
            raise GameError, "#{self.class::GAME_TITLE} does not support #{player_count} players"
          end
          # First, prep the majors:
          puts "removing majors..."
          remove_from_group!(REMOVABLE_MAJORS_GROUP, @corporations) do |corporation|
            place_home_token(corporation)
            ability_with_icons = corporation.abilities.find { |ability| ability.type == 'tile_lay' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[corporation.id]) if ability_with_icons
            abilities(corporation, :reservation) do |ability|
              corporation.remove_ability(ability)
            end
          end
          # Then, select the minors:
          puts "removing minors..."
          remove_from_group!(REMOVABLE_MINORS_GROUP, @companies) do |company|
            puts "removing minor #{company.name}"
            ability_with_icons = company.abilities.find { |ability| ability.type == 'tile_lay' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            ability_with_icons = company.abilities.find { |ability| ability.type == 'assign_hexes' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            matching_private_name = company.name << " (minor)"
            if MINOR_PRIVATES_GROUP.include?(matching_private_name)
              puts "matching minor found #{matching_private_name}"
            end
            company.close! #this closes the private, but not the minor with the same name.
            @round.active_step.companies.delete(company)
          end
=begin
          # TODO: Manage the minor -> excluded private map
          # TODO: Add the CCC's extra private
          # Finally, select the privates
          puts "removing privates..."
          remove_from_group!(REMOVABLE_PRIVATES_GROUP, @companies) do |company|
            puts "removing private #{company.name}"
            ability_with_icons = company.abilities.find { |ability| ability.type == 'tile_lay' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            ability_with_icons = company.abilities.find { |ability| ability.type == 'assign_hexes' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            company.close!
            @round.active_step.companies.delete(company)
          end

          @log << "Privates in the game: #{@companies.reject { |c| c.name.include?('Pass') }.map(&:name).sort.join(', ')}"
=end
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
