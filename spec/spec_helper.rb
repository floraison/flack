
#
# Specifying flack
#
# Wed Sep 14 14:03:37 JST 2016
#

require 'pp'
#require 'ostruct'

require 'flack'


def make_env(opts)

  me = opts[:method] || 'GET'
  ho = opts[:host] || '127.0.0.1:7006'
  pa = opts[:path] || '/'
  qs = opts[:query] || ''
  sn = opts[:script_name] || ''

  body = opts[:body]
  body = JSON.dump(body) if body && ! body.is_a?(String)
  ri = body ? StringIO.new(body) : nil

  {
    'REQUEST_METHOD' => me,
    'PATH_INFO' => pa,
    'REQUEST_PATH' => pa,
    'QUERY_STRING' => qs,
    'REQUEST_URI' => "http://#{ho}#{pa}#{qs.empty? ? '' : '?'}#{qs}",
    'SCRIPT_NAME' => sn,
    'HTTP_HOST' => ho,
    'HTTP_VERSION' => 'HTTP/1.1',
    'rack.url_scheme' => 'http',
    'rack.input' => ri
  }
end

def jdump(o)

  o.nil? ? 'null' : JSON.dump(o)
end

RSpec::Matchers.define :eqj do |o|

  match do |actual|

    jdump(actual) == jdump(o)
  end

  failure_message do |actual|

    "expected #{jdump(o)}\n" +
    "     got #{jdump(actual)}"
  end

  #failure_message_for_should do |actual|
  #end
  #failure_message_for_should_not do |actual|
  #end
end

