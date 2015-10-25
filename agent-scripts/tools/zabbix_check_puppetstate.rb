#!/usr/bin/env ruby

require 'yaml'

puppet_state = YAML.load_file('/var/lib/puppet/state/last_run_summary.yaml')

value = nil

ARGV.each do |arg|
  if value == nil
    value = puppet_state.fetch(arg)
  else
    value = value.fetch(arg)
  end
end

print "#{value}"
