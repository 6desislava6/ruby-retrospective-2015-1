def move(snake, direction)
  snake.drop(1) << make_new_head(snake, direction)
end

def grow(snake, direction)
  snake.dup << make_new_head(snake, direction)
end

def new_food(food, snake, dimensions)
  free_positions(dimensions[:width],
                 dimensions[:height],
                 food,
                 snake).sample
end

def make_new_head(snake, direction)
  [snake.last[0] + direction[0], snake.last[1] + direction[1]]
end

def obstacle_ahead?(snake, direction, dimensions)
  new_snake = move(snake, direction)

  return true if outside_field?(new_snake.last[0], dimensions[:width])
  return true if outside_field?(new_snake.last[1], dimensions[:height])
  new_snake[0...-1].include? new_snake.last or snake.include? new_snake.last
end

def danger?(snake, direction, dimensions)
  return true if obstacle_ahead?(snake, direction, dimensions)
  obstacle_ahead?(move(snake, direction), direction, dimensions)
end


def outside_field?(coordinate, length)
  coordinate < 0 or coordinate >= length
end

def free_positions(dimension_x, dimension_y, food, snake)
  all_positions = (0...dimension_x).to_a.product((0...dimension_y).to_a)
  all_positions - food - snake
end
