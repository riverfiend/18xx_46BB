# frozen_string_literal: true

require_relative 'scripts_helper'
require_relative 'import_local_game'

def test_import(file_name = "/18xx/scripts/hotseat_games/3p_draft_done.json", game_id = 100001)
  import_local_game(file_name, game_id)
end
