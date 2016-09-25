
#
# specifying flack
#
# Wed Sep 14 14:05:53 JST 2016
#

require 'spec_helper'


describe '/executions' do

  before :each do

    @app = Flack::App.new('envs/test/etc/conf.json', start: false)
    @app.unit.conf['unit'] = 'u'
    #@app.unit.hook('journal', Flor::Journal)
    @app.unit.storage.migrate
    @app.unit.storage.clear
    @app.unit.start
  end

  after :each do

    @app.unit.stop
    @app.unit.storage.clear
    @app.unit.shutdown
  end

  describe 'GET /executions' do

    context 'when no executions' do

      it 'lists zero executions' do

        r = @app.call(make_env(path: '/executions'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['_embedded']).to eq([])
      end
    end

    context 'with ongoing executions' do

      before :each do
        @exids = [
          @app.unit.launch(%{ stall _ }, domain: 'net.ntt'),
          @app.unit.launch(%{ stall _ }, domain: 'net.ntt')
        ]
        sleep 0.5
      end

      it 'lists the executions' do

        r = @app.call(make_env(path: '/executions'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        jn = JSON.parse(r[2].first)
        ed = jn['_embedded']

        expect(ed.collect { |e| e['exid'] }).to eq(@exids)
      end
    end
  end
end

