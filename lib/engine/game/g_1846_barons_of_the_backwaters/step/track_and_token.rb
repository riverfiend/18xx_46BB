# frozen_string_literal: true
require_relative '../../g_1846/step/track_and_token'

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      module Step
        class TrackAndToken < Engine::Game::G1846::Step::TrackAndToken
          def tokener_available_hex(entity, hex)
            if ( [entity.id, hex.id] == ['IC', 'L8'] ) &&
               entity.all_abilities.find { |a| a.type == :token }
              return true
            end
            super
          end
          def process_lay_tile(action) #this is identical to what we should be inheriting elsewhere, but adding it fixed things?
            lay_tile_action(action)
            pass! if !can_lay_tile?(action.entity) && @tokened
          end
        end
      end
    end
  end
end