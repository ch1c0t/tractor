require 'redis'

module Tractor
  class << self
    def ipc
      setup_redis
      patch_Integer_shamelessly
    end

    private

    def setup_redis
      stdout = $stdout.clone
      $stdout.reopen (File.new '/dev/null', 'w')

      redis_pid = spawn 'redis-server --port 0 --unixsocket tractor.sock'
      parent_pid = Process.pid
      at_exit { `kill #{redis_pid}` if Process.pid == parent_pid }

      const_set :R, (Redis.new path: 'tractor.sock')
      sleep 0.01 until File.exist? 'tractor.sock'

      $stdout = stdout
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
