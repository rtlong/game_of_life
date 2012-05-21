require 'game_of_life'
require 'matrix'

describe "Game of Life" do

  it "games should allow adding cells at locations"  do
    g = Universe.new
    l = Location.new(1, 1)
    c = Cell.new(l)
    g << c
  end

  it "games should return cells by location index" do
    g = Universe.new
    l = Location.new(1, 1)
    c = Cell.new(l)
    g << c
    g[Location.new(1, 1)].should be(c)
    g[Location.new(1, 2)].should be_nil
  end

  it "games should allow iteration over live cells" do
    g = Universe.new
    5.times do |i|
      l = Location.new(1,i)
      c = Cell.new(l)
      g << c
    end
    i = 0
    g.each do |cell|
      i += 1
    end
    i.should be 5
  end

  it "games should allow counting live cells" do
    g = Universe.new
    5.times do |i|
      l = Location.new(1,i)
      c = Cell.new(l)
      g << c
    end
    g.count.should be 5
  end

  it "locations should yield to adjacent locations" do
    i = 0
    l = Location.new(1, 1)
    l.adjacent_locations.each do |loc|
      i += 1 if l.adjacent?(loc)
    end
    i.should be 8
  end

  it "should have locations" do
    l = Location.new(1, 1)
  end

  it "locations should be able to instantiate with a bias factor" do
    Location.with_bias([-1, -1], 1, 1).coords.should eq [0, 0]
    Location.with_bias([0, 0], 1, 1).coords.should eq [1, 1]
    Location.with_bias([5, -2], 2, 3).tap do |l|
      l.coords.should eq [7, 1]
      l.should be_a Location
    end
  end

  it "cells should have locations" do
    l = Location.new(1, 1)
    c = Cell.new(l)
    c.location.should eq Location.new(1, 1)
  end

  it "should allow reading coordinates" do
    l = Location.new(1, 2)
    l.coords.should eq [1, 2]
  end

  it "locations should know if they are adjacent" do
    map_bias = -2
    adjacent_map = Matrix[
      [0,0,0,0,0],
      [0,1,1,1,0],
      [0,1,0,1,0],
      [0,1,1,1,0],
      [0,0,0,0,0]
    ].map{|t| t == 1 ? true : false }
    l = Location.new 1, 1
    adjacent_map.each_with_index do |t, *offset|
      coords = offset.zip(l.coords).map{|v| v.reduce(:+) + map_bias}
      other = Location.new(*coords)

      l.adjacent?(other).should(t ? be_true : be_false, "Expected adjacent?(#{other}) to be #{t}, at adjacent_map#{offset}")
    end
  end

  it "locations should be hashable" do
    l1 = Location.new 1, 1
    l2 = Location.new 1, 1
    l1.hash.should == l2.hash
    l1.should eq l2
  end

  it "UniverseRenderer should create a matrix" do
    g = Universe.new
    g << Cell.new(Location.new(-5, 4))
    g << Cell.new(Location.new(3, -2))
    g << Cell.new(Location.new(6, -9))
    r = UniverseRenderer.new(g)

    m = r.matrix
    m[*Location.with_bias([5,9], -5, 4).coords].should_not be_nil
  end

  it "universe calculates its bounds" do
    g = Universe.new
    g << Cell.new(Location.new(-5, 4))
    g << Cell.new(Location.new(3, -2))
    g << Cell.new(Location.new(6, -9))

    g.max.should eq [ 6,  4]
    g.min.should eq [-5, -9]
  end

  it "should allow dead cells to spring to life" do
    g = Universe.new
    initial_cells = [[1,1],[1,2],[1,3]]
    initial_cells.each do |coords|
      g << Cell.new(Location.new(*coords))
    end
    g.evolve
    dead_locations = [[1,1],[1,3]]
    dead_locations.each do |coords|
      g[Location.new(*coords)].should be_nil, "live cell [#{coords.join(',')}] should have died"
    end
    surviving_locations = [[1,2]]
    surviving_locations.each do |coords|
      g[Location.new(*coords)].should_not be_nil, "live cell [#{coords.join(',')}] should have survived"
    end
    new_cells = [[0,2],[2,2]]
    new_cells.each do |coords|
      g[Location.new(*coords)].should_not be_nil, "dead cell [#{coords.join(',')}] should have come alive"
    end
  end

  it "UniverseRenderer calculates its height/width" do
    g = Universe.new
    g << Cell.new(Location.new(-5, 4))
    g << Cell.new(Location.new(3, -2))
    g << Cell.new(Location.new(6, -9))
    r = UniverseRenderer.new(g)

    r.width.should eq 12
    r.height.should eq 14

  end

  it "UniverseRenderer calculates its bias" do
    g = Universe.new
    g << Cell.new(Location.new(-5, 4))
    g << Cell.new(Location.new(3, -2))
    g << Cell.new(Location.new(6, -9))
    r = UniverseRenderer.new(g)

    r.bias.should eq [-5, -9]
  end
end
