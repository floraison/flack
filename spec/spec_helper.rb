
#
# Specifying flack
#
# Wed Sep 14 14:03:37 JST 2016
#

require 'pp'
#require 'ostruct'

require 'flack'


def make_env(opts)

  ho = opts[:host] || '127.0.0.1:7006'
  pa = opts[:path] || '/'
  qs = opts[:query] || ''
  sn = opts[:script_name] || ''

  {
    'REQUEST_METHOD' => opts[:method] || 'GET',
    'PATH_INFO' => pa,
    'REQUEST_PATH' => pa,
    'QUERY_STRING' => qs,
    'REQUEST_URI' => "http://#{ho}#{pa}#{qs.empty? ? '' : '?'}#{qs}",
    'SCRIPT_NAME' => sn,
    'HTTP_HOST' => ho,
    'HTTP_VERSION' => 'HTTP/1.1',
    'rack.url_scheme' => 'http'
  }
end


RSpec::Matchers.define :eqj do |o|

  match do |actual|

    JSON.dump(actual) == JSON.dump(o)
  end

  failure_message do |actual|

    "expected #{JSON.dump(o)}\n" +
    "     got #{JSON.dump(actual)}"
  end

  #failure_message_for_should do |actual|
  #end
  #failure_message_for_should_not do |actual|
  #end
end

