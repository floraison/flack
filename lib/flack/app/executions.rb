# frozen_string_literal: true

# /executions/*
#
class Flack::App

  # GET /executions
  # GET /executions?exid=<exid_prefix>
  # GET /executions?dexid=<date_exid_prefix>
  #
  def get_executions(env)

# TODO implement paging
    env['flack.rel'] = 'flack:executions'

    statuses = query_values(env, 'statuses', 'status')
    exid = query_value(env, 'exid')
    dexid = query_value(env, 'dexid')

    q = @unit.executions
      #
    q = q.where(status: statuses) if statuses
    q = q.where(Sequel.like(:exid, "#{exid}%")) if exid
    q = q.where(Sequel.like(:exid, "%-#{dexid}%")) if dexid
      #
    q = q.order(:exid)

    if query_value(env, 'count')
      respond(env, { count: q.count })
    else
      respond(env, q.all)
    end
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

  # DELETE /executions/<exid>
  #
  def delete_executions_s(env)

    exid = env['flack.args'][0]

    return respond_not_found(env) \
      unless @unit.executions.where(exid: exid).count > 0

    r = { exid: exid, counts: {} }
    cs = r[:counts]

    @unit.storage.db.transaction do

      cs[:messages] = @unit.messages.where(exid: exid).count
      cs[:executions] = @unit.executions.where(exid: exid).count
      cs[:pointers] = @unit.pointers.where(exid: exid).count
      cs[:timers] = @unit.timers.where(exid: exid).count
      cs[:traps] = @unit.traps.where(exid: exid).count
        #
        # not sure if the DB adapter returns the DELETE count,
        # so counting first

      @unit.messages.where(exid: exid).delete
      @unit.executions.where(exid: exid).delete
      @unit.pointers.where(exid: exid).delete
      @unit.timers.where(exid: exid).delete
      @unit.traps.where(exid: exid).delete
    end

    respond(env, r)
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

    statuses = query_values(env, 'statuses', 'status')

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

    q = q.where(status: statuses) if statuses

    respond(env, q.all)
  end
end

