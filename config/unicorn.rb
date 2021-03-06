require 'tmpdir'
worker_processes Integer(ENV['WORKER_PROCESSES'] || 4)
timeout 25
preload_app true
data_dir = ENV['DATA_DIR'] || Dir.tmpdir
listen "unix:#{data_dir}/forum.sock", :backlog => 512
pid "#{data_dir}/forum_unicorn.pid"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Waiting for master to send QUIT'
  end
  ::Mongoid.default_session.disconnect
end
