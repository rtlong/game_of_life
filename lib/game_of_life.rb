require 'matrix'
require 'set'

class Universe < Hash
  alias each each_value

  def <<(cell)
    self[cell.location] = cell
  end
  alias add_cell <<

  def max
    keys.reduce(keys.first.coords) do |_max,location|
      _max = _max.zip(location.coords).map(&:max)
    end
  end

  def min
    keys.reduce(keys.first.coords) do |_min,location|
      _min = _min.zip(location.coords).map(&:min)
    end
  end

  def evolve
    self.replace Evolution.new(self).perform
  end

end

class Evolution
  def initialize(universe)
    @universe = universe
    @new_universe = Universe.new
    @keys_to_check = Set.new @universe.keys
    @checked = Set.new
  end

  def keys
    @keys_to_check - @checked
  end

  def perform
    while keys.any?
      keys.each do |loc|
        adj = loc.adjacent_locations
        neighbors = adj & @universe.keys

        if cell = @universe[loc]
          # Add it's neighbors to be checked
          @keys_to_check = @keys_to_check | adj

          @new_universe.add_cell(cell) if (2..3).include?(neighbors.count)
        else
          @new_universe.add_cell(Cell.new(loc)) if neighbors.count == 3
        end

        @checked << loc
      end
    end

    @new_universe
  end
end

class Cell
  attr_reader :location

  def initialize(location)
    @location = location
  end
end

class Location
  attr_reader :coords

  def initialize(*coords)
    @coords = coords.flatten
  end

  def self.with_bias(bias, *coords)
    # p coords
    coords = coords.zip(bias).map{|a| a.reduce(:+) }
    # p coords
    self.new(*coords)
  end

  def adjacent?(other)
    return false if self.eql?(other)
    coords.zip(other.coords).each do |a,b|
      return false if (a - b).abs > 1
    end
    return true
  end

  def hash
    coords.hash
  end

  def eql?(other)
    hash == other.hash
  end

  def ==(other)
    hash == other.hash
  end

  def adjacent_locations
    locations = []
    (-1..1).each do |i|
      (-1..1).each do |j|
        offset = i, j
        new_coords = offset.zip(coords).map{|v| v.reduce(:+)}
        locations << Location.new(*new_coords) unless offset.all?{|i| i == 0}
      end
    end
    return locations
  end

  def to_s
    "#<Location @coords=#{coords.inspect}>"
  end
end

class GameOfLife
  def initialize
    @universe = Universe.new

    200.times do
      l = Location.new(Array.new(2).map{ rand(20)  })
      @universe << Cell.new(l)
    end
  end

  def run
    loop do
      print
      @universe.evolve
      break if @universe.empty?
      sleep 0.05
    end
  end

  def print
    STDOUT.print `clear`
    r = UniverseRenderer.new(@universe)
    r.render
  end
end

class UniverseRenderer
  def initialize(u)
    @universe = u
  end

  def render
    puts matrix.row_vectors.map { |v| v.to_a.join(' ') }
  end

  def matrix
    @matrix ||= Matrix.build(width, height) do |x, y|
      @universe[Location.with_bias(bias, x, y)].nil? ? ' ' : '*'
    end
  end

  def width
    (@universe.min[0]..@universe.max[0]).count
  end

  def height
    (@universe.min[1]..@universe.max[1]).count
  end

  def bias
    @bias ||= @universe.min
  end
end
