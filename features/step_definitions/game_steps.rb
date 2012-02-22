Given /I have a fresh game table/ do
  @game_table = Factory.create :game_table

  @seq = sequence('turn sequence')
end

When /the hand begins/ do
  @hand = @game_table.hands.create

  # Workaround to preserve expectations.
  Hand.any_instance.stubs(:active_players).returns(@players.values)

  puts @players.values.collect { |p| p.to_s }.inspect
end

Given /a player named (\w+) with (\d+) chips/ do |name, chips|
  @players ||= {}
  @players[name] = @game_table.tournament.players.create(:name => name, :chips => chips)
  @game_table.seatings.create(:player => @players[name])
end

When /(\w+) bets (\d+)/ do |name, chips|
  @players[name].expects(:get_action).in_sequence(@seq).returns(
    :action => "bet",
    :amount => chips
  )
end

When /(\w+) folds/ do |name|
  @players[name].expects(:get_action).in_sequence(@seq).returns(
    :action => "fold"
  )
end

When /(\w+) posts blinds/ do |name|
  @players[name].expects(:blind).in_sequence(@seq).returns(true)
end

When /(\w+) fails to post blinds/ do |name|
  @players[name].expects(:blind).in_sequence(@seq).returns(false)
end

When /the hand plays out/ do
  @hand.play!
end

# This will end the scenario!
Then /the round should advance to (\w+)/ do |round|
  @hand.expects(:next_turn).in_sequence(@seq)
end

# This will end the scenario!
Then /the round should be over/ do
  @hand.expects(:close_hand!).in_sequence(@seq)
end