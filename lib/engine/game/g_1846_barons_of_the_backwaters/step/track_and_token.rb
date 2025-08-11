# frozen_string_literal: true

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      module Step
        class TrackAndToken < Engine::Game::G1846::Step::TrackAndToken
          def tokener_available_hex(entity, hex)
            if ([entity.id, hex.id] == ['IC', 'L8']) &&
               entity.all_abilities.find { |a| a.type == :token }
              return true
            end

            super
          end
        end
      end
    end
  end
end
