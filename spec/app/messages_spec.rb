
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

    @db = @app.unit.storage.db
  end

  after :each do

    @app.unit.shutdown
  end

  context 'when no executions' do

    describe 'GET /messages' do

      it 'returns an empty message list' do

        r = @app.call(make_env(path: '/messages'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['_embedded']).to eq([])
      end
    end

    describe 'GET /messages/:exid' do

      it 'returns an empty list' do

        r = @app.call(make_env(path: '/messages/exid_1'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(j['_embedded']).to eq([])
      end
    end

    describe 'GET /messages/:id' do

      it 'goes 404 if the message does not exist' do

        r = @app.call(make_env(path: '/messages/1'))

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

    describe 'GET /messages' do

      it 'lists all' do

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
    end

    describe 'GET /messages/:exid' do

      it 'returns all the messages with the given exid' do

        exid = @exids.first

        @app.unit.queue({ 'point' => 'cancel', 'exid' => exid, 'nid' => '0' })
        @app.unit.wait(exid, 'terminated')

        wait_until { @db[:flor_messages].where(status: 'consumed').count == 4 }

        r = @app.call(make_env(path: "/messages/#{exid}"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        ms = j['_embedded']

        expect(
          ms.size).to eq(3)
        expect(
          ms.collect { |e| e['point'] }).to eq(%w[ execute cancel terminated ])
        expect(
          ms.collect { |e| e['exid'] }.uniq).to eq([ exid ])
      end
    end

    describe 'GET /messages/:id' do

      it 'returns the message with the given id' do

        exid = @exids.first

        mr = @app.call(make_env(path: "/messages/#{exid}"))
        mj = JSON.parse(mr[2].first)
        mi = mj['_embedded'].first['id']

        r = @app.call(make_env(path: "/messages/#{mi}"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(exid)
      end
    end

    describe 'GET /messages/:exid/:point' do

      it 'lists the messages of an execution with a given point' do

        exid = @exids.first

        @app.unit.queue({ 'point' => 'cancel', 'exid' => exid, 'nid' => '0' })
        @app.unit.wait(exid, 'terminated')

        wait_until { @db[:flor_messages].where(status: 'consumed').count == 4 }

        r = @app.call(make_env(path: "/messages/#{exid}/execute"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(j['_embedded'].size).to eq(1)
        expect(j['_embedded'][0]['exid']).to eq(exid)
        expect(j['_embedded'][0]['point']).to eq('execute')

        r = @app.call(make_env(path: "/messages/#{exid}/terminated"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(j['_embedded'].size).to eq(1)
        expect(j['_embedded'][0]['exid']).to eq(exid)
        expect(j['_embedded'][0]['point']).to eq('terminated')
      end
    end
  end
end

