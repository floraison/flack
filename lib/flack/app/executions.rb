
# /executions/*
#
class Flack::App

  # GET /executions
  #
  def get_executions(env)

# TODO implement paging
    env['flack.rel'] = 'flack:executions'

    qs = CGI.parse(env['QUERY_STRING'] || '')
    statuses = qs['status']
    statuses = nil if statuses == []

    q = @unit.executions
    q = q.where(status: statuses) if statuses

    respond(env, q.all)
  end

  # GET /executions/<id>
  #
  def get_executions_i(env)

    env['flack.rel'] = 'flack:executions/id'

    if exe = @unit.executions[env['flack.args'][0]]
      respond(env, exe)
    else
      respond_not_found(env)
    end
  end

  # GET /executions/<exid>
  # GET /executions/<domain>
  # GET /executions/<domain>*
  # GET /executions/<domain>.*
  #
  def get_executions_s(env)

    arg = env['flack.args'][0]

    if arg.count('-') == 0
      get_executions_by_domain(env, arg)
    else
      get_executions_by_exid(env, arg)
    end
  end

  protected

  def get_executions_by_exid(env, exid)

    env['flack.rel'] = 'flack:executions/exid'

    if exe = @unit.executions[exid: exid]
      respond(env, exe)
    else
      respond_not_found(env)
    end
  end

  def get_executions_by_domain(env, dom)

    q = @unit.executions

    if m = dom.match(/\A([^*]+)\*+\z/)
      if m[1][-1, 1] == '.'
        env['flack.rel'] = 'flack:executions/domain-dot-star'
        q = q.where(Sequel.like(:domain, "#{m[1]}%"))
      else
        env['flack.rel'] = 'flack:executions/domain-star'
        q = q.where(
          Sequel[{ domain: m[1] }] |
          Sequel.like(:domain, "#{m[1]}.%"))
      end
    else
      env['flack.rel'] = 'flack:executions/domain'
      q = q.where(domain: dom)
    end

    respond(env, q.all)
  end
end

