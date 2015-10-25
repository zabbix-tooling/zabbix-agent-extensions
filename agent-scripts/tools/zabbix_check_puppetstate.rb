#!/usr/bin/env ruby

require 'yaml'

#puppet_state=YAML.load_file('/var/lib/puppet/state/last_run_summary.yaml')

puppet_state=YAML.load_file('/home/nschaeffler/Documents/work/git/zabbix-agent-extensions/agent-scripts/tools/foo.yaml')

if (ARGV.lenght == 1)
  puts "Argument: #{ARGV[0]} #{puppet_state.fetch(ARGV[0])}"
elseif (ARGV.lenght == 2)
  puts "Argument: #{ARGV[0]} / #{ARGV[1]} #{puppet_state.fetch(ARGV[0]).fetch(ARGV[1])}"
end

