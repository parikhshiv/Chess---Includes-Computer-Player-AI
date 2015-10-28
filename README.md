# Chess

This project is a fully interactive, multi featured version of Chess.

![ScreenShot](/images/preview.png)

## Pieces are split into SteppingPieces and SlidingPieces

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

### Run project from the command line with:

```ruby game.rb```

Cursor input is available through the keys AWSD. "Enter" will select and place
pieces. Games are played against a fully programmed computer AI.
