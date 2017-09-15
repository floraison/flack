
#
# specifying flack
#
# Mon Sep 19 11:35:06 JST 2016
#

require 'spec_helper'


describe '/' do

  before :each do

    @app = Flack::App.new('envs/test/', start: false)
    #@unit.conf['unit'] = 'u'
    #@unit.hook('journal', Flor::Journal)
    #@unit.storage.migrate
    #@unit.start
  end

  after :each do

    #@unit.stop
    #@unit.storage.clear
    #@unit.shutdown
  end

  describe 'GET /' do

    it 'returns links to the various endpoints' do

      r = @app.call(make_env(path: '/'))

      expect(r[0]).to eq(200)
      expect(r[1]['Content-Type']).to eq('application/json')

      j = JSON.parse(r[2].first)

      expect(
        j['_links'].select { |k, v| k != 'curies' }
      ).to eqj({
        'self' => { href: '/' },
        'flack:executions' => { href: '/executions' }
      })

      expect(
        j['_links'].select { |k, v| k == 'curies' }
      ).to eqj({
        'curies' => [
          { name: 'flack',
            href: 'https://github.com/floraison/flack/blob/master/doc/rels.md#{rel}',
            templated: true }
        ]
      })

      f = j['_forms']['flack:forms/message']

      expect(
        f
      ).to eqj({
        'action' => '/message',
        'method' => 'POST',
        '_inputs' => { 'flack:forms/message-content' => { type: 'json' } }
      })
    end

    context 'when SCRIPT_NAME' do

      it 'returns links to the various endpoints' do

        r = @app.call(make_env(path: '/', script_name: '/flack'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(
          j['_links'].select { |k, v| k != 'curies' }
        ).to eqj({
          'self' => { href: '/flack/' },
          'flack:executions' => { href: '/flack/executions' }
        })
      end
    end
  end
end

