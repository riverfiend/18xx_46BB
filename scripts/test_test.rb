# frozen_string_literal: true

require_relative 'scripts_helper'

DB.extension :pg_array, :pg_advisory_lock, :pg_json, :pg_enum

def test_test(simple = false, overwrite = false, minors = false)
  game_title = '1846_barons_of_the_backwaters'
  game_class = Engine.game_by_title(game_title)
  players = Array.new(3) { |n| "Player #{n + 1}" }
  game = game_class.new(players)
  
  #corporations = game.send(:init_corporations, game.stock_market)
  #corporations.concat(game.send(:init_minors)) if minors
#
 # corporations.each do |corp|
  #  next if simple && corp.logo == corp.simple_logo
  #end
end
