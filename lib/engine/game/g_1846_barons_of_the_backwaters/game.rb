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

        BANK_CASH = { 3 => 8000, 4 => 9500, 5 => 11_000, 6 => 13_000 }.freeze

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
        ].freeze

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

        ABILITY_ICONS = {
          SC: 'port',
          SWSC: 'swport',
          MPC: 'meat',
          GMC: 'grain',
          LSL: 'lsl',
          BT: 'boom',
          OG: 'oil',
          LM: 'lm',
          IC: 'ic',
        }.freeze

        GRAIN_HEXES = %w[G3 C9 J12].freeze

        SOUTHWEST_STEAMBOAT_HEXES = %w[B8 C5 D14 I1 G19].freeze

        BOOMTOWN_HEXES = %w[H12 J10].freeze

        OILGAS_HEXES = %w[G19 G15 E21].freeze

        CCCI_HEXES = %w[G15 F16].freeze

        OILGAS_REVENUE_DESC = "Oil/Gas"

        GRAIN_REVENUE_DESC = "Grain Mill"

        SWSTEAMBOAT_REVENUE_DESC = "SWSC Port"

        STEAMBOAT_REVENUE_DESC = "SC Port"

        ASSIGNMENT_TOKENS = {
          'MPC' => '/icons/1846/mpc_token.svg',
          'GMC' => '/icons/1846/gmc_token.svg',
          'SC' => '/icons/1846/sc_token.svg',
          'SWSC' => '/icons/1846/swsc_token.svg',
          'BT' => '/icons/1846/bt_token.svg',
          'OG' => '/icons/1846/og_token.svg',
        }.freeze

        def grain_mill
          @grain_mill ||= company_by_id('GMC')
        end

        def swsteamboat
          @swsteamboat ||= company_by_id('SWSC')
        end

        def oilgas
          @oilgas ||= company_by_id('OGC')
        end

        def ccci
          @ccci ||= company_by_id('CC&C')
        end

        def num_excluded_majors(players)
          case players.size
          when 3 then 3
          when 4 then 1
          else 0
          end
        end

        def num_excluded_minors(players)
          3 + (players.size < 6 ? 1 : 0)
        end

        def num_random_privates(players)
          2 + (players.size > 3 ? 2 : 0) + (players.size > 4 ? 2 : 0) + (players.size > 5 ? 1 : 0)
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
          when REMOVABLE_MINORS_GROUP, MINOR_PRIVATES_GROUP then num_excluded_minors(players)
          when REMOVABLE_PRIVATES_GROUP then group.size - num_random_privates(players) - @force_exclude_companies.size - @ccc_extra
          else
            puts 'buggy removal'
            raise GameError, 'Something has Gone Wrong -- Buggy removal'
          end
        end

        def remove_from_group!(group, entities)
          removals_group = group.dup
          @force_exclude_companies&.each do |excluded_private|
            removals_group.delete(excluded_private)
          end
          removals = removals_group.sort_by { rand }.take(num_removals(group))
          return if removals.empty?

          @log << "Removing #{removals.join(', ')}"
          puts "Removing #{removals.join('; ')}"
          entities.reject! do |entity|
            if removals.include?(entity.name) || removals.include?(entity.name[0..-8])
              yield entity if block_given?
              removals << entity
              true
            else
              false
            end
          end
        end

        def private_excluded(minor)
          case minor
          when 'BRP' then 'Lake Shore Line'
          when 'VCC' then 'Tunnel Blasting Company'
          when 'NNI' then 'Bridging Company'
          when 'CC&C' then 'Ohio & Indiana'
          when 'BIG4', 'MS' then 'NOT_A_PRIVATE'
          end
        end

        def setup
          @turn = setup_turn
          @ccc_extra = 0
          @force_exclude_companies = []
          # When creating a game the game will not have enough to start
          unless (player_count = @players.size).between?(*self.class::PLAYER_RANGE)
            raise GameError, "#{self.class::GAME_TITLE} does not support #{player_count} players"
          end

          # First, prep the majors:
          remove_from_group!(REMOVABLE_MAJORS_GROUP, @corporations) do |corporation|
            place_home_token(corporation)
            ability_with_icons = corporation.abilities.find { |ability| ability.type == 'tile_lay' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[corporation.id]) if ability_with_icons
            abilities(corporation, :reservation) do |ability|
              corporation.remove_ability(ability)
            end
          end
          # Then, select the minors:
          @removed_minors = []
          remove_from_group!(MINOR_PRIVATES_GROUP, @companies) do |minor|
            @removed_minors.push(minor.id)
            ability_with_icons = minor.abilities.find { |ability| ability.type == 'assign_hexes' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[minor.id]) if ability_with_icons #only the CC&C has an icon
            minor.close!
            @round.active_step.companies.delete(minor)
          end


          @companies.each do |company|
            next unless company.name.include? 'Minor'

            @force_exclude_companies.push(private_excluded(company.id))
            if company.id == 'CC&C'
              @log << "The CC&C is included, adding an extra private."
              @ccc_extra = 1
            end
          end
          @force_exclude_companies.delete('NOT_A_PRIVATE')
          @force_exclude_companies.each do |excluded_private|
            @companies.each do |company|
              next unless company.name.include? excluded_private
              @log << "Removing #{company.name}, and drawing a replacement."
              ability_with_icons = company.abilities.find { |ability| ability.type == 'tile_lay' }
              remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
              ability_with_icons = company.abilities.find { |ability| ability.type == 'assign_hexes' }
              remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
              company.close!
              @round.active_step.companies.delete(company)
              @companies.delete(company)
            end
          end
          # Finally, select the privates
          remove_from_group!(REMOVABLE_PRIVATES_GROUP, @companies) do |company|
            ability_with_icons = company.abilities.find { |ability| ability.type == 'tile_lay' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            ability_with_icons = company.abilities.find { |ability| ability.type == 'assign_hexes' }
            remove_icons(ability_with_icons.hexes, self.class::ABILITY_ICONS[company.id]) if ability_with_icons
            company.close!
            @round.active_step.companies.delete(company)
          end

          @log << "#{@corporations.size} corporations in the game: #{@corporations.map(&:name).sort.join(', ')}"
          minors_in_game = @companies.reject { |c| !c.name.include?('Minor') }
          @log << "#{minors_in_game.size} Minors in the game: #{minors_in_game.map(&:name).sort.join(', ')}"
          privates_in_game = @companies.reject { |c| c.name.include?('Pass') || c.name.include?('Minor') }
          @log << "#{privates_in_game.size} privates in the game: #{privates_in_game.map(&:name).sort.join(', ')}"

          @cert_limit = init_cert_limit

          setup_company_price_up_to_face

          @draft_finished = false

          @minors.each do |minor|
            if @removed_minors.include?(minor.name)
              minor.close!
              next
            end

            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)
            hex = hex_by_id(minor.coordinates)
            hex.tile.cities[0].place_token(minor, minor.next_token, free: true)
          end

          @last_action = nil
        end

        def preprocess_action(action)
          preprocess_upgrade_to_connect(action)
          check_special_tile_lay(action) unless psuedo_special_tile_lay?(action)
        end

        def ccci_router
          @ccci_router ||=
            Engine::Corporation.new(name: 'CC&C Corp', sym: 'CC&C Corp', tokens: [], coordinates: CCCI_HEXES.first)
        end

        def compute_ccci_graph
          graph = Graph.new(self, no_blocking: true, home_as_token: true)
          graph.compute(ccci_router)
          graph
        end

        def upgrade_to_connect_action?(action)
          (action.entity == little_miami || action.entity == ccci) &&
            (action.is_a?(Action::LayTile) || action.is_a?(Action::Pass))
        end

        def preprocess_upgrade_to_connect(action)
          return unless upgrade_to_connect_action?(action)
          case action.entity
          when little_miami
            @little_miami_hexes_laid ||= []
            check_little_miami_graph_before! if @little_miami_hexes_laid.empty?
          when ccci
            @ccci_hexes_laid ||= []
            check_ccci_graph_before! if @ccci_hexes_laid.empty?
          end

          return unless action.is_a?(Action::LayTile)

          hex = action.hex
          case action.entity
          when little_miami
            @little_miami_before_exits ||= {}
            @little_miami_before_exits[hex.id] = hex.tile.exits.dup
          when ccci
            @ccci_before_exits ||= {}
            @ccci_before_exits[hex.id] = hex.tile.exits.dup
          end
        end

        def postprocess_upgrade_to_connect(action)
          return unless upgrade_to_connect_action?(action)

          if action.is_a?(Action::LayTile)
            hex = action.hex
            case action.entity
            when little_miami
              @little_miami_new_exits ||= {}
              @little_miami_new_exits[hex.id] = hex.tile.exits.dup - @little_miami_before_exits[hex.id]
              if @little_miami_hexes_laid == [hex]
                raise GameError, 'Cannot lay and upgrade a tile in the same hex with Little Miami'
              end
              @little_miami_hexes_laid << hex
            when ccci
              @ccci_new_exits ||= {}
              @ccci_new_exits[hex.id] = hex.tile.exits.dup - @ccci_before_exits[hex.id]
              if @ccci_hexes_laid == [hex]
                raise GameError, 'Cannot lay and upgrade a tile in the same hex with CC&C'
              end
              @ccci_hexes_laid << hex
            end 
          end

          return if abilities(action.entity, :tile_lay)
          case action.entity
          when little_miami
            check_little_miami_graph_after!
            remove_icons(self.class::LITTLE_MIAMI_HEXES, self.class::ABILITY_ICONS[little_miami.id])
          when ccci
            check_ccci_graph_after!
            remove_icons(self.class::CCCI_HEXES, self.class::ABILITY_ICONS[ccci.id])
          end
        end

        def check_ccci_graph_before!
          return if loading

          graph = compute_ccci_graph
          reached_hexes = graph.connected_nodes(ccci_router).select { |_k, v| v }.keys.map { |n| n.hex.id }

          return unless (CCCI_HEXES & reached_hexes) == CCCI_HEXES

          raise GameError, "#{CCCI_HEXES.join(' and ')} are already connected, cannot use CC&C"
        end

        def check_ccci_graph_after!
          return if loading

          graph = compute_ccci_graph
          reached_hexes = graph.connected_nodes(ccci_router).select { |_k, v| v }.keys.map { |n| n.hex.id }
          if (CCCI_HEXES & reached_hexes) != CCCI_HEXES
            raise GameError, "#{CCCI_HEXES.join(' and ')} must be connected after using CC&C"
          end

          new_paths_by_hex = @ccci_new_exits.map do |hex_id, exits|
            paths = exits.flat_map do |exit|
              graph.connected_paths(ccci_router).keys.select do |path|
                path.hex.id == hex_id && path.exits.include?(exit)
              end
            end
            [hex_id, paths]
          end

          return if new_paths_by_hex.all? do |hex_id, new_paths_on_hex|
            ccci_a_new_path_used_for_connection?(hex_id, new_paths_on_hex)
          end

          raise GameError, 'Some new track on each tile laid by CC&C must '\
                           "be used to connect #{CCCI_HEXES.join(' and ')}"
        end

        def ccci_a_new_path_used_for_connection?(hex_id, new_paths)
          node = hex_by_id(hex_id).tile.cities.first

          other_hex_id = CCCI_HEXES.find { |h| h != hex_id }
          other_node = hex_by_id(other_hex_id).tile.cities.first

          node.walk do |_path, visited_paths, visited_nodes|
            return true if visited_nodes[other_node] && new_paths.any? { |p| visited_paths[p] }
          end

          false
        end



        def revenue_for(route, stops)
          revenue = super
          # This should properly process the base-game privates
          # and east-west bonuses

          [
            [oilgas, 20],
            [grain_mill, 30],
            [swsteamboat, 20, 'swport'],
          ].each do |company, bonus_revenue, icon|
            id = company&.id
            if id && route.corporation.assigned?(id) && (assigned_stop = stops.find { |s| s.hex.assigned?(id) })
              revenue += bonus_revenue * (icon ? assigned_stop.hex.tile.icons.count { |i| i.name == icon } : 1)
            end
          end

          revenue += north_south_bonus(stops)[:revenue]

          revenue
        end

        def north_south_bonus(stops)
          bonus = { revenue: 0 }

          north = stops.find { |stop| stop.tile.label&.to_s() == 'N/W' } # there's only one N on the map, it's Chicago -- TODO: Make sure that's final
          south = stops.find { |stop| stop.tile.label&.to_s() == 'S/W' } # there's only one S on the map, it's Nashville -- TODO: Make sure that's final

          if north && south
            bonus[:revenue] += north.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:revenue] += south.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:description] = 'N/S'
          end

          bonus
        end

        def east_west_bonus(stops)
          bonus = { revenue: 0 }

          east = stops.find { |stop| stop.groups.include?('E') }
          west = stops.find { |stop| ((stop.tile.label&.to_s() == 'W') || (stop.tile.label&.to_s() == 'S/W') || (stop.tile.label&.to_s() == 'N/W')) }

          if east && west
            bonus[:revenue] += east.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:revenue] += west.tile.icons.sum { |icon| icon.name.to_i }
            bonus[:description] = 'E/W'
          end

          bonus
        end

        def revenue_str(route)
          stops = route.stops
          stop_hexes = stops.map(&:hex)
          str = route.hexes.map do |h|
            stop_hexes.include?(h) ? h&.name : "(#{h&.name})"
          end.join('-')

          [
            [oilgas, self.class::OILGAS_REVENUE_DESC],
            [grain_mill, self.class::GRAIN_REVENUE_DESC],
            [swsteamboat, self.class::SWSTEAMBOAT_REVENUE_DESC],
            [boomtown, self.class::BOOMTOWN_REVENUE_DESC],
            [meat_packing, self.class::MEAT_REVENUE_DESC],
            [steamboat, self.class::STEAMBOAT_REVENUE_DESC],
          ].each do |company, desc|
            id = company&.id
            str += " + #{desc}" if id && route.corporation.assigned?(id) && stops.any? { |s| s.hex.assigned?(id) }
          end

          nsbonus = north_south_bonus(stops)[:description]
          ewbonus = east_west_bonus(stops)[:description]
          str += " + #{nsbonus}" if nsbonus
          str += " + #{ewbonus}" if ewbonus

          if route.train.owner.companies.include?(mail_contract)
            longest = route.routes.max_by { |r| [r.visited_stops.size, r.train.id] }
            str += ' + Mail Contract' if route == longest
          end

          str
        end

        def east_west_desc
          'cross-map'
        end

        def event_remove_bonuses!
          removals = Hash.new { |h, k| h[k] = {} }

          @corporations.each do |corp|
            corp.assignments.dup.each do |company, _|
              removals[company][:corporation] = corp.name
              corp.remove_assignment!(company)
            end
          end

          @hexes.each do |hex|
            hex.assignments.dup.each do |company, _|
              removals[company][:hex] = hex.name
              hex.remove_assignment!(company)
            end
          end

          remove_icons(self.class::BOOMTOWN_HEXES, self.class::ABILITY_ICONS['BT'])
          remove_icons(self.class::OILGAS_HEXES, self.class::ABILITY_ICONS['OG'])
          remove_icons(self.class::MEAT_HEXES, self.class::ABILITY_ICONS['MPC'])
          remove_icons(self.class::GRAIN_HEXES, self.class::ABILITY_ICONS['GMC'])
          remove_icons(self.class::STEAMBOAT_HEXES, self.class::ABILITY_ICONS['SC'])
          remove_icons(self.class::SOUTHWEST_STEAMBOAT_HEXES, self.class::ABILITY_ICONS['SWSC'])

          removals.each do |company, removal|
            hex = removal[:hex]
            corp = removal[:corporation]
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} bonus removed from #{hex} --"
          end
        end



        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1846BaronsOfTheBackwaters::Step::SCAssign,
            G1846BaronsOfTheBackwaters::Step::SWSCAssign,
            G1846::Step::BuySellParShares,
            Engine::Step::HomeToken,
          ])
        end

        def operating_round(round_num)
          @round_num = round_num
          G1846::Round::Operating.new(self, [
            G1846::Step::Bankrupt,
            G1846BaronsOfTheBackwaters::Step::SCAssign,
            G1846BaronsOfTheBackwaters::Step::SWSCAssign,
            Engine::Step::SpecialToken,
            G1846BaronsOfTheBackwaters::Step::SpecialTrack,
            G1846::Step::BuyCompany,
            G1846::Step::IssueShares,
            G1846BaronsOfTheBackwaters::Step::TrackAndToken,
            Engine::Step::Route,
            G1846::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1846::Step::BuyTrain,
            [G1846::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
