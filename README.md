# Chess

This project is a fully interactive, multi featured version of Chess.

![ScreenShot](/images/preview.png)

## Aggressiv Computer AI

Computer Player finds most aggressive possible move to make (move that will result in one of its pieces being closest to the opponent's king):

```
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
  p valid_moves_hash
  [valid_moves_hash[best_move].pos, best_move]
end
```

## Pieces split into SteppingPieces and SlidingPieces

The SlidingPiece class uses a trace_path method to determine a piece's possible moves:

```
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
```

Stepping Pieces are relatively simpler - but a similar logic for determining possible moves is used:

```
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
```

## Empty Space Class

An empty space class was created to replace nil values on the chess board - this helped avoid the common "undefined method for nil:NilClass" error.

```
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
```

### Run project from the command line with:

```ruby game.rb```

Cursor input is available through the keys AWSD. "Enter" will select and place
pieces. Games are played against a fully programmed computer AI.
