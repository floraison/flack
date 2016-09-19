
#
# specifying flack
#
# Wed Sep 14 14:05:53 JST 2016
#

require 'spec_helper'


describe '/executions' do

  before :each do

    @app = Flack::App.new('envs/test/etc/conf.json')
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

  describe 'GET /executions' do

    context 'when no executions' do

      it 'returns an empty result set' do

        r = @app.call(make_env(path: '/executions'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['_embedded']).to eq([])
      end
    end
  end
end

