
# /messages/*
#
class Flack::App

  # GET /messages
  def get_messages(env)

# TODO implement paging
    respond(env, @unit.messages.all)
  end

  # GET /messages/<id>
  def get_messages_i(env)

    exe = @unit.messages[env['flack.args'][0]]
    return respond_not_found(env) unless exe
    respond(env, exe)
  end

  # GET /messages/<exid>
  def get_messages_s(env)

    exe = @unit.messages.where(exid: [env['flack.args'][0]]).last
    return respond_not_found(env) unless exe
    respond(env, exe)
  end
end
