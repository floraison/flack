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


# helpers
#
class Flack::App

  protected

  def debug_respond(env)

    [ 200, { 'Content-Type' => 'application/json' }, [ JSON.dump(env) ] ]
  end

  def respond(env, data, opts={})

    status = opts[:code] || opts[:status] || 200

    json = serialize(env, data, opts)
    json['_status'] = status
    json['_status_text'] = Rack::Utils::HTTP_STATUS_CODES[status]

    [ status, { 'Content-Type' => 'application/json' }, [ JSON.dump(json) ] ]
  end

  def try(o, meth)

    o.respond_to?(meth) ? o.send(meth) : nil
  end

  def serialize(env, data, opts)

    return serialize_array(env, data, opts) if data.is_a?(Array)

    r =
      (data.is_a?(Hash) ? Flor.dup(data) : nil) ||
      (data.nil? ? {} : nil) ||
      data.to_h

    #r['_klass'] = data.class.to_s # too rubyish
    r['_links'] = links(env)

    r
  end

  def serialize_array(env, data, opts)

    { '_links' => links(env),
      '_embedded' => data.collect { |e| serialize(env, e, opts) } }
  end

  def determine_root_uri(env)

    hh = env['HTTP_HOST'] || "#{env['SERVER_NAME']}:#{env['SERVER_PORT']}"

    "#{env['rack.url_scheme']}://#{hh}#{env['SCRIPT_NAME']}"
  end

  def abs(env, href)

    return href if href[0, 4] == 'http'
    "#{env['flack.root_uri']}#{href[0, 1] == '/' ? '': '/'}#{href}"
  end

  def link(env, h, type)

    h["flack:#{type}"] = { href: abs(env, "/#{type}") }
  end

  def links(env)

    h = {}

    h['self'] = {
      href: abs(env, env['REQUEST_PATH']) }
    h['curies'] = [{
      name: 'flack',
      href: 'https://github.com/floraison/flack/blob/master/doc/rels.md#{rel}',
      templated: true }]

    link(env, h, :executions)

    h
  end

  def respond_not_found(env); respond(env, {}, code: 404); end
end

