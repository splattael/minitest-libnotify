require 'minitest/unit'
require 'libnotify'

module MiniTest
  # Test notifier for minitest via libnotify.
  #
  # == Usage
  #
  # In your test helper put:
  #
  #   require 'minitest/autorun'
  #   require 'minitest/libnotify'
  #
  class Libnotify
    VERSION = "0.0.1"

    def initialize io
      @io = io
      @libnotify = begin
        require 'libnotify'
        ::Libnotify.new(:timeout => 2.5, :append => false)
      end
    end

    def puts(*o)
      if o.first =~ /(\d+) failures, (\d+) errors/
        description = [ defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby", RUBY_VERSION, RUBY_PLATFORM ].join(" ")
        @libnotify.body = o.first
        if $1.to_i > 0 || $2.to_i > 0 # fail?
          @libnotify.summary = ":-( #{description}"
          @libnotify.urgency = :critical
          @libnotify.icon_path = "face-angry.*"
        else
          @libnotify.summary += ":-) #{description}"
          @libnotify.urgency = :normal
          @libnotify.icon_path = "face-laugh.*"
        end
        @libnotify.show!
      else
        @io.puts(*o)
      end
    end

    def method_missing(msg, *args, &block)
      @io.send(msg, *args, &block)
    end
  end
end

MiniTest::Unit.output = MiniTest::Libnotify.new(MiniTest::Unit.output)
