require_relative 'display'
require 'colorize'
require_relative 'piece'

class Board
  attr_reader :grid
  attr_reader :current_player_color

  def initialize(duped = false)
    @grid = Array.new(8) { Array.new(8) {EmptySpace.new} }
    @duped = duped
    setup_board unless @duped
    @current_player_color = :white
  end

  def move_piece!(start, end_pos)
    piece = self[start]
    piece.pos = end_pos
    self[start] = EmptySpace.new
    self[end_pos] = piece
  end

  def[](pos)
    row, col = pos
    @grid[row][col]
  end

  def[]=(pos, value)
    row, col = pos
    @grid[row][col] = value
  end

  def in_check?(color)
    king_pos = find_king(color)
    opponents_pieces_moves(color).any? { |pos| pos == king_pos }
  end

  def safe?(color, our_pos)
    !(opponents_pieces_moves(color).any? { |opp_move_pos| opp_move_pos == our_pos })
  end

  def grab_pieces(color)
    pieces = @grid.flatten.select { |piece| piece.is_a?(Piece) && piece.color == color}
  end

  def check_mate?(color)
    pieces = grab_pieces(color)
    pieces.all? { |piece| piece.valid_moves.empty? }
  end

  def move_piece(start, end_pos)
    piece = self[start]
    raise EmptySpaceError if piece.is_a?(EmptySpace)
    raise WrongPlayerError if piece.color != @current_player_color
    if piece.valid_moves.include?(end_pos)
      move_piece!(start, end_pos)
      current_player_switch
    else
      raise EndPositionError
    end
  end

  def in_bounds?(pos)
    pos.all? { |el| el >= 0 && el < 8 }
  end

  def find_king(color)
    king = @grid.flatten.find {|piece| piece.color == color && piece.is_a?(King)}
    king.pos
  end

  private

  def current_player_switch
    @current_player_color = (@current_player_color == :white) ? :black : :white
  end

  def opponents_pieces_moves(color)
    opponents = @grid.flatten.select {|piece| piece.color != color && piece.is_a?(Piece)}
    all_moves = []
    opponents.each { |piece| all_moves += piece.moves }
    all_moves
  end

  def setup_board
    [:black, :white].each do |color|
      load_pieces(color)
    end

    8.times do |idx|
      Pawn.new([1, idx], :black, self)
      Pawn.new([6, idx], :white, self)
    end
  end

  def load_pieces(color)
    order = ["Rook", "Knight", "Bishop", "Queen", "King", "Bishop", "Knight", "Rook" ]
    color == :white ? row = 7 : row = 0
    8.times do |col|
      type = order[col]
      pos = [row,col]
      generate_piece(pos,color,type)
    end
  end

  def generate_piece(pos,color,type)
    case type
    when "Rook"
      Rook.new(pos,color,self)
    when "Knight"
      Knight.new(pos,color,self)
    when "Bishop"
      Bishop.new(pos,color,self)
    when "Queen"
      Queen.new(pos,color,self)
    when "King"
      King.new(pos,color,self)
    end
  end
end

class EmptySpace
  def to_s
    "  "
  end
  def color
  end
  def valid_moves
    []
  end
end

class EmptySpaceError < StandardError
end

class EndPositionError < StandardError
end

class WrongPlayerError < StandardError
end
