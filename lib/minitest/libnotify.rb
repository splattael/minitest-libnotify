require 'minitest/unit'
require 'libnotify'
require 'minitest/libnotify/version'

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
    def initialize io
      @io = io
      @libnotify = begin
        require 'libnotify'
        ::Libnotify.new(:timeout => 2.5, :append => false)
      rescue => e
        warn e
        false
      end
    end

    def puts(*o)
      if @libnotify && o.first =~ /(\d+) failures, (\d+) errors/
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
      end
      @io.puts(*o)
    end

    def method_missing(msg, *args, &block)
      @io.send(msg, *args, &block)
    end
  end
end

MiniTest::Unit.output = MiniTest::Libnotify.new(MiniTest::Unit.output)
