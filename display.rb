require_relative 'cursorable'
require_relative 'player'

class Display
  include Cursorable

  attr_accessor :selected

  def initialize(board)
    @board = board
    @cursor = [0, 0]
    @selected = false
  end

  def render
    system("clear")
    puts "Use WASD to move, enter to confirm."

    grid = build_grid
    load_path_space(grid)
    grid.each_with_index { |row, i| puts  "#{i+1} #{row.join}" }
    puts "  #{('a'..'h').to_a.join(' ')}"
  end

  private
  attr_reader :board

  def build_grid
    @board.grid.map.with_index do |row, i|
      build_row(row, i)
    end
  end

  def build_row(row, i)
    row.map.with_index do |piece, j|
      color_options = colors_for(i, j)
      piece.to_s.colorize(color_options)
    end
  end

  def possible_moves
    board[@cursor].valid_moves
  end

  def colors_for(i, j)
    if [i, j] == @cursor
      bg = :light_cyan
    elsif (i + j).odd?
      bg = :light_red
    else
      bg = :light_brown
    end
    { background: bg, color: :brown, mode: :bold }
  end

  def load_path_space(grid)
    possible_moves.each do |move|
      piece = grid[move[0]][move[1]]
      if @board.current_player_color == @board[@cursor].color
        grid[move[0]][move[1]] = piece.to_s.colorize({ background: :light_magenta,
                                                         color: :light_white})
      end
    end
  end

end
