class RationalSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
  end

  def each_rational
    counter = 0
    row, col = 1, 1
    loop do
      if row.gcd(col) == 1
        yield Rational(row, col)
      end
      row, col = calculate_direction(row, col)
    end
  end

  def each(&block)
     enum_for(:each_rational).lazy.take(@limit).each(&block)
  end

  def calculate_direction(row, col)
    if col == 1 and row.odd?
      row += 1
    elsif row == 1 and col.even?
      col += 1
    elsif (row + col).even?
      row += 1
      col -= 1
    else
      row -= 1
      col += 1
    end
      return row, col
  end
end

class PrimeSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
  end

  def each_prime
    number, counter = 2, 0
    loop do
      if number.prime?
        yield(number)
        counter += 1
      end
      number += 1
    end
  end

  def each(&block)
     enum_for(:each_prime).lazy.take(@limit).each(&block)
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(limit, first: 1, second: 1)
    @limit = limit
    @first = first
    @second = second
  end

  def each
    first, second = @first, @second
    @limit.times do
      yield first
      first, second = second, first + second
    end
  end
end

class WorthlessRationalSequence < RationalSequence
  def each
    sum = 0
    row, col = 1, 1
    while sum < @limit
      number = Rational(row, col)
      break if sum + number > @limit
      if row.gcd(col) == 1
        yield number
        sum += number
      end
      row, col = calculate_direction(row, col)
    end
  end
end

module DrunkenMathematician
  module_function

  def meaningless(count)
    return 1 if count == 0
    groups = RationalSequence.new(count).to_a.group_by do |number|
      number.numerator.prime? or (number.denominator).prime?
    end
    groups[true]  ||= []
    groups[false] ||= []
    groups[true].reduce(1, :*) / groups[false].reduce(1, :*)
  end

  def aimless(count)
    return 0 if count == 0
    numbers = PrimeSequence.new(count).each_slice(2).map do |pair|
      pair.length == 2 ? Rational(pair.first, pair.last) : Rational(pair.first)
    end
    numbers.reduce(:+)
  end

  def worthless(nth_fibonacci)
    return 0 if nth_fibonacci == 0
    limit = FibonacciSequence.new(nth_fibonacci).to_a.last
    WorthlessRationalSequence.new(limit).to_a
  end
end

class Integer
  def prime?
    self == 1 ? false : (2..self / 2).none? { |i| self % i == 0 }
  end
end
