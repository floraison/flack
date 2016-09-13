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


class Flack::App

  def initialize
  end

  def call(env)

    flack_path_info = env['PATH_INFO'][1..-1]
      .split('/')
      .collect { |s| s.match(/\A\d+\z/) ? 'i' : s }

    meth = ([ env['REQUEST_METHOD'].downcase ] + flack_path_info)
      .join('_')
      .to_sym

    if respond_to?(meth) && method(meth).arity == 1
      env['flack.path_info'] = flack_path_info
      return send(meth, env)
    end

    four_o_four
  end

  def get_debug(env)

    [ 200,
      { 'Content-Type' => 'text/plain' },
      [ env.collect { |k, v| [ k, ': ', v.inspect, "\n" ] } ].flatten ]
  end

  protected

  def four_o_four

    [ 404,
      { 'Content-Type' => 'application/json' },
      [ JSON.dump({ code: 404, text: 'Not Found' }) ] ]
  end
end

