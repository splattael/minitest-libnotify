module Minitest::Libnotify
  # Test notifier for minitest via libnotify.
  #
  # == Usage
  #
  # In your test helper put:
  #
  #   require 'minitest/autorun'
  #   require 'minitest/libnotify'
  #
  # == Config
  #
  #  require 'minitest/autorun'
  #  require 'minitest/libnotify'
  #
  #  reporter = MiniTest::Unit.output
  #  reporter.config[:global][:description]  = "TESTS"
  #  reporter.config[:pass][:description]    = proc { |desc| "#{desc} :)" }
  #  reporter.config[:fail][:description]    = proc { |desc| "#{desc} :(" }
  #  reporter.config[:fail][:icon_path]      = "face-crying.*"
  class Reporter < Minitest::AbstractReporter
    class << self
      attr_accessor :default_config
    end

    # Default configuration
    self.default_config = {
      :global => {
        :regexp       => /(\d+) failures, (\d+) errors/,
        :timeout      => 2.5,
        :append       => false,
        :description  => proc { [ defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby", RUBY_VERSION, RUBY_PLATFORM ].join(" ") },
      },
      :pass => {
        :description  => proc { |description| ":-) #{description}" },
        :urgency      => :critical,
        :icon_path    => "face-laugh.*"
      },
      :fail => {
        :description  => proc { |description| ":-( #{description}" },
          :urgency    => :critical,
            :icon_path  => "face-angry.*"
      }
    }

    attr_accessor :config

    def initialize(config = self.class.default_config)
      @results = []
      @libnotify = nil
      @config = config.dup
    end

    def record(result)
      @results << result
    end

    def report
      state = @results.all?(&:passed?) ? :pass : :fail
      notify(state)
    end

    private

    def notify(state)
      default_description = config_for(:description)
      libnotify.body      = config_for(:body, state, "wat")
      libnotify.summary   = config_for(:description, state, default_description)
      libnotify.urgency   = config_for(:urgency, state)
      libnotify.icon_path = config_for(:icon_path, state)
      libnotify.show!
    end

    def libnotify
      if @libnotify.nil?
        @libnotify = begin
                       require 'libnotify'
                       ::Libnotify.new(:timeout => config_for(:timeout), :append => config_for(:append))
                     rescue => e
                       warn e
                       false
                     end
      end
      @libnotify
    end

    def config_for(name, state=:global, default=nil)
      value = config[state][name] || config[:global][name]
      if value.respond_to?(:call)
        value.call(default)
      else
        value.nil? ? default : value
      end
    end
  end
end
