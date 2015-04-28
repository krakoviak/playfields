# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

root = File.dirname(__FILE__) + '/..'
set :output, "#{root}/log/cron_log.log"
# set :job_template, "bash -i -c ':job'"
# env :PATH, ENV['PATH']

every 1.minute do
  # command 'rvm --default use 2.2.1'
  rake 'get_build_info', environment => "development"
end