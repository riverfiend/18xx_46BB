# frozen_string_literal: true

require_relative 'scassign'

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      module Step
        class SWSCAssign < Engine::Game::G1846BaronsOfTheBackwaters::Step::SCAssign
          def setup
            @steamboat = @game.swsteamboat
          end

          def description
            return super unless blocking_for_steamboat?

            'Assign Southwest Steamboat Company'
          end

          def help
            return super unless blocking_for_steamboat?

            assignments = [steamboat_assigned_hex, steamboat_assigned_corp].compact.map(&:name)

            targets = []
            targets << 'hex' if steamboat_assignable_to_hex?
            targets << 'corporation or minor' if steamboat_assignable_to_corp?

            help_text = ["#{@steamboat.owner.name} may assign Southwestern Steamboat Company to a new #{targets.join(' and/or ')}."]
            help_text << " Currently assigned to #{assignments.join(' and ')}." if assignments.any?

            help_text
          end

          def process_pass(action)
            raise GameError, "Not #{action.entity.name}'s turn: #{action.to_h}" unless action.entity == @steamboat

            if (ability = @game.abilities(@steamboat, :assign_hexes, time: 'or_start', strict_time: false))
              ability.use!
              @log <<
                if (hex = steamboat_assigned_hex)
                  "Southwestern Steamboat Company is assigned to #{hex.name}"
                else
                  'Southwestern Steamboat Company is not assigned to any hex'
                end
            end

            if (ability = @game.abilities(@steamboat, :assign_corporation, time: 'or_start', strict_time: false))
              ability.use!
              @log <<
                if (corp = steamboat_assigned_corp)
                  "Southwestern Steamboat Company is assigned to #{corp.name}"
                else
                  'Southwestern Steamboat Company is not assigned to any corporation or minor'
                end
            end

            pass!
          end
        end
      end
    end
  end
end
