require 'minitest/libnotify'

module Minitest
  def self.plugin_libnotify_init(options)
    Minitest.reporter << Minitest::Libnotify::Reporter.new
  end
end
