# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
YARD::Rake::YardocTask.new(:doc)

desc "Start an interactive console"
task :console do
  require "bundler/setup"
  require "irb"
  require "zotero"
  ARGV.clear
  IRB.start
end

task default: %i[spec rubocop]
