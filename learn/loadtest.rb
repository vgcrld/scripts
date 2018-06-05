require 'tempfile'

module Runner

  class Writer

    Thread::abort_on_exception = true

    attr :queue, :result, :thread

    def initialize
      @queue = Queue.new
      @result = Queue.new
      @thread = start_thread
    end

    private 

    def start_thread
      td = Thread.new do
        until (data=@queue.pop) == :stop
          eval data
        end
      end
      return td
    end

  end
  
end
