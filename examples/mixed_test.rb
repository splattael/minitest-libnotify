require "minitest/autorun"
#require "minitest/libnotify"

class PassTest < Minitest::Test
  def test_pass
    assert true
  end

  def test_fail
    fail
  end

  def test_skip
    skip
  end
end
