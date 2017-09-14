
# /executions/*
#
class Flack::App

  # GET /executions
  def get_executions(env)

# TODO implement paging
    respond(env, @unit.executions.all)
  end

  # GET /executions/<id>
  def get_executions_i(env)

    exe = @unit.executions[env['flack.args'][0]]
    return respond_not_found(env) unless exe
    respond(env, exe)
  end

  # GET /executions/<exid>
  def get_executions_s(env)

    exe = @unit.executions.where(exid: env['flack.args'][0]).last
    return respond_not_found(env) unless exe
    respond(env, exe)
  end
end

