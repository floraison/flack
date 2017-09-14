
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

  context 'when no executions' do

    describe 'GET /executions' do

      it 'lists zero executions' do

        r = @app.call(make_env(path: '/executions'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['_embedded']).to eq([])
      end
    end

    describe 'GET /executions/:exid' do

      it 'goes 404 when the execution does not exist' do

        r = @app.call(make_env(path: '/executions/exid_1'))

        expect(r[0]).to eq(404)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(nil)
      end
    end

    describe 'GET /executions/:id' do

      it 'goes 404 when the execution does not exist' do

        r = @app.call(make_env(path: '/executions/1'))

        expect(r[0]).to eq(404)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(nil)
      end
    end
  end

  context 'with ongoing executions' do

    before :each do

      @exids = (1..2)
        .collect { @app.unit.launch(%{ stall _ }, domain: 'net.ntt') }
        .sort
      @app.unit.wait('idle')
    end

    describe 'GET /executions' do

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
    end

    describe 'GET /executions/:exid' do

      it 'returns the execution' do

        r = @app.call(make_env(path: "/executions/#{@exids.first}"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(@exids.first)
      end
    end

    describe 'GET /executions/:id' do

      it 'returns the execution' do

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

