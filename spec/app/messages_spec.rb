
#
# specifying flack
#
# Thu Sep 14 16:53:46 JST 2017
#

require 'spec_helper'


describe '/messages' do

  before :each do

    @app = Flack::App.new('envs/test/etc/conf.json', start: false)
    @app.unit.conf['unit'] = 'u'
    #@app.unit.hook('journal', Flor::Journal)
    @app.unit.storage.archive = true
    @app.unit.storage.delete_tables
    @app.unit.storage.migrate
    @app.unit.start
  end

  after :each do

    @app.unit.shutdown
  end

  describe 'GET /messages' do

    context 'when no executions' do

      it 'messages with zero executions (empty)' do

        r = @app.call(make_env(path: '/messages'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['_embedded']).to eq([])
      end

      it 'a message with zero executions by exid (not found)' do

        r = @app.call(make_env(path: '/messages/exid_1'))

        expect(r[0]).to eq(404)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(nil)
      end

      it 'a message with zero executions by id (not found)' do

        r = @app.call(make_env(path: '/messages/1'))

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

      it 'lists of the messages' do

        r = @app.call(make_env(path: '/messages'))

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

      it 'first item of the messages by exid' do

        r = @app.call(make_env(path: "/messages/#{@exids.first}"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(@exids.first)
      end

      it 'first item of the messages by id' do

        pr = @app.call(make_env(path: "/messages/#{@exids.first}"))
        pj = JSON.parse(pr[2].first)
        pi = pj['id']

        r = @app.call(make_env(path: "/messages/#{pi}"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(@exids.first)
      end
    end
  end
end

