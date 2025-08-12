# frozen_string_literal: true

module Engine
  module Game
    module G1846BaronsOfTheBackwaters
      module ReceivershipSkip
        def actions(entity)
          entity.receivership? ? [] : super
        end
      end
    end
  end
end
