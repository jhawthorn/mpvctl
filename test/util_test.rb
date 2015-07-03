require 'test_helper'

module MpvCtl
  class UtilTest < Minitest::Test
    def test_parse_seconds
      assert_parsed 0, "0"
      assert_parsed 1, "1"
      assert_parsed 15, "15"
      assert_parsed 60, "60"
      assert_parsed 120, "120"
      assert_parsed 12345, "12345"
    end

    def test_parse_colon_separated
      assert_parsed 0, "0:00"
      assert_parsed 12, "0:12"
      assert_parsed 60, "1:00"
      assert_parsed 90, "1:30"
      assert_parsed 120, "2:00"
      assert_parsed 300, "5:00"
      assert_parsed 600, "10:00"
      assert_parsed 3600, "60:00"
      assert_parsed 5400, "90:00"
      assert_parsed 3600, "1:00:00"
      assert_parsed 3600, "01:00:00"
      assert_parsed 3661, "01:01:01"
      assert_parsed 86400, "24:00:00"
    end

    def test_parse_letters
      assert_parsed 0, "0s"
      assert_parsed 5, "5s"
      assert_parsed 60, "60s"
      assert_parsed 60, "1m"
      assert_parsed 65, "1m5s"
      assert_parsed 65, "1m5"
      assert_parsed 3600, "60m"
      assert_parsed 5400, "90m"
      assert_parsed 3600, "1h"
      assert_parsed 3661, "1h1m1s"
      assert_parsed 3605, "1h5s"
      assert_parsed 86400, "24h"
    end

    private
    def assert_parsed(expected, input)
      assert_equal expected, Util.parse_time(input), "Expected #{input.inspect} to parse to #{expected.inspect}"
    end
  end
end
