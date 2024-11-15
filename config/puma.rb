require 'puma_worker_killer'

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

plugin :tmp_restart

PumaWorkerKiller.enable_rolling_restart # 定期再起動を有効化

if ENV['RAILS_ENV'] == 'production'
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }
  preload_app!
  
  on_worker_boot do
    # PumaWorkerKillerの設定
    PumaWorkerKiller.config do |config|
      config.ram           = ENV.fetch('PUMA_WORKER_RAM') { 1024 }.to_i
      config.frequency     = 10
      config.percent_usage = 0.90
      config.rolling_restart_frequency = 6 * 3600
    end
    PumaWorkerKiller.start
  end
end