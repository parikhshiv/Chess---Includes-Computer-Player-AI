require_relative 'player'
# require 'colorize'

class Game
  def initialize
    @board = Board.new
    @display = Display.new(board)
    setup_players
    @winner = nil
  end

  def run
    puts "White Goes First!"
    sleep(1)
    until over?
      setup_display
      current_player.play_turn
      switch_players!
    end
    puts "Congrats #{@winner}"

  end

  private
  
  attr_reader :board, :display, :players
  attr_accessor :current_player

  def setup_display
      puts "#{@current_player.color.capitalize}, please make a move: "
      display.render
  end

  def setup_players
    @player1, @player2 = HumanPlayer.new(@board, :white), ComputerPlayer.new(@board, :black)
    @players = [@player1, @player2]
    @current_player = @players.first
  end

  def over?
    if @board.check_mate?(:white)
      @winner = "Black"
    elsif @board.check_mate?(:black)
      @winner = "White"
    else
      false
    end
  end

  def switch_players!
    players.rotate!
    @current_player = players.first
  end
end


if __FILE__ == $PROGRAM_NAME
  game = Game.new

  # Queen.new([6,5], :black, new_board)
  # Bishop.new([4,7], :black, new_board)
  # # Bishop.new([4,7], :black, new_board)
  # # p new_board[[1,1]].moves
  # p new_board.check_mate?(:white)
  # # p new_board[[7,4]].valid_moves
  # # new_board.grid.flatten.each { |el| p el.color}
  game.run
end
