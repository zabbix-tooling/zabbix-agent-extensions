#!/usr/bin/env ruby

require 'rubygems'

require 'net/http'
require 'optparse'
require 'uri'

require 'json'
require 'erb'

SUCCESS          = 0
E_RUN            = 1
E_ARGV           = 3
E_NO_MATCH       = 5
E_NETWORK        = 7
E_ILLEGAL        = 9
E_INVALID_FILE   = 11
E_INVALID_SOURCE = 13

# json files principally are maps which MAY include arrays. arrays are
# indexed by natural numbers. hashes as key value pairs MAY use natural
# numbers either atomically or in string representation as keys. since it
# is not possible to disambiguate, any structures which may be arrays are
# casted to maps using the former index as new key.
cast2map   = lambda do |enum_obj|
  if enum_obj.kind_of?(Array)
    # TODO: first, commented out variant does not work with ruby1.8 on
    # TODO: target platform. needs to be adapted on migration possibility.
    #enum_obj.map.with_index { |val, idx| [idx.to_s, val] }.to_h
    tmp = []
    enum_obj.map.each_with_index { |val, idx| tmp << [idx.to_s, val] }
    Hash[tmp]
  else
    enum_obj
  end
end

# wrapper around http get and post requests
http_call  = {
    :GET  => lambda do |request_h|
      http = Net::HTTP.new(
          request_h[:uri].host,
          request_h[:uri].port
      )

      req = Net::HTTP::Get.new(
          request_h[:uri].request_uri
      )

      req.basic_auth(request_h[:uri].user,
                     request_h[:uri].password
      )

      begin
        http.request(req)
      rescue Timeout::Error => exc
        STDERR.puts 'ERROR: ' + exc.message
        exit(E_NETWORK)
      rescue Errno::ETIMEDOUT => exc
        STDERR.puts 'ERROR: ' + exc.message
        exit(E_NETWORK)
      rescue Errno::ECONNREFUSED => exc
        STDERR.puts 'ERROR: ' + exc.message
        exit(E_NETWORK)
      end
    end,
    :POST => lambda do |request_h|
      http = Net::HTTP.new(
          request_h[:uri].host,
          request_h[:uri].port
      )

      req      = Net::HTTP::Post.new(
          request_h[:uri].request_uri,
          init_header = {'Content-Type' => 'application/json'}
      )
      req.body = request_h[:body]

      begin
        http.request(req)
      rescue Timeout::Error => exc
        STDERR.puts 'ERROR: ' + exc.message
        exit(E_NETWORK)
      rescue Errno::ETIMEDOUT => exc
        STDERR.puts 'ERROR: ' + exc.message
        exit(E_NETWORK)
      rescue Errno::ECONNREFUSED => exc
        STDERR.puts 'ERROR: ' + exc.message
        exit(E_NETWORK)
      end
    end
}

# tree_query recursively returns values or branches from hash-tree.
# selectors may take * as wildcard, which returns branches.
# branches may be named after a tree property using the *[<name>] operator.
tree_query = lambda do |tree_h, selector_a|

  if tree_h.nil?
    STDERR.puts('Cannot select query nil-trees.')
    exit(E_NO_MATCH)
  elsif selector_a.nil?
    STDERR.puts('Cannot select after nil-selectors.')
    exit(E_ARGV)
  end


  if selector_a.size == 1
    if selector_a[0].to_s =~ /^\*/
      cast2map.call(tree_h)
    else
      cast2map.call(tree_h[selector_a[0].to_s])
    end

  else
    selector_head, *selector_tail = selector_a

    # wildcard query returns a number of (named) branches
    if selector_head.to_s =~ /^\*/

      # TODO: needs to be done properly with recursion, out of time
      branches = []
      tree_h.each_key do |key|

        branch = tree_query.call(tree_h[key],
                                 selector_tail)
        if selector_head.to_s =~ /^\*\[.*\]$/ # named branch
          branch_nominator = selector_head.to_s.match(/\[(.*)\]/)[1]
          branch_name      = tree_h[key][branch_nominator]
          branches << {branch_name => branch}
        else # anon branch
          branches << branch
        end

      end

      branches
    else # non-wildcard query returns leaf
      tree_query.call(cast2map.call(tree_h[selector_head.to_s]),
                      selector_tail)
    end

  end
end

validate_uri = lambda do |url|
  begin
    uri = URI.parse(url)

    unless uri.kind_of?(URI::HTTP)
      STDERR.puts('Protocol MUST be http.')
      exit(E_ARGV)
    end
    true
  rescue URI::InvalidURIError
    STDERR.puts('URI MUST be valid URI.')
    exit(E_ARGV)
  end
end

