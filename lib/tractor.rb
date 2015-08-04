require 'redis'
require 'suppress_output'

module Tractor
  class << self
    def ipc
      setup_redis
      patch_Integer_shamelessly
    end

    private

    def setup_redis
      suppress_output do
        socket = File.expand_path 'tractor.sock'

        redis_pid, parent_pid = (spawn "redis-server --port 0 --unixsocket #{socket}"), Process.pid
        at_exit { `kill #{redis_pid}` if Process.pid == parent_pid }

        const_set :R, (Redis.new path: socket)
        sleep 0.01 until File.exist? socket
      end
    end

    def patch_Integer_shamelessly
      Integer.class_eval do
        def put message
          R.rpush self, message
        end

        def get
          (R.blpop [self])[1]
        end
      end
    end
  end
end
