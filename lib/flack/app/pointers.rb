# frozen_string_literal: true

# /pointers/*
#
class Flack::App

  # GET /pointers
  #
  def get_pointers(env)

# TODO implement paging
    env['flack.rel'] = 'flack:pointers'

    qs = CGI.parse(env['QUERY_STRING'] || '')
    types = qs['types'].collect { |e| e.split(',') }.flatten
    types = nil if types == []

    q = @unit.pointers
    q = q.where(type: types) if types

    respond(env, q.all)
  end

  # GET /pointers/<exid>
  # GET /pointers/<domain>
  # GET /pointers/<domain>*
  # GET /pointers/<domain>.*
  #
  def get_pointers_s(env)

    arg = env['flack.args'][0]

    qs = CGI.parse(env['QUERY_STRING'] || '')

    types = qs['types'].collect { |e| e.split(',') }.flatten
    types = nil if types == []

    if arg.count('-') == 0
      get_pointers_by_domain(env, arg, types)
    else
      get_pointers_by_exid(env, arg, types)
    end
  end

  protected

  def get_pointers_by_exid(env, exid, types)

    env['flack.rel'] = 'flack:pointers/exid'

    q = @unit.pointers.where(exid: exid)
    q = q.where(type: types) if types

    respond(env, q.all)
  end

  def get_pointers_by_domain(env, dom, types)

    q = @unit.pointers
    q = q.where(type: types) if types

    if m = dom.match(/\A([^*]+)\*+\z/)
      if m[1][-1, 1] == '.'
        env['flack.rel'] = 'flack:pointers/domain-dot-star'
        q = q.where(Sequel.like(:domain, "#{m[1]}%"))
      else
        env['flack.rel'] = 'flack:pointers/domain-star'
        q = q.where(
          Sequel[{ domain: m[1] }] |
          Sequel.like(:domain, "#{m[1]}.%"))
      end
    else
      env['flack.rel'] = 'flack:pointers/domain'
      q = q.where(domain: dom)
    end

    respond(env, q.all)
  end
end

