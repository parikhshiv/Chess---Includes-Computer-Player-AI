require_relative 'display'
require_relative 'board'

class HumanPlayer
  attr_reader :color

  def initialize(board, color)
    @display = Display.new(board)
    @board = board
    @color = color
  end

  def play_turn
    puts "Please make a move, use enter to select and place."
    start, end_pos = get_two_moves
    @board.move_piece(start, end_pos)
    rescue EmptySpaceError
      print "There are no pieces at that start space. Try again in ".colorize(:red)
      countdown
      retry
    rescue EndPositionError
      print "That endpoint is invalid (Puts you in check, or is out-of-bounds). \nTry again in ".colorize(:red)
      countdown
      retry
    rescue WrongPlayerError
      print "You can only move your own pieces, fucker. \nTry again in ".colorize(:red)
      countdown
      retry
  end

  private

  def move
    start = nil
    until start
      @display.render
      start = @display.get_input
    end
    start
  end

  def get_two_moves
    moves = []
    until moves.length == 2
      moves << move
    end
    moves
  end

  def countdown
    [3,2,1].each do |idx|
      print "#{idx} "
      sleep(0.5)
    end
  end
end

class ComputerPlayer
  attr_reader :color

  def initialize(board, color)
    @display = Display.new(board)
    @board = board
    @color = color
  end

  def play_turn
    @bad_moves = []
    move = self.move
    piece = @board[move[0]]
    until piece.safe_move?(move)
      @bad_moves << move[1]
      move = self.move
      piece = @board[move[0]]
    end
    @board.move_piece(move[0], move[1])
  end

  def move
    opponents_king = get_opponents_king
    pieces = @board.grab_pieces(color)
    movable_pieces = pieces.reject { |piece| piece.valid_moves.empty? }
    move = select_best_move(movable_pieces, opponents_king)
  end

  private

  def select_best_move(movable_pieces, opponents_king)
    valid_moves_hash = {}
    movable_pieces.each do |piece|
      piece.valid_moves.each do |move|
        valid_moves_hash[move] = piece unless @bad_moves.include?(move)
      end
    end
    smallest_distance = nil
    best_move = nil
    valid_moves_hash.each do |move, piece|
      distance = get_distance(opponents_king, move)
      smallest_distance ||= distance
      best_move ||= move
      if distance < smallest_distance
        smallest_distance = distance
        best_move = move
      end
    end
    valid_moves_hash
    [valid_moves_hash[best_move].pos, best_move]
  end

  def get_distance(pos1,pos2)
    (pos1[0]-pos2[0]).abs + (pos1[1]-pos2[1]).abs
  end

  def get_opponents_king
    opponent_color = get_opponent_color
    @board.find_king(opponent_color)
  end

  def get_opponent_color
    player_color = @board.current_player_color
    color = (player_color == :white) ? :black : :white
  end

end
