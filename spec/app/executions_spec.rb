
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
    @app.unit.storage.delete_tables
    @app.unit.storage.migrate
    @app.unit.start
  end

  after :each do

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

      it 'a item with zero executions by exid (not found)' do

        r = @app.call(make_env(path: '/executions/exid_1'))

        expect(r[0]).to eq(404)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(nil)
      end

      it 'a item with zero executions by id (not found)' do

        r = @app.call(make_env(path: '/executions/1'))

        expect(r[0]).to eq(404)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(nil)
      end
    end

    context 'with ongoing executions' do

      before :each do
        @exids = (1..2)
          .collect { @app.unit.launch(%{ stall _ }, domain: 'net.ntt') }
          .sort
        @app.unit.wait('idle')
      end

      it 'lists the executions' do

        r = @app.call(make_env(path: '/executions'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        jn = JSON.parse(r[2].first)
        ed = jn['_embedded']

        expect(
          ed.collect { |e| e['exid'] }.sort
        ).to eq(
          @exids
        )
      end

      it 'first item of the executions by exid' do

        r = @app.call(make_env(path: "/executions/#{@exids.first}"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(@exids.first)
      end

      it 'first item of the executions by id' do

        pr = @app.call(make_env(path: "/executions/#{@exids.first}"))
        pj = JSON.parse(pr[2].first)
        pi = pj['id']

        r = @app.call(make_env(path: "/executions/#{pi}"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(@exids.first)
      end

    end
  end
end

