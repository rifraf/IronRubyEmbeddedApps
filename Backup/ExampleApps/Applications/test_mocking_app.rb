require 'test/unit'
require 'flexmock/test_unit'

# ================================================
class TestDog < Test::Unit::TestCase

  def test_dog_wags
    tail_mock = flexmock(:wag => :happy)
    assert_equal :happy, tail_mock.wag
  end

  def test_dog_wags_not
    tail_mock = flexmock(:wag => :sad)
    assert_equal :happy, tail_mock.wag
  end

end

# TODO: test failures fail on reporting. location??
