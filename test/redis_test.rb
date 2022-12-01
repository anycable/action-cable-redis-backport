# frozen_string_literal: true

require "test_helper"
require_relative "common"
require_relative "channel_prefix"

class RedisAdapterTest < ActionCable::TestCase
  include CommonSubscriptionAdapterTest
  include ChannelPrefixTest

  def cable_config
    { adapter: "redis", driver: "ruby" }.tap do |x|
      if host = ENV["REDIS_URL"]
        x[:url] = host
      end
    end
  end

  def test_reconnections
    subscribe_as_queue("channel") do |queue|
      subscribe_as_queue("other channel") do |queue_2|
        @tx_adapter.broadcast("channel", "hello world")

        assert_equal "hello world", queue.pop

        drop_pubsub_connections
        wait_pubsub_connection(redis_conn, "channel")

        @tx_adapter.broadcast("channel", "hallo welt")

        assert_equal "hallo welt", queue.pop

        drop_pubsub_connections
        wait_pubsub_connection(redis_conn, "channel")
        wait_pubsub_connection(redis_conn, "other channel")

        @tx_adapter.broadcast("channel", "hola mundo")
        @tx_adapter.broadcast("other channel", "other message")

        assert_equal "hola mundo", queue.pop
        assert_equal "other message", queue_2.pop
      end
    end
  end

  private
    def redis_conn
      @redis_conn ||= ::Redis.new(cable_config.except(:adapter))
    end

    def drop_pubsub_connections
      # Emulate connection failure by dropping all connections
      redis_conn.client("kill", "type", "pubsub")
    end

    def wait_pubsub_connection(redis_conn, channel, timeout: 2)
      wait = timeout
      loop do
        break if redis_conn.pubsub("numsub", channel).last > 0

        sleep 0.1
        wait -= 0.1

        raise "Timed out to subscribe to #{channel}" if wait <= 0
      end
    end
end

class RedisAdapterTest::AlternateConfiguration < RedisAdapterTest
  def cable_config
    alt_cable_config = super.dup
    alt_cable_config.delete(:url)
    url = URI(ENV["REDIS_URL"] || "")
    alt_cable_config.merge(host: url.hostname || "127.0.0.1", port: url.port || 6379, db: 12)
  end
end
