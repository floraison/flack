
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

  {
    'REQUEST_METHOD' => opts[:method] || 'GET',
    'PATH_INFO' => pa,
    'REQUEST_PATH' => pa,
    'QUERY_STRING' => qs,
    'REQUEST_URI' => "http://#{ho}#{pa}#{qs.empty? ? '' : '?'}#{qs}",
    'HTTP_HOST' => ho,
    'HTTP_VERSION' => 'HTTP/1.1'
  }
end

#RSpec::Matchers.define :eqd do |o|
#
#  o0 = o
#  o = Flor.to_d(o) unless o.is_a?(String)
#  o = o.strip
#
#  match do |actual|
#
#    return Flor.to_d(actual) == o
#  end
#
#  failure_message do |actual|
#
#    "expected #{o}\n" +
#    "     got #{Flor.to_d(actual)}"
#  end
#end

