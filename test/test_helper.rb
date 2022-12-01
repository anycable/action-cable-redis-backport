# frozen_string_literal: true

require "action_cable"
require "active_support/testing/autorun"
require "active_support/testing/method_call_assertions"

require "action-cable-redis-backport"

# Set test adapter and logger
ActionCable.server.config.cable = { "adapter" => "test" }
ActionCable.server.config.logger = Logger.new(nil)

class ActionCable::TestCase < ActiveSupport::TestCase
  include ActiveSupport::Testing::MethodCallAssertions
end
