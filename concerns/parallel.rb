require "thread"  # for Mutex

module Parallel
  def iterate_over_parallel(iterable)
    mutex = Mutex.new

    ENV["THREADS_COUNT"].to_i.times.map do
      Thread.new(iterable) do |iterable|
        while element = mutex.synchronize { iterable.pop }
          yield(mutex, element)
        end
      end
    end.each(&:join)
  end

  def summarize_parallel(iterable)
    mutex = Mutex.new
    result = []
    
    iterate_over_parallel(iterable) do
      mutex.synchronize { result.concat(yield(mutex, element)) }
    end

    result
  end
end
