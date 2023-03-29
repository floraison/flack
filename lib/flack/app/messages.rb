# frozen_string_literal: true

# /messages/*
#
class Flack::App

  # GET /messages
  def get_messages(env)

# TODO implement paging
    env['flack.rel'] = 'flack:messages'

# TODO {?exid,dexid,count} like for /executions and /pointers

    respond(env, @unit.messages.all)
  end

  # GET /messages/<id>
  def get_messages_i(env)

    env['flack.rel'] = 'flack:messages'

    if exe = @unit.messages[env['flack.args'][0]]
      respond(env, exe)
    else
      respond_not_found(env)
    end
  end

  # GET /messages/<exid>
  def get_messages_s(env)

# TODO implement paging
    arg = env['flack.args'][0]

    if Flor.point?(arg)
      get_messages_by_point(env, arg)
    else
      get_messages_by_exid(env, arg)
    end
  end

  # GET /messages/<exid>/<point>
  def get_messages_s_s(env)

    env['flack.rel'] = 'flack:messages/exid/point'

    exid, point = env['flack.args']

    respond(
      env,
      @unit.messages.where(exid: exid, point: point).all)
  end

  protected

  def get_messages_by_exid(env, exid)

    env['flack.rel'] = 'flack:messages/exid'

    respond(env, @unit.messages.where(exid: exid).all)
  end

  def get_messages_by_point(env, point)

    env['flack.rel'] = 'flack:messages/point'

    respond(env, @unit.messages.where(point: point).all)
  end
end

