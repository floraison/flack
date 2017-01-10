#--
# Copyright (c) 2016-2017, John Mettraux, jmettraux+flor@gmail.com
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

  def is_response?(o)

    o.is_a?(Array) &&
    o.length == 3 &&
    o[0].is_a?(Fixnum) &&
    o[1].is_a?(Hash) &&
    o[2].is_a?(Array)
  end

  def respond(env, data, opts={})

    return data if opts == {} && is_response?(data)

    status = nil
    links = nil
    location = nil

    if data.is_a?(Hash)
      status = data['_status'] || data[:_status]
      links = data.delete('_links') || data.delete(:_links)
      location = data['_location'] || data[:_location]
    end

    status = status || opts[:code] || opts[:status] || 200

    headers = { 'Content-Type' => 'application/json' }
    headers['Location'] = location if location

    json = serialize(env, data, opts)

    json['_links'].merge!(links) if links

    json['_status'] = status
    json['_status_text'] = Rack::Utils::HTTP_STATUS_CODES[status]

    if e = opts[:error]; json['error'] = e; end

    [ status, headers, [ JSON.dump(json) ] ]
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
    r['_forms'] = forms(env)

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

  def rel(env, href)

    return href if href[0, 4] == 'http'
    "#{env['SCRIPT_NAME']}#{href[0, 1] == '/' ? '': '/'}#{href}"
  end

  def link(env, h, type)

    h["flack:#{type}"] = { href: rel(env, "/#{type}") }
  end

  def links(env)

    h = {}

    h['self'] = {
      href: rel(env, env['REQUEST_PATH']) }
    m = env['REQUEST_METHOD']
    h['self'][:method] = m unless %w[ GET HEAD ].include?(m)

    h['curies'] = [{
      name: 'flack',
      href: 'https://github.com/floraison/flack/blob/master/doc/rels.md#{rel}',
      templated: true }]

    link(env, h, :executions)

    h
  end

  def forms(env)

    h = {}

    h['flack:forms/message'] = {
      action: rel(env, '/message'),
      method: 'POST',
      _inputs: { 'flack:forms/message-content' => { type: 'json' } } }

    h
  end

  def respond_bad_request(env, error=nil)

    respond(env, {}, code: 400, error: error)
  end

  def respond_not_found(env, error=nil)

    respond(env, {}, code: 404, error: error)
  end
end

