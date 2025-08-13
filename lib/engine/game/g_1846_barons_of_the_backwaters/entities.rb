# frozen_string_literal: true

require_relative '../g_1846/entities'

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      module Entities
        COMPANIES = [
          {
            name: 'Louisville, Cincinnati, and Lexington Railroad',
            value: 40,
            revenue: 15,
            desc: 'Owning corporation may lay up to two extra yellow tiles '\
                  'in reserved hexes I3, J14, and K13, receiving a discount of $20 for each tile laid. '\
                  'Owning corporation does not need to be connected to either hex to use this ability.',
            sym: 'LC&LR',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[I13 J14 K13] },
                        {
                          type: 'tile_lay',
                          when: 'owning_corp_or_turn',
                          owner_type: 'corporation',
                          free: false,
                          discount: 20,
                          must_lay_together: true,
                          connect: false,
                          hexes: %w[I13 J14 K13],
                          tiles: %w[7 8 9],
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Bridging Company',
            value: 60,
            revenue: 20,
            desc: 'Reduces the cost of laying tiles on water tiles (hexes with a $WATER_SYMBOL) and '\
                  'connecting hexes with bridges (blue hex edges) by $20 for the owning corporation.',
            sym: 'BC',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'water',
                owner_type: 'corporation',
                exact_match: false,
              },
            ],
            color: nil,
          },
          {
            name: 'Grain Mill Company',
            value: 70,
            revenue: 25,
            desc: 'TODO: Owning corporation may place a special green tile on one of Springfield (G3), '\
                  'South Bend (C9), or Lexington (J12), even in the yellow phase. This action counts '\
                  'as part of the corporation\'s tile lay for the turn.'\
                  'The owning corporation may also assign a Mill Marker to the tile after placing it. '\
                  'This marker pays an additional $30 revenue to all companies\' routes to this location '\
                  'The special contains space for one token, this space is reserved for the owning corporation. '\
                  'The owning corporation may place an extra token on this space during its normal tile/token '\
                  'laying step. This token costs $60, or $80 as a teleport. The company closes and the Mill Marker '\
                  'is removed immediately when the brown phase begins. If a token already exists in this location, '\
                  'the owning corporation may still place a token as if there were two token spaces.',
            sym: 'GMC',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[G3 C9 J12],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Southwestern Steamboat Company',
            value: 40,
            revenue: 10,
            desc: 'Add a bonus to the value of one port city, either a $40 bonus to Evansville (J6) '\
                  'or a $20 bonus to (I17) / (K3) / (L8) / St. Louis (I1). '\
                  'At the beginning of each OR, this company\'s owner may reassign this bonus '\
                  'to a different port city and/or train company (including minors). '\
                  'Once purchased by a corporation, it becomes permanently assigned to that corporation. '\
                  'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
            sym: 'SWSC',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[I17 K3 L8 I1 J6],
                count_per_or: 1,
                when: 'or_start',
                owner_type: 'player',
              },
              {
                type: 'assign_corporation',
                count_per_or: 1,
                when: 'or_start',
                owner_type: 'player',
              },
              {
                type: 'assign_hexes',
                when: %w[track_and_token route],
                hexes: %w[I17 K3 L8 I1 J6],
                count_per_or: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Oil and Gas Company',
            value: 40,
            revenue: 10,
            desc: 'Add a $20 bonus to one of the oil/gas locations (G19, G15, E21) for the assigned company.'\
                  'At the beginning of each OR, this company\'s owner may reassign this bonus '\
                  'to a different port city and/or train company (including minors). '\
                  'Once purchased by a corporation, it becomes permanently assigned to that corporation. '\
                  'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
            sym: 'OGC',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[G19 G15 E21],
                count_per_or: 1,
                when: 'or_start',
                owner_type: 'player',
              },
              {
                type: 'assign_corporation',
                count_per_or: 1,
                when: 'or_start',
                owner_type: 'player',
              },
              {
                type: 'assign_hexes',
                when: %w[track_and_token route],
                hexes: %w[G19 G15 E21],
                count_per_or: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Steamboat Company',
            value: 40,
            revenue: 10,
            desc: 'Add a bonus to the value of one port city, either a $40 bonus to Wheeling (G19) / Holland (B8) '\
                  'or a $20 bonus to Chicago Conn. (C5) / Toledo (D14) / St. Louis (I1). '\
                  'At the beginning of each OR, this company\'s owner may reassign this bonus '\
                  'to a different port city and/or train company (including minors). '\
                  'Once purchased by a corporation, it becomes permanently assigned to that corporation. '\
                  'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
            sym: 'SC',
            abilities: [
              {
                type: 'assign_hexes',
                hexes: %w[B8 C5 D14 I1 G19],
                count_per_or: 1,
                when: 'or_start',
                owner_type: 'player',
              },
              {
                type: 'assign_corporation',
                count_per_or: 1,
                when: 'or_start',
                owner_type: 'player',
              },
              {
                type: 'assign_hexes',
                when: %w[track_and_token route],
                hexes: %w[B8 C5 D14 I1 G19],
                count_per_or: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Boomtown',
            sym: 'BT',
            value: 40,
            revenue: 10,
            desc: 'Adds a $20 bonus to Cincinnati (H12) or Louisville (J10) for the owning corporation. '\
                  'Bonus must be assigned after being purchased by a corporation. '\
                  'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[H12 J10],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Michigan Southern (Minor)',
            value: 60,
            discount: -80,
            revenue: 0,
            desc: 'Starts with $60, a 2 train, and a token in Detroit (C15). Always operates first. Its train may run in OR1. '\
                  'Splits dividends equally with owner. Purchasing company receives its cash, train and token '\
                  'but cannot run this 2 train in the same OR in which the MS operated. ',
            sym: 'MS',
            color: nil,
          },
          {
            name: 'Big 4 (Minor)',
            value: 40,
            discount: -60,
            revenue: 0,
            desc: 'Starts with $40, a 2 train, and a token in Indianapolis (G9). '\
                  'Always operates after the MS and before other corporations. '\
                  'Its train may run in OR1. '\
                  'Splits dividends equally with owner. Purchasing company receives its cash, train and token '\
                  'but cannot run this 2 train in the same OR in which the BIG4 operated. '\
                  'If this company is in the game, the game begins with an extra tile in Indianapolis (G9), '\
                  'connecting to F10 and G7 (TODO)',
            sym: 'BIG4',
            color: nil,
          },
          {
            name: 'Nashville and Northwestern (Minor)',
            value: 40,
            discount: -60,
            revenue: 0,
            desc: 'Starts with $40, a 2 train, and a token in Nashville (L8). '\
                  'Always operates after the MS and before other corporations. '\
                  'Its train may run in OR1. '\
                  'Splits dividends equally with owner. Purchasing company receives its cash, train and token '\
                  'but cannot run this 2 train in the same OR in which the BIG4 operated. '\
                  'The NNI or the owning corporation also receives a $20 discount on the cost of all water tiles '\
                  'and water/bridge hexsides. The owning corporation loses this ability when this company closes. ',
            sym: 'NNI',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'water',
                owner_type: 'corporation',
                exact_match: false,
              },
            ],
            color: nil,
          },
          {
            name: 'Virginia Coal Company (Minor)',
            value: 60,
            discount: -60,
            revenue: 0,
            desc: 'Starts with $60, a 2 train, and a token in the special Coal Mine tile (H18). '\
                  'Always operates after the MS and before other corporations. '\
                  'Its train may run in OR1. '\
                  'Splits dividends equally with owner. Purchasing company receives its cash, train and token '\
                  'but cannot run this 2 train in the same OR in which the BIG4 operated. '\
                  'The VCC or the owning corporation also receives a $20 discount on the cost of all mountain tiles '\
                  'and tunnel/pass hexsides. The owning corporation loses this ability when this company closes. '\
                  'The CM tile may be upgraded during any corporation\'s normal track laying step '\
                  'after the first gray train is purchased. The upgrading corporation must be able to '\
                  'trace a legal route to the hex and pay the normal costs to lay the tile. The upgrading '\
                  'corporation may immediately lay a free extra token on the upgraded CM tile, (TODO) even if '\
                  'they already have a token on that hex.',
            sym: 'VCC',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
                exact_match: false,
              },
            ],
            color: nil,
          },
          {
            name: 'Buffalo, Rochester, and Pittsburgh (Minor)',
            value: 40,
            discount: -40,
            revenue: 0,
            desc: 'Starts with $20, a 2 train, and a token in the special Salamanca tile (C21). '\
                  'Always operates after the MS and before other corporations. '\
                  'Its train may run in OR1. '\
                  'Splits dividends equally with owner. Purchasing company receives its cash, train and token. '\
                  'TODO: BPR receives an additional $20 into its treasury at the start of OR1.2, and, if included '\
                  'in the game, an additional yellow 2T is added to the train roster. The purchasing company may '\
                  'choose to replace the BRP token with its own, even if they already have a token in the hex. If '\
                  'this double-token ability is waived, the second space will remain open permanently.',
            sym: 'BRP',
            color: nil,
          },
          {
            name: 'Cleveland, Columbus, and Cincinnati (Minor)',
            value: 40,
            discount: -20,
            revenue: 0,
            desc: 'Starts with $21 in its treasury. TODO: Implement any of these abilities. '\
                  'Always operates after the MS and before other corporations. '\
                  'TODO: Receives a green 2T at the beginning of OR2.1. '\
                  'Splits dividends equally with owner. Purchasing company receives its cash, train and token. '\
                  'TODO: Cannot be purchased by a corporation until its debt has been paid to the bank.',
            sym: 'CC&C',
            color: nil,
          },
          {
            name: 'Chicago and Western Indiana',
            value: 60,
            revenue: 10,
            desc: 'Reserves a token slot in the southeast entrance to Chicago (D6) next to E7. Owning '\
                  'corporation may place an extra token there for free (no connection required). '\
                  'Reservation is removed once this company is purchased by a corporation or closed.'\
                  'Owning corporation may also lay one extra phase-appropriate yellow or green tile in one of '\
                  'D6, E7, or F8 during their normal tile laying step. The owning corporation must pay the '\
                  'normal cost to lay this extra tile. Using this ability closes the private company.',
            sym: 'C&WI',
            abilities: [
              {
                type: 'token',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                hexes: ['D6'],
                city: 3,
                price: 0,
                teleport_price: 0,
                count: 1,
                extra_action: true,
              },
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                discount: 0,
                must_lay_together: true,
                hexes: %w[D6 E7 F8],
                tiles: %w[7 8 9 16 17 18 19 20 21 22 23 24 25 26 27 29 29 30 31 298],
                count: 1,
                special: false,
                connect: false,
                reachable: false,
              },
              { type: 'reservation', remove: 'sold', hex: 'D6', city: 3 },
            ],
            color: nil,
          },
          {
            name: 'Mail Contract',
            value: 80,
            revenue: 0,
            desc: 'Adds a $10 bonus for each city visited by a single train of the owning corporation. '\
                  'Never closes once purchased by a corporation. Closes on Phase III if owned by a player',
            sym: 'MAIL',
            abilities: [{ type: 'close', on_phase: 'never', owner_type: 'corporation' }],
            color: nil,
          },
          {
            name: 'Tunnel Blasting Company',
            value: 60,
            revenue: 20,
            desc: 'Reduces the cost of laying tiles on mountains (hexes with a brown triangle) and '\
                  'connecting hexes with tunnels (brown hex edges) by $20 for the owning corporation.',
            sym: 'TBC',
            abilities: [
              {
                type: 'tile_discount',
                discount: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
                exact_match: false,
              },
            ],
            color: nil,
          },
          {
            name: 'Meat Packing Company',
            value: 60,
            revenue: 15,
            desc: 'Adds a $30 bonus to either St. Louis (I1) or Chicago (D6) for the owning corporation. '\
                  'Bonus must be assigned after being purchased by a corporation. '\
                  'Bonus persists after this company closes in Phase III but is removed in Phase IV.',
            sym: 'MPC',
            abilities: [
              {
                type: 'assign_hexes',
                when: 'owning_corp_or_turn',
                hexes: %w[I1 D6],
                count: 1,
                owner_type: 'corporation',
              },
              {
                type: 'assign_corporation',
                when: 'sold',
                count: 1,
                owner_type: 'corporation',
              },
            ],
            color: nil,
          },
          {
            name: 'Lake Shore Line',
            value: 40,
            revenue: 15,
            desc: 'Owning corporation may make an extra free green tile upgrade of either '\
                  'Cleveland (E17) or Toledo (D14).'\
                  'TODO: Should also allow a brown upgrade if both tiles are green and the company remains unused.',
            sym: 'LSL',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                free: true,
                hexes: %w[D14 E17],
                tiles: %w[14 15 619 294 295 296],
                special: false,
                count: 1,
              },
            ],
            color: nil,
          },
          {
            name: 'Michigan Central',
            value: 40,
            revenue: 15,
            desc: 'Owning corporation may lay up to two extra free yellow tiles '\
                  'in reserved hexes B10 and B12. '\
                  'If both tiles are laid, they must connect to each other. '\
                  'Owning corporation does not need to be connected to either hex to use this ability.',
            sym: 'MC',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[B10 B12] },
                        {
                          type: 'tile_lay',
                          when: 'owning_corp_or_turn',
                          owner_type: 'corporation',
                          free: true,
                          must_lay_together: true,
                          hexes: %w[B10 B12],
                          tiles: %w[7 8 9],
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Ohio & Indiana',
            value: 40,
            revenue: 15,
            desc: 'Owning corporation may lay up to two extra free yellow tiles '\
                  'in reserved hexes F14 and F16. '\
                  'If both tiles are laid, they must connect to each other. '\
                  'Owning corporation does not need to be connected to either hex to use this ability.',
            sym: 'O&I',
            abilities: [{ type: 'blocks_hexes', owner_type: 'player', hexes: %w[F14 F16] },
                        {
                          type: 'tile_lay',
                          when: 'owning_corp_or_turn',
                          owner_type: 'corporation',
                          free: true,
                          must_lay_together: true,
                          hexes: %w[F14 F16],
                          tiles: %w[7 8 9],
                          count: 2,
                        }],
            color: nil,
          },
          {
            name: 'Little Miami',
            sym: 'LM',
            value: 40,
            revenue: 15,
            desc: 'If no track connects Cincinnati (H12) to Dayton (G13), the '\
                  'owning corporation may lay and/or upgrade an extra free tile in each hex to connect them. '\
                  'Owning corporation does not need to be connected to either hex to use this ability.',
            abilities: [
              {
                type: 'tile_lay',
                when: 'owning_corp_or_turn',
                owner_type: 'corporation',
                discount: 20,
                must_lay_together: true,
                hexes: %w[H12 G13],
                tiles: %w[5 6 57 14 15 619 291 292 293 294 295 296],
                count: 2,
                special: false,
                connect: false,
                reachable: false,
              },
            ],
            color: nil,
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 20,
            sym: 'L&N',
            name: 'Louisville and Nashville Railroad',
            logo: '1846/LNR',
            simple_logo: '1846/LNR.alt',
            tokens: [0, 80, 80],
            abilities: [
            {
              type: 'base',
              description: 'Forced Treasury Sale',
              desc_detail: 'TODO: At the beginning of the L&N\'s first full stock round, its stock price '\
                           'moves two spaces to the right. The L&N receives half the new share price '\
                           '(rounded down), and one treasury share is placed into the market as compensation.'\
                           'This forced sale may exceed the market share limit.',
            },
          ],
            coordinates: 'J10',
            color: '#8F000F',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '1846/PRR',
            simple_logo: '1846/PRR.alt',
            tokens: [0, 80, 80, 80, 80],
            abilities: [
            {
              type: 'token',
              description: 'Reserved $40 token/$60 teleport on E11',
              desc_detail: 'May place token in Ft. Wayne (E11) for $40 if connected, $60 '\
                           'otherwise. This token slot is reserved until Phase IV.',
              hexes: ['E11'],
              price: 40,
              teleport_price: 60,
            },
            {
              type: 'reservation',
              hex: 'E11',
              remove: 'IV',
            },
          ],
            coordinates: 'F20',
            color: '#ff0000',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'NYC',
            name: 'New York Central Railroad',
            logo: '1846/NYC',
            simple_logo: '1846/NYC.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'D20',
            color: '#110a0c',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '1846/BO',
            simple_logo: '1846/BO.alt',
            tokens: [0, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40 token/$100 teleport on H12',
                desc_detail: 'May place token in Cincinnati (H12) for $40 if connected, $100 '\
                             'otherwise. This token slot is reserved until Phase IV.',
                hexes: ['H12'],
                price: 40,
                count: 1,
                teleport_price: 100,
              },
              {
                type: 'reservation',
                hex: 'H12',
                remove: 'IV',
              },
            ],
            coordinates: 'G19',
            color: '#025aaa',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'C&O',
            name: 'Chesapeake & Ohio Railroad',
            logo: '1846/CO',
            simple_logo: '1846/CO.alt',
            tokens: [0, 80, 80, 80],
            coordinates: 'I15',
            color: :'#ADD8E6',
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'ERIE',
            name: 'Erie Railroad',
            logo: '1846/ERIE',
            simple_logo: '1846/ERIE.alt',
            tokens: [0, 80, 80, 80],
            abilities: [
              {
                type: 'token',
                description: 'Reserved $40 token in Erie (D20)',
                desc_detail: 'May place $40 token in Erie (D20) if connected. This token slot is '\
                             'reserved until Phase IV.',
                hexes: ['D20'],
                count: 1,
                price: 40,
              },
              {
                type: 'reservation',
                hex: 'D20',
                slot: 1,
                remove: 'IV',
              },
            ],
            coordinates: 'E21',
            color: :'#FFF500',
            text_color: 'black',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'GT',
            name: 'Grand Trunk Railway',
            logo: '1846/GT',
            simple_logo: '1846/GT.alt',
            tokens: [0, 80, 80],
            coordinates: 'B16',
            color: '#f58121',
            always_market_price: true,
          },
          {
            float_percent: 20,
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '1846/IC',
            simple_logo: '1846/IC.alt',
            tokens: [0, 80, 80, 80],
            abilities: [
              {
                type: 'base',
                description: 'Receives an initial subsidy of 1x par value',
                desc_detail: 'When floated IC receives a one-time subsidy equal to its par price into its treasury.',
                remove: 'par',
              },
              {
                type: 'tile_lay',
                discount: 20,
                description: 'Free yellow tile lays on "IC" hexes',
                desc_detail: 'IC lays yellow tiles for free on hexes marked with an IC icon (E5, '\
                             'F6, G5, H6 and J4).',
                passive: true,
                when: 'track_and_token',
                hexes: %w[E5 F6 G5 H6 J4],
                tiles: %w[7 8 9],
              },

              {
                type: 'token',
                description: 'Reserved $60 Nashville (L8) token',
                desc_detail: 'May place $60 token in Nashville (L8) regardless of connectivity. This token slot is '\
                             'reserved until Phase IV.',
                hexes: ['L8'],
                count: 1,
                price: 60,
              },
              {
                type: 'reservation',
                hex: 'L8',
                remove: 'IV',
              },

            ],
            coordinates: 'I5',
            color: '#32763f',
            always_market_price: true,
          },
        ].freeze
        MINORS = [
          {
            sym: 'MS',
            name: 'Michigan Southern',
            logo: '1846/MS',
            simple_logo: '1846/MS.alt',
            tokens: [0],
            coordinates: 'C15',
            color: :pink,
            text_color: 'black',
          },
          {
            sym: 'BIG4',
            name: 'Big 4',
            logo: '1846/B4',
            simple_logo: '1846/B4.alt',
            tokens: [0],
            coordinates: 'G9',
            color: :cyan,
            text_color: 'black',
          },
          {
            sym: 'NNI',
            name: 'Nashville and Northwestern',
            logo: '1846/NNI',
            simple_logo: '1846/NNI.alt',
            tokens: [0],
            coordinates: 'L8',
            color: :pink,
            text_color: 'black',
            abilities: [
              {
                description: 'Terrain discount: Water',
                desc_detail: 'Reduces the cost of laying tiles on water hexes or connecting hexes with bridges '\
                             '(blue hex edges) by $20 for the owning corporation.',
                type: 'tile_discount',
                discount: 20,
                terrain: 'water',
                owner_type: 'corporation',
                exact_match: false,
              },
            ],
          },
          {
            sym: 'VCC',
            name: 'Virginia Coal Company',
            logo: '1846/VCC',
            simple_logo: '1846/VCC.alt',
            tokens: [0],
            coordinates: 'G3',
            color: :pink,
            text_color: 'black',
            abilities: [
              {
                description: 'Mountain discount',
                desc_detail: 'Minor (or owning company) recieves a $20 discount on laying mountain tiles.',
                type: 'tile_discount',
                discount: 20,
                terrain: 'mountain',
                owner_type: 'corporation',
                exact_match: false,
              },
            ],
          },
          {
            sym: 'BRP',
            name: 'Buffalo, Rochester, and Pittsburgh',
            logo: '1846/BRP',
            simple_logo: '1846/BRP.alt',
            tokens: [0],
            coordinates: 'D14',
            color: :pink,
            text_color: 'black',
          },
          {
            sym: 'CC&C',
            name: 'Cleveland, Columbus, and Cincinnati',
            logo: '1846/CC&C',
            simple_logo: '1846/CC&C.alt',
            tokens: [0],
            coordinates: 'G15',
            color: :pink,
            text_color: 'black',
          },
        ].freeze
      end
    end
  end
end
