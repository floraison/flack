#--
# Copyright (c) 2016-2016, John Mettraux, jmettraux+flor@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

require 'flack/app/executions'


class Flack::App

  def initialize(root)

    @root = root

    @unit = Flor::Unit
      .new(File.join(@root, 'etc/conf.json'))
      .start
  end

  def call(env)

    flack_path_info = env['PATH_INFO'][1..-1]
      .split('/')

    flack_path_info = [ 'index' ] if flack_path_info.empty?

    env['flack.path_info'] = flack_path_info

    METHS.each do |m|

      next if env['REQUEST_METHOD'] != m[1]
      next if flack_path_info.length != m[2].length

      match = true
      args = []

      for i in 0..flack_path_info.length - 1
        break unless match
        pi = flack_path_info[i]
        mi = m[2][i]
        if mi == 'i'
          match = pi.match(/\A\d+\z/)
          args << pi.to_i
        elsif mi == 's'
          args << pi
        else
          match = pi == mi
        end
      end

      next unless match

      env['flack.args'] = args
      env['flack.query_string'] = Rack::Utils.parse_query(env['QUERY_STRING'])

      return send(m[0], env)
    end

    four_o_four
  end

  def get_debug(env)

    [ 200,
      { 'Content-Type' => 'text/plain' },
      [ env.collect { |k, v| [ k, ': ', v.inspect, "\n" ] } ].flatten ]
  end

  alias get_debug_i get_debug

  def get_index(env)

# TODO
    [ 200, {}, [ "ok" ] ]
  end

  METHS = instance_methods
    .collect(&:to_s)
    .select { |m| m.match(/\A(get|head|put|post|delete)_.+\z/) }
    .select { |m| instance_method(m).arity == 1 }
    .collect { |m| s = m.split('_'); [ m, s.shift.upcase, s ] }
    .collect(&:freeze).freeze

  protected

  def four_o_four

    [ 404,
      { 'Content-Type' => 'application/json' },
      [ JSON.dump({ code: 404, text: 'Not Found' }) ] ]
  end
end

