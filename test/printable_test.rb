require 'minitest/autorun'
require 'minitest/power_assert'

require 'simple-printable'

class Test < MiniTest::Test

  class A

    attr_accessor :x
    attr_accessor :y

    include Simple::Printable

    def initialize
      @x = 'x'
      @y = 'y'
    end

    def printable
      [
        :x,
        [:y, 'Y', proc { @y } ],
      ]
    end

  end

  class B < A

    attr_accessor :z

    def initialize
      super
      @z = 'z'
    end

    def printable
      super + [
        Simple::Printable::Field.new(:z, 'Z', proc { @z }),
      ]
    end

  end

  class D

    attr_accessor :d

    include Simple::Printable

    def initialize
      @d = 'd'
    end

    def printable
      [
        :d,
      ]
    end

  end

  class C < A

    attr_accessor :d

    def initialize
      super
      @d = 3.times.map { D.new }
    end

    def printable
      super + [:d]
    end

  end

  def test_simple
    a = A.new
    output = a.print(output: nil).split("\n")
    assert {
      output == [
        'X: x',
        'Y: y',
      ]
    }
  end

  def test_inherited
    b = B.new
    output = b.print(output: nil).split("\n")
    assert {
      output == [
        'X: x',
        'Y: y',
        'Z: z',
      ]
    }
  end

  def test_nested
    c = C.new
    output = c.print(output: nil).split("\n")
    assert {
      output == [
        'X: x',
        'Y: y',
        'D: ',
        '   D: d',
        '   D: d',
        '   D: d',
      ]
    }
  end

end