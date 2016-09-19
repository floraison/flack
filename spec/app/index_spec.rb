
#
# specifying flack
#
# Mon Sep 19 11:35:06 JST 2016
#

require 'spec_helper'


describe '/' do

  before :each do

    @app = Flack::App.new('envs/test/')
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
        j['_links']
      ).to eqj({
        self: {
          href: '/' },
        executions: {
          href: '/executions',
          rel: 'https://github.com/floraison/flack/blob/master/doc/rels.md#executions' }
      })
    end
  end
end

