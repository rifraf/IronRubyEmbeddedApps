require 'test/unit'

# ================================================
class TestDemo < Test::Unit::TestCase

  def test_should_pass
	sum = 2 + 2
    assert_equal 4, sum
  end

  def test_should_fail
	sum = 2 + 2
    assert_equal 5, sum
  end

end