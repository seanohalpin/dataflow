require 'thread'

module Dataflow
  class Port  
    include Dataflow
    LOCK = Mutex.new

    class Stream
      include Dataflow
      declare :tail, :head
    
      # Defining each allows us to use the enumerable mixin
      # None of the list can be garbage collected less the head is
      # garbage collected, so it will grow indefinitely even though
      # the function isn't recursive.
      include Enumerable
      def each
        s = self
        while 1
          yield s.head
          s = s.tail
        end
      end
    end
  
    # Create a stream object, bind it to the input variable
    # Instance variables are necessary because @tail is state
    def initialize(x)
      @tail = Stream.new
      unify x, @tail
    end
  
    # This needs to be synchronized because it uses @tail as state
    def send value
      LOCK.synchronize do
        unify @tail.head, value
        unify @tail.tail, Stream.new
        @tail = @tail.tail
      end
    end
  end
end

