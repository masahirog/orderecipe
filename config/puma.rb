require 'puma_worker_killer'


# max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
# min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
# threads min_threads_count, max_threads_count

# port ENV.fetch("PORT") { 3000 }
# environment ENV.fetch("RAILS_ENV") { "development" }
# pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# plugin :tmp_restart

# PumaWorkerKiller.enable_rolling_restart # 定期再起動を有効化

# if ENV['RAILS_ENV'] == 'production'
#   workers ENV.fetch("WEB_CONCURRENCY") { 2 }
#   preload_app!
  
#   on_worker_boot do
#     puts "Worker booting... Starting PumaWorkerKiller"
#     PumaWorkerKiller.config do |config|
#       config.ram           = ENV.fetch('PUMA_WORKER_RAM') { 1024 }.to_i
#       config.frequency     = 10
#       config.percent_usage = 0.90
#       config.rolling_restart_frequency = 6 * 3600
#       config.reaper_status_logs = true
#     end
#     PumaWorkerKiller.start
#   end
# end



max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
plugin :tmp_restart
if ENV.fetch("RAILS_ENV") == "production"
  workers Integer(ENV['WEB_CONCURRENCY'] || 2)
  # before_fork do
  #   PumaWorkerKiller.config do |config|
  #     config.ram           = 1024 # 単位はMB。デフォルトは512MB
  #     config.frequency     = 10    # 単位は秒
  #     config.percent_usage = 0.90 # ramを90%以上を使用したらワーカー再起動
  #     config.rolling_restart_frequency = 6 * 3600 # 6時間
  #   end
  #   PumaWorkerKiller.start
  # end

  PumaWorkerKiller.config do |config|
    config.ram           = 1024
    config.frequency     = 10   # 秒
    config.percent_usage = 0.30 # RAM使用率90%超で再起動
    config.rolling_restart_frequency = 6 * 3600 # 6時間ごとに再起動
    config.reaper_status_logs = true # ログを有効化（任意）
  end
  on_worker_boot do
    PumaWorkerKiller.start # 各Workerの起動時にPumaWorkerKillerを有効化
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end