validate_json = lambda do |json_s|
  begin
    JSON.parse(json_s)
  rescue
    JSON::ParserError
    STDERR.puts('POST-payload MUST be valid json.')
    exit(E_INVALID_FILE)
  end
end

options   = {}
opt_parse = OptionParser.new do |opts|
  opts.banner = 'Usage: example.rb [options]'

  opts.on('-c',
          '--collate',
          'collate multpile pre-formatted zabbix auto-discovery endpoints') do |z|
    options[:collate] = true
  end

  opts.on('-f <filename>',
          '--file <filename>',
          'A file with http POSTable payload.') do |filename|

    # TODO: get advice how to properly pass a path for packaging _before_
    # TODO: packaging. I do not know how.
    fullpath = '/usr/share/zabbix-agent/' + filename
    #fullpath = File.dirname(__FILE__) + '/' + filename

    if !(filename =~ /\//)
      options[:file] = File.read(fullpath)
      validate_json.call(options[:file])
    else
      STDERR.puts('Files MUST be under script path in package.')
      exit(E_ILLEGAL)
    end
  end

  opts.on('-m [GET|POST]',
          '--http_method [GET|POST]',
          'The http method used to complete the query') do |m|
    if m =~ /^GET$|^POST$/i
      options[:http_method] = m.upcase.to_sym
    else
      STDERR.puts('Method MUST be either GET or POST.')
      exit(E_ARGV)
    end
  end

  opts.on('-o <format>',
          '--outformat <format>',
          'The format for the output string') do |o|
    if o =~ /^JSON$/i
      options[:output_format] = o.upcase.to_sym
    else
      STDERR.puts('output format MUST be either JSON or emtpy.')
      exit(E_ARGV)
    end
  end

  opts.on('-p <string>',
          '--params <string>',
          'Parameters rendered into the json data for a post request.') do |p|

    # parameters may consist of a list of key-value pairs
    key_value_explode = lambda do |key_value_a|
      if key_value_a.size == 1
        head, tail = key_value_a[0].split('=')
        { head.to_sym => tail.to_s }
      else
        head, *tail = key_value_a
        key_value_explode.call([head]).merge(key_value_explode.call(tail))
      end
    end

    options[:param] = key_value_explode.call(p.split(','))
  end

  opts.on('-s <expr>',
          '--selector <expr>',
          'Expression tree, IFS=\'.\', e.g. <expr1.expr2>') do |s|
    # <string>.kind_of?(Array) == true
    # splitting and iterating over array of string, it is necessary to have
    # individual strings atomic =! <String>
    options[:selector_a] = s.split('.').map(&:to_sym)
  end

  opts.on('-u <URI>',
          '--uri <URI>',
          '[http://][user:pass@]example.org[:<port>][/<path>]') do |u|


    auth_host_port_path_s, protocol_s = u.split(/:\/\//).reverse
    protocol_s                        = 'http' if protocol_s.nil?
    auth_host_port_s, path_s          = auth_host_port_path_s.split('/', 2)
    host_port_s, auth_s               = auth_host_port_s.split('@').reverse
    host_s, ports_group_s             = host_port_s.split(':')
    ports_clean_s                     = ports_group_s.gsub(/\[|\]/, '')
    ports_a                           = ports_clean_s.split(',')

    validate_uri.call(protocol_s + '://' + host_s + '/' + path_s)

    populate_uri_elements    = lambda do |ports_a|
      if ports_a.size == 1
        [{
             :protocol => protocol_s,
             :auth     => auth_s,
             :host     => host_s,
             :port     => ports_a[0],
             :path     => '/' + path_s
         }]
      else
        head, *tail = ports_a
        populate_uri_elements.call([head]).concat(populate_uri_elements.call(tail))
      end
    end
    options[:uri_elements_a] = populate_uri_elements.call(ports_a)
  end

  opts.on('-z',
          '--zabbix',
          'wrap output for zabbix auto-discovery') do |z|
    options[:zabbix] = true
  end

  opts.on_tail('-h',
               '--help',
               'Show this message') do
    puts opts
    exit(SUCCESS)
  end

end

begin
  opt_parse.parse!
  mandatory_args_a = [:http_method, :uri_elements_a]
  missing_args_a   = mandatory_args_a.select { |param| options[param].nil? }
  unless missing_args_a.empty?
    STDERR.puts 'Missing options: ' + missing_args_a.join(', ') + '.'
    STDERR.puts "\n" + opt_parse.to_s
    exit(E_ARGV)
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  STDERR.puts "\n" + opt_parse.to_s
  exit(E_ARGV)
end

construct_uris     = lambda do |uri_elements_a|
  if uri_elements_a.size == 1
    uri_elements = uri_elements_a[0]
    [
        URI::HTTP.new(
            uri_elements[:protocol],
            uri_elements[:auth],
            uri_elements[:host],
            uri_elements[:port],
            nil, #registry,
            uri_elements[:path],
            nil, #opaque,
            nil, #query,
            nil #fragment
        )
    ]
  else
    head, *tail = uri_elements_a
    construct_uris.call([head]).concat(construct_uris.call(tail))
  end
end
uris_a             = construct_uris.call(options[:uri_elements_a])

# TODO: make optional with GET?  many "RESTful" APIs use GET w payload to
# TODO: emulate POST. bad taste exists.
construct_requests = lambda do |uri_a|

  # certain application endpoints, e.g. elasticsearch, accept json-encoded
  # complex queries. erb is used to pass parameters given at command
  # invocation to predefined query templates
  erb_render = lambda do |file_content_s|
    if file_content_s =~ /<%=.*%>/
      renderer = ERB.new(file_content_s)
      renderer.result(binding)
    else
      file_content_s
    end
  end

  if uri_a.size == 1
    uri = uri_a[0]
    [
        {
            :uri  => uri,
            :body => erb_render.call(options[:file])
        }
    ]
  else
    head, *tail = uri_a
    construct_requests.call([head]).concat(construct_requests.call(tail))
  end
end
requests_a         = construct_requests.call(uris_a)

collect_responses       = lambda do |requests_a|
  if requests_a.size == 1
    request = requests_a[0]
    [{request[:uri].port => http_call[options[:http_method]].call(request)}]
  else
    head, *tail = requests_a
    collect_responses.call([head]).concat(collect_responses.call(tail))
  end
end
responses_a             = collect_responses.call(requests_a)

# TODO: deal with elasticsearch situations like cluster or shard
# TODO: failure etc which result in valid, but useless http responses
# TODO: alternatively decide and document how to defer such situations to
# TODO: monitoring tool, i.e. zabbix

populate_response_trees = lambda do |responses_a|
  if responses_a.size == 1
    port, response = responses_a[0].keys[0], responses_a[0].values[0]

    begin
      [{ port => JSON.parse(response.body) }]
    rescue JSON::ParserError
      STDERR.puts('Only json-sources can be queried.')
      exit(E_INVALID_SOURCE)
    end
  else
    head, *tail = responses_a
    populate_response_trees.call([head]).concat(populate_response_trees.call(tail))
  end
end
response_trees_a        = populate_response_trees.call(responses_a)

select_branches     = lambda do |response_trees_a|
  if response_trees_a.size == 1
    port, tree = response_trees_a[0].keys[0], response_trees_a[0].values[0]
    [{ port => tree_query.call(tree, options[:selector_a]) }]
  else
    head, *tail = response_trees_a
    select_branches.call([head]).concat(select_branches.call(tail))
  end
end
selected_branches_a = select_branches.call(response_trees_a)

if selected_branches_a.nil?
  STDERR.puts('No match.')
  exit(E_NO_MATCH)
end

if options[:zabbix]
  wrap4zabbix = lambda do |selected_branches_a|
    if selected_branches_a.size == 1
      port, values_a = selected_branches_a[0].first

      collect_values = lambda do |values_a|
        if values_a.size == 1
          [{
               '{#NAME}'.to_sym => values_a[0] + '_' + port.to_s,
               '{#PORT}'.to_sym => port.to_s,
               '{#ITEM}'.to_sym => values_a[0]
           }]
        else
          head, *tail = values_a
          collect_values.call([head]).concat(collect_values.call(tail))
        end
      end
      collect_values.call(values_a)
    else
      head, *tail = selected_branches_a
      wrap4zabbix.call([head]).concat(wrap4zabbix.call(tail))
    end
  end
  wrap        = {:data => wrap4zabbix.call(selected_branches_a)}
end

if options[:collate]
  collate_data_items = lambda do |selected_branches_a|
    if selected_branches_a.size == 1
      selected_branches_a[0].values[0]['data']
    else
      head, *tail = selected_branches_a
      collate_data_items.call([head]).concat(collate_data_items.call(tail))
    end
  end
  wrap               = {:data => collate_data_items.call(selected_branches_a)}
end

if (options[:zabbix] || options[:collate]) #implies JSON output
  puts wrap.to_json
else
  if options[:output_format] == 'JSON'.to_sym
    if selected_branches_a.size == 1
      port, tree = selected_branches_a[0].first
      puts tree.to_json
    else
      puts selected_branches_a.first.to_json
    end
  else
    if selected_branches_a.size == 1
      port, tree = selected_branches_a[0].first
      # kludge necessary for ruby1.8. TODO: clean when possible!
      puts tree.inspect
    else
      puts selected_branches_a.first
    end
  end
end
exit(SUCCESS)
