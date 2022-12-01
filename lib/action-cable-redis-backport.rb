# frozen_string_literal: true

require "action_cable"

return if ActionCable::VERSION::MAJOR >= 7 && ActionCable::VERSION::MINOR >= 1

require "action_cable/subscription_adapter/redis"

module ActionCableRedisBackport
  ActionCable::SubscriptionAdapter::Redis::Listener.prepend(Module.new do
    def initialize(*)
      super

      return if instance_variable_defined?(:@reconnect_attempt)

      @subscribed_client = @raw_client = nil

      @reconnect_attempt = 0
      @reconnect_attempts = ::ActionCable.server.config.cable&.fetch("reconnect_attempts", 1)
      @reconnect_attempts = Array.new(@reconnect_attempts, 0) if @reconnect_attempts.is_a?(Integer)
    end

    private
      if ::Redis::VERSION < "5"
        ConnectionError = ::Redis::ConnectionError
      else
        ConnectionError = RedisClient::ConnectionError
      end

      def ensure_listener_running
        @thread ||= Thread.new do
          Thread.current.abort_on_exception = true

          begin
            conn = @adapter.redis_connection_for_subscriptions
            listen conn
          rescue ConnectionError
            reset
            if retry_connecting?
              when_connected { resubscribe }
              retry
            end
          end
        end
      end

      def retry_connecting?
        @reconnect_attempt += 1

        return false if @reconnect_attempt > @reconnect_attempts.size

        sleep_t = @reconnect_attempts[@reconnect_attempt - 1]

        sleep(sleep_t) if sleep_t > 0

        true
      end

      def resubscribe
        channels = @sync.synchronize do
          @subscribers.keys
        end
        return if channels.empty?

        if @subscribed_client
          @subscribed_client.subscribe(*channels)
        else
          send_command("subscribe", *channels)
        end
      end

      def reset
        @subscription_lock.synchronize do
          @subscribed_client = @raw_client = nil
          @subscribe_callbacks.clear
          @when_connected.clear
          when_connected { @reconnect_attempt = 0 }
        end
      end
  end)
end
