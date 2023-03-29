
#
# Specifying flack
#
# Wed Sep 14 14:03:37 JST 2016
#

require 'pp'
#require 'ostruct'

require 'flack'


module Helpers

  def make_env(opts)

    me = opts[:method] || opts[:me] || 'GET'
    ho = opts[:host] || '127.0.0.1:7006'
    pa = opts[:path] || opts[:pa] || opts[:p] || '/'
    qs = opts[:query] || opts[:qs] || ''
    sn = opts[:script_name] || ''

    body = opts[:body]
    body = JSON.dump(body) if body && ! body.is_a?(String)
    ri = body ? StringIO.new(body) : nil

    { 'REQUEST_METHOD' => me,
      'PATH_INFO' => pa,
      'REQUEST_PATH' => pa,
      'QUERY_STRING' => qs,
      'REQUEST_URI' => "http://#{ho}#{pa}#{qs.empty? ? '' : '?'}#{qs}",
      'SCRIPT_NAME' => sn,
      'HTTP_HOST' => ho,
      'HTTP_VERSION' => 'HTTP/1.1',
      'rack.url_scheme' => 'http',
      'rack.input' => ri }
  end

  def jdump(o)

    o.nil? ? 'null' : JSON.dump(o)
  end

  def wait_until(timeout=14, frequency=0.1, &block)

    start = Time.now

    loop do

      sleep(frequency)

      #return if block.call == true
      r = block.call
      return r if r

      break if Time.now - start > timeout
    end

    fail "timeout after #{timeout}s"
  end
  alias :wait_for :wait_until

  def parse_response(res)

    o = OpenStruct.new
    o.status = res[0]
    o.headers = res[1]
    o.json = JSON.parse(res[2].first)
    o.embedded = o.json['_embedded']

    %w[ flack:executions flack:pointers ].each do |key|
      k = key.split(':').last
      o[k] = o.embedded[key]
    end if o.embedded

    o
  end
end

RSpec.configure { |c| c.include(Helpers) }


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

