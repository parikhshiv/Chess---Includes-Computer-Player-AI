class Piece
  attr_accessor :pos
  attr_reader :board, :color

  def initialize(pos, color, board)
    @pos = pos
    @color = color
    @board = board
    add_self_to_board
  end

  def valid_moves
    moves.reject do |move|
      duped_board = make_duped_move([@pos, move])
      duped_board.in_check?(self.color)
    end
  end

  def safe_move?(move)
    duped_board = make_duped_move(move)
    duped_board.safe?(self.color, move[1])
  end

  #for debugging
  def inspect
    self.class
  end

  private

  def add_self_to_board
    @board[@pos] = self
  end

  def dup_entire_board
    duped_board = Board.new(true)
    pieces = @board.grid.flatten.select {|piece| piece.is_a?(Piece)}
    pieces.each { |piece| piece.dup(duped_board) }
    duped_board
  end

  def make_duped_move(move)
    start, end_pos = move
    duped_board = dup_entire_board
    duped_board.move_piece!(start, end_pos)
    duped_board
  end

  def add_coord(pos1,pos2)
    [pos1[0]+pos2[0], pos1[1]+pos2[1]]
  end

  def out_of_bounds?(pos)
    pos.any? { |el| el < 0 || el > 7  }
  end

  protected

  def dup(new_board)
    self.class.new(self.pos.dup, self.color, new_board)
  end
end

class Pawn < Piece

  def initialize(pos, color, board)
    super(pos,color,board)
    get_permitted_directions
  end

  def moves
    all_moves = add_basic_pawn_moves
    all_moves = include_starting_moves(all_moves)
  end

  def to_s
    color == :white ? "♙ " : "♟ "
  end

  private

  def add_basic_pawn_moves
    all_moves = []
    coordinates = @permitted_directions.map{ |dir| add_coord(dir,pos)}
    first, last, front = coordinates.first, coordinates.last, coordinates[1]

    coordinates.each do |coor|
      next if out_of_bounds?(coor)
      case coor
      when front
        all_moves << coor unless @board[coor].is_a?(Piece)
      else
        all_moves << coor if @board[coor].color != self.color &&
                      @board[coor].is_a?(Piece)
      end
    end
    all_moves
  end

  def get_permitted_directions
    if color == :white
      @permitted_directions = [[-1,-1], [-1,0], [-1,1]]
    else
      @permitted_directions = [[1,-1], [1,0], [1,1]]
    end
  end

  def include_starting_moves(all_moves)
    if pos[0] == 1 && @color == :black
      coor = add_coord([2,0],@pos)
      all_moves << coor unless @board[coor].is_a?(Piece) ||
                        @board[[coor[0]-1,coor[1]]].is_a?(Piece)
    elsif pos[0] == 6 && @color == :white
      coor = add_coord([-2,0],@pos)
      all_moves << coor unless @board[coor].is_a?(Piece)||
                        @board[[coor[0]+1,coor[1]]].is_a?(Piece)
    end
    all_moves
  end
end

class SteppingPiece < Piece
  def initialize(pos, color, board)
    super(pos,color,board)
  end

  def moves
    all_moves = []
    @permitted_directions.each do |dir|
      next_move = add_coord(dir, pos)
      next if out_of_bounds?(next_move)
      if @board[next_move].is_a?(Piece)
        all_moves << next_move if board[next_move].color != self.color
        next
      end
      all_moves << next_move
    end
    all_moves
  end
end

class Knight < SteppingPiece
  def initialize(pos, color, board)
    super(pos,color,board)
    @permitted_directions = [[-2,-1],[2,-1],[1,2],[2,1],[-2,1],[1,-2],[-1,2],[-1,-2]]
  end

  def to_s
    color == :white ? "♘ " : "♞ "
  end
end

class King < SteppingPiece
  def initialize(pos, color, board)
    super(pos,color,board)
    @permitted_directions = [[-1,0],[0,1],[1,0],[0,-1],[-1,-1],[-1,1],[1,1],[1,-1]]
  end

  def to_s
    color == :white ? "♔ " : "♿ "
  end
end

class SlidingPiece < Piece
  def initialize(pos, color, board)
    super(pos,color,board)
  end


  def trace_path(dir)
    next_pos = add_coord(pos,dir)
    row, col = next_pos
    path = []
    until out_of_bounds?(next_pos)
      if @board[next_pos].is_a?(Piece)
        path << next_pos if @board[next_pos].color != self.color
        break
      end
      path << next_pos
      next_pos = add_coord(next_pos,dir)
    end
    path
  end

  def moves
    all_paths = []
    @permitted_directions.each do |dir|
      all_paths += trace_path(dir)
    end
    all_paths
  end
end

class Bishop < SlidingPiece
  def initialize(pos, color, board)
    super(pos,color,board)
    @permitted_directions = [[-1,-1],[-1,1],[1,1],[1,-1]]
  end

  def move_dirs
    [:diagonal]
  end

  def to_s
    color == :white ? "♗ " : "♝ "
  end
end

class Rook < SlidingPiece
  def initialize(pos, color, board)
    super(pos,color,board)
    @permitted_directions = [[-1,0],[0,1],[1,0],[0,-1]]
  end

  def move_dirs
    [:straight]
  end

  def to_s
    color == :white ? "♖ " : "♜ "
  end

end

class Queen < SlidingPiece
  def initialize(pos, color, board)
    super(pos,color,board)
    @permitted_directions = [[-1,0],[0,1],[1,0],[0,-1],[-1,-1],[-1,1],[1,1],[1,-1]]
  end

  def move_dirs
    [:straight, :diagonal]
  end

  def to_s
    color == :white ? "♕ " : "♛ "
  end
end
