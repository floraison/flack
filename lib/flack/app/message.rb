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


# /message
#
class Flack::App

  def post_message(env)

    msg = JSON.load(env['rack.input'].read)
#pp msg

    pt = msg['point']

    return respond_bad_request(env, 'missing msg point') \
      unless pt
    return respond_bad_request(env, "bad msg point #{pt.inspect}") \
      unless %w[ launch cancel ].include?(pt)

    r = self.send("queue_#{pt}", env, msg, { point: pt })

    respond(env, r)
  end

  protected

  def queue_launch(env, msg, ret)

    dom = msg['domain'] || 'domain0'
    src = msg['tree'] || msg['name']

    return respond_bad_request(env, 'missing "tree" or "name" in launch msg') \
      unless src

    opts = {}
    opts[:domain] = dom

    r = @unit.launch(src, opts)

    ret['exid'] = r
    ret['_status'] = 201
    ret['_location'] = rel(env, '/executions/' + r)

    ret['_links'] = {
      'flack:forms/message-created' => { 'href' => ret['_location'] } }

    ret
  end

  def queue_cancel(env, msg, ret)

    exid = msg['exid']
    nid = msg['nid'] || '0'

    return respond_bad_request(env, 'missing exid') \
      unless exid

    exe = @unit.executions[exid: exid]

    return respond_not_found(env, 'missing execution') \
      unless exe
    return respond_not_found(env, 'missing execution node') \
      unless exe.nodes[nid]

    ret['xxx'] = @unit.queue({ 'point' => 'cancel', 'exid' => exid, 'nid' => nid })

    ret['_status'] = 202
    ret['_location'] = rel(env, '/executions/' + exid)
    ret['_links'] = { 'flack:execution' => { 'href' => ret['_location'] } }

    ret
  end
end

