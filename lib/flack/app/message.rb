
# /message
#
class Flack::App

  def post_message(env)

    msg = JSON.load(env['rack.input'].read)

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
    vars = msg['vars'] || {}
    fields = msg['fields'] || {}

    return respond_bad_request(env, 'missing "tree" or "name" in launch msg') \
      unless src

    opts = {}
    opts[:domain] = dom
    opts[:vars] = vars
    opts[:fields] = fields

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

