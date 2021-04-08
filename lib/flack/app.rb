# frozen_string_literal: true

require 'flack/app/helpers'
  #
require 'flack/app/index'
require 'flack/app/static'
require 'flack/app/message'
require 'flack/app/executions'
require 'flack/app/messages'
require 'flack/app/pointers'


class Flack::App

  attr_reader :unit

  def initialize(root, opts={})

    @root = root

    conf_path =
      root.end_with?(File::SEPARATOR + 'conf.json') ?
      root :
      File.join(@root, 'etc', 'conf.json')

    @unit = Flor::Unit.new(conf_path)

    @unit.start unless opts[:start] == false

    self.class.unit = @unit

    @unit
  end

  def shutdown

    @unit.shutdown
  end

  def self.unit
    @unit
  end
  def self.unit=(u)
    @unit = u
  end

  def call(env)

    flack_path_info = (env['PATH_INFO'][1..-1] || '')
      .split('/')

    flack_path_info = [ 'index' ] if flack_path_info.empty?

    env['flack.path_info'] = flack_path_info

    METHS.each do |m|

      next if env['REQUEST_METHOD'] != m[1]
      next if flack_path_info.length != m[2].length

      match = true
      args = []

      for i in 0..(flack_path_info.length - 1)

        break unless match

        pi = flack_path_info[i]
        mi = m[2][i]

        break if mi == 'plus' || mi == 'star'

        if mi == 'i'
          match = pi.match(/\A\d+\z/)
          args << pi.to_i
        elsif mi == 's'
          args << pi
        elsif mi.is_a?(Regexp)
          match = pi.match(mi)
        else
          match = (pi == mi)
        end
      end

      next unless match

      env['flack.args'] = args
      env['flack.query_string'] = Rack::Utils.parse_query(env['QUERY_STRING'])
      env['flack.root_uri'] = determine_root_uri(env)

      return send(m[0], env)
    end

    respond_not_found(env)

  rescue => err

    $stderr.puts '=' * 80
    $stderr.puts Time.now.to_s
    $stderr.puts err.inspect
    $stderr.puts err.backtrace
    $stderr.puts ('=' * 79) + '.'

    respond_internal_server_error(env, err)
  end

  def get_debug(env); debug_respond(env); end
  alias get_debug_i get_debug

  METHS = instance_methods
    .collect(&:to_s)
    .select { |m| m.match(/\A(get|head|put|post|delete)_.+\z/) }
    .select { |m| instance_method(m).arity == 1 }
    .sort
    .collect { |m|
      s = m.split('_')
      if s.length == 3 && s[2] == 'suffix'
        [ m, s.shift.upcase, [ /\.#{s[0]}\z/ ] ]
      else
        [ m, s.shift.upcase, s ]
      end }
    .collect(&:freeze).freeze
end

