#!/usr/bin/env ruby

require 'net/http'
require 'optparse'
require 'uri'

require 'json'
require 'erb'

cast2map = ->(enum_obj) {
  if enum_obj.kind_of?(Array)
    enum_obj.map.with_index { |val, idx| [idx.to_s, val] }.to_h
  else
    enum_obj
  end
}

tree_query = ->(tree, selector_a) {
  if tree.nil?
    nil
  elsif selector_a.size == 1
    cast2map.call(tree)[selector_a[0].to_s]
  else
    sel_head, *sel_tail = selector_a
    tree_query.call(cast2map.call(tree[sel_head.to_s]),
               sel_tail)
  end
}

validate_uri =->(url) {
  abort('URI is MANDATORY.') if url.nil?
  begin
    uri = URI.parse(url)
    abort('Protocol MUST be http.') unless uri.kind_of?(URI::HTTP)
    return true
  rescue # noinspection RubyResolve
    URI::InvalidURIError
    abort('URI must be valid URI.')
  end
}

validate_json =->(json_s) {
  begin
    JSON.parse(json_s)
  rescue JSON::ParserError
    abort('Not valid json. POST-payload can only be passed as json.')
  end
}

param_explode =->(params) {

  if params.size == 1
    head, tail = params[0].split('=')
    h          = {head.to_sym => tail.to_s}
    return h
  else
    head, *tail = params
    param_explode.call(tail).merge(param_explode.call([head]))
  end
}

erb_render = ->(file) {
  if file =~ /<%=.*%>/
    renderer = ERB.new(file)
    payload  = renderer.result(binding)
    payload
  else
    file
  end
}

http_call = {
    :GET  => ->(request_h) { Net::HTTP.get_response(request_h[:uri]) },
    :POST => ->(request_h) {

      http = Net::HTTP.new(
          request_h[:uri].host,
          request_h[:uri].port
      )

      req      = Net::HTTP::Post.new(
          request_h[:uri].request_uri,
          initheader = {'Content-Type' => 'application/json'}
      )
      req.body = request_h[:body]

      http.request(req)
    }
}

options   = {}
opt_parse = OptionParser.new do |opts|
  opts.banner = 'Usage: example.rb [options]'

  opts.on('-f <filename>',
          '--file <filename>',
          'A file with query data') do |filename|

    options[:file] = File.read(filename) #unless filename =~ /\//

    if ! options[:file].nil?
    validate_json.call(options[:file])
    else
      abort('Files outside script path are not supported for security reasons.')
    end


  end

  opts.on('-m [GET|POST]',
          '--http_method [GET|POST]',
          'The http method used to complete the query') do |m|
    if m =~ /^GET$|^POST$/i
      options[:http_method] = m.upcase.to_sym
    else
      abort('method MUST be either GET or POST.')
    end
  end

  opts.on('-p <string>',
          '--params <string>',
          'Parameters rendered into the json data for a post request.') do |p|

    options[:param] = param_explode.call(p.split(','))

  end

  opts.on('-s <expr>',
          '--selector <expr>',
          'Expression tree, IFS=\'.\', e.g. <expr1.expr2>') do |s|
    options[:selector] = s
  end

  opts.on('-u <URI>',
          '--uri <URI>',
          '[http://]example.org[:<port>][/<path>]') do |u|
    u.shift('http://') unless u =~ /:\/\// # default http
    options[:uri] = u if validate_uri.call(u)

  end

  opts.on_tail('-h',
               '--help',
               'Show this message') do
    puts opts
    exit
  end

end

begin
  opt_parse.parse!
  mandatory = [:http_method, :uri]
  missing   = mandatory.select { |param| options[param].nil? }
  unless missing.empty?
    puts "Missing options: #{missing.join(', ')}."
    puts '\n' + opt_parse.to_s
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts opt_parse
  exit
end

request_h = {
    :uri  => URI.parse(options[:uri]),
    :body => erb_render.call(options[:file])
}

response_h = http_call[options[:http_method]].call(request_h)

begin
  tree_h = JSON.parse(response_h.body)
rescue JSON::ParserError
  abort("#{$PROGRAM_NAME} does only support json-output.")
end

# <string>.kind_of?(Array) == true
# splitting and iterating over array of string, it is necessary to have
# individual strings atomic =! <String>
selector_a = options[:selector].split('.').map(&:to_sym)
value_s    = tree_query.call(tree_h, selector_a)

# TODO: deal with errors like cluster or shard failure etc

if value_s.nil?
  abort('No match.')
else
  puts value_s
end

