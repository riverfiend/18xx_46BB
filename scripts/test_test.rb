# frozen_string_literal: true

require_relative 'scripts_helper'

DB.extension :pg_array, :pg_advisory_lock, :pg_json, :pg_enum
def test_bb(player_count = 3)
  test_exec('1846_barons_of_the_backwaters', player_count)
end

def test_base(player_count = 3)
  test_exec('1846', player_count)
end

def test_exec(game_title, player_count)
  game_class = Engine.game_by_title(game_title)
  players = Array.new(player_count) { |n| "Player #{n + 1}" }
  game = game_class.new(players)
  
  #corporations = game.send(:init_corporations, game.stock_market)
  #corporations.concat(game.send(:init_minors)) if minors
#
 # corporations.each do |corp|
  #  next if simple && corp.logo == corp.simple_logo
  #end
end
