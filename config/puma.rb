threads ENV['PUMA_MIN_THREADS'].to_i, ENV['PUMA_MAX_THREADS'].to_i
workers ENV['PUMA_NUM_WORKERS'].to_i

# Invoke Puma.stats from the main process
if ENV['LOG_PUMA_STATS']
  before_fork do
    Thread.new do
      loop do
        puts Puma.stats
        sleep 30
      end
    end
  end
end
