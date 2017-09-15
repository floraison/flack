
# /executions/*
#
class Flack::App

  # GET /executions
  #
  def get_executions(env)

# TODO implement paging
    respond(env, @unit.executions.all)
  end

  # GET /executions/<id>
  #
  def get_executions_i(env)

    exe = @unit.executions[env['flack.args'][0]]
    return respond_not_found(env) unless exe
    respond(env, exe)
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

    if exe = @unit.executions[exid: exid]
      respond(env, exe)
    else
      respond_not_found(env)
    end
  end

  def get_executions_by_domain(env, dom)

    q =
      @unit.executions
    q =
      if m = dom.match(/\A([^*]+)\*+\z/)
        if m[1][-1, 1] == '.'
          q.where(Sequel.like(:domain, "#{m[1]}%"))
        else
          q.where(Sequel[{ domain: m[1] }] | Sequel.like(:domain, "#{m[1]}.%"))
        end
      else
        q.where(domain: dom)
      end

    respond(env, q.all)
  end
end

