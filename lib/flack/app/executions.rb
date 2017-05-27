
# /executions/*
#
class Flack::App

  def get_executions(env)

# TODO implement paging
    respond(env, @unit.executions.all)
  end

  def get_executions_i(env)

# TODO
    debug_respond(env)
  end
end

