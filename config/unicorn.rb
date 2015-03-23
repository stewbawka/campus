app_dir = File.expand_path('../../', __FILE__)
shared_dir = File.expand_path('../../shared/', __FILE__)

# unicorn options
if ENV["RAILS_ENV"] == "development"
  worker_processes 1
else
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
end

timeout 10
preload_app true

working_directory app_dir

listen "#{shared_dir}/sockets/unicorn.sock", backlog: 64

stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

pid = "#{shared_dir}/pids/unicorn.pid"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  old_pid = "#{app_dir}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  Mongoid::Config.load!("#{Rails.root}/config/mongoid.yml")
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
end

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{app_dir}/Gemfile"
end
