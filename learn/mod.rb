require 'ap'

module Learn

  class Testee
    attr_accessor :name
    def initialize(name: 'n/a')
      @name = name
    end
  end

  def hello
    "hello"
  end

  def goodbye
    "goodbye"
  end

end


class Song
  include Comparable
  attr_reader :duration
  def initialize(name,artist,rank)
    @name = name
    @artist = artist
    @duration = rank
  end
  def <=>(other)
    self.duration <=> other.duration
  end
end

song1 = Song.new('my way', 'sinatra', 225)
song2 = Song.new('help', 'the beatles', 125)

ap (song1 <=> song2)
ap (song1 <   song2)
ap (song1 >   song2)
ap (song1 ==  song2)

