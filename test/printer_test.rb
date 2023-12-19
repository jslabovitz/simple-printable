require 'minitest/autorun'
require 'minitest/power_assert'

require 'simple-printer'

class Test < Minitest::Test

  class A

    attr_accessor :x
    attr_accessor :y

    include Simple::Printer::Printable

    def initialize
      @x = 'x'
      @y = 'y'
    end

    def printable
      [
        :x,
        [:y, 'Y', @y],
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
        Simple::Printer::Field.new(key: :z, label: 'Z', value: @z),
      ]
    end

  end

  class D

    attr_accessor :d

    include Simple::Printer::Printable

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
    output = a.print(output: nil)
    expected_output = <<~END
      X: x
      Y: y
    END
    assert { output == expected_output }
  end

  def test_inherited
    b = B.new
    output = b.print(output: nil)
    expected_output = <<~END
      X: x
      Y: y
      Z: z
    END
    assert { output == expected_output }
  end

  def test_nested
    c = C.new
    output = c.print(output: nil)
    expected_output = <<~END
      X: x
      Y: y
      D:
         D: d
         D: d
         D: d
    END
    assert { output == expected_output }
  end

  def test_standalone
    output = Simple::Printer.print(
      ['Foo', 'foo'],
      ['Bar', 2],
      output: nil)
    expected_output = <<~END
      Foo: foo
      Bar: 2
    END
    assert { output == expected_output }
  end

end