# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            if action.entity.id == @game.class::LSL_ID
              @game.remove_icons(@game.class::LSL_HEXES,
                                 @game.class::ABILITY_ICONS[action.entity.id])
            end

            super
          end
          def process_lay_tile(action) #again, it is unclear to me why removing this function breaks things.
            if @company && (@company != action.entity) &&
               (ability = @game.abilities(@company, :tile_lay, time: 'track')) &&
               ability.must_lay_together && ability.must_lay_all
              raise GameError, "Cannot interrupt #{@company.name}'s tile lays"
            end
          
            ability = abilities(action.entity)
            owner = if !action.entity.owner
                      nil
                    elsif action.entity.owner.corporation?
                      action.entity.owner
                    else
                      @game.current_entity
                    end
            if ability.type == :teleport ||
               (ability.type == :tile_lay && ability.consume_tile_lay)
              lay_tile_action(action, spender: owner)
            else
              lay_tile(action, spender: owner)
              ability.laid_hexes << action.hex.id
              @round.laid_hexes << action.hex
              check_connect(action, ability)
            end
            ability.use!(upgrade: %i[green brown gray].include?(action.tile.color))
          
            # Record any track laid after the dividend step
            if owner&.corporation? && (operating_info = owner.operating_history[[@game.turn, @round.round_num]])
              operating_info.laid_hexes = @round.laid_hexes
            end
          
            if ability.type == :tile_lay
              if ability.count&.zero? && ability.closed_when_used_up
                company = ability.owner
                @game.company_closing_after_using_ability(company)
                company.close!
              end
              @company = ability.count.positive? ? action.entity : nil if ability.must_lay_together
            end
          
            return unless ability.type == :teleport
          
            company = ability.owner
            tokener = company.owner
            tokener = @game.current_entity if tokener.player?
            if tokener.tokens_by_type.empty?
              company.remove_ability(ability)
            else
              @round.teleported = company
              @round.teleport_tokener = tokener
            end
          end
        end
      end
    end
  end
end
