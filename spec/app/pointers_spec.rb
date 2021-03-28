
#
# specifying flack
#
# Sun Mar 28 10:52:09 JST 2021
#

require 'spec_helper'


describe '/pointers' do

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

    describe 'GET /pointers' do

      it 'returns an empty list' do

        r = @app.call(make_env(path: '/pointers'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['_embedded']).to eq({ 'flack:pointers' => [] })
      end
    end

    describe 'GET /pointers/:exid' do

      it 'returns an empty list' do

        r = @app.call(
          make_env(path: '/pointers/net.ntt.hr-u-20210328.0345.bizechotagu'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['_embedded']).to eq({ 'flack:pointers/exid' => [] })
      end
    end
  end

  context 'with ongoing executions' do

    before :each do

      @exids = [
        @app.unit.launch(
          %{ stall tag: 'talbot' },
          domain: 'net.ntt'),
        @app.unit.launch(
          %{ concurrence
               stall tag: 'turbo'
               remote 'galactic' },
          domain: 'net.ntt.hr'),
        @app.unit.launch(
          %{ set name 'bob'; set name a [ 1, 2 ]; stall _ },
          domain: 'net.ntt.finance') ]

      @app.unit.wait('idle')
    end

    describe 'GET /pointers' do

      it 'lists the pointers' do

        r = @app.call(make_env(path: '/pointers'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].keys
        ).to eq(%w[
          flack:pointers
        ])

        expect(
          j['_embedded'].values.first
            .sort_by { |e|
              e['id'] }
            .collect { |e| {
              d: e['domain'],
              t: e['type'], n: e['name'], v: e['value'], #da: e['data'],
              ni: e['nid'] } }
        ).to eq([
          { d: "net.ntt.finance",
            n: "name", ni: "0", t: "var", v: "1" },
          { d: "net.ntt.finance",
            n: "a", :ni=>"0", t: "var", v: "2" },
          { d: "net.ntt",
            n: "talbot", ni: "0", t: "tag", v: nil },
          { d: "net.ntt.hr",
            n: "turbo", ni: "0_0", t: "tag", v: nil },
          { d: "net.ntt.hr",
            n: "remote", ni: "0_1", t: "tasker", v: "galactic" }
        ])
      end
    end

    describe 'GET /pointers' do

      it 'lists the pointers' do

        r = @app.call(make_env(path: '/pointers'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].keys
        ).to eq(%w[
          flack:pointers
        ])

        expect(
          j['_embedded'].values.first
            .sort_by { |e|
              e['id'] }
            .collect { |e| {
              d: e['domain'],
              t: e['type'], n: e['name'], v: e['value'], #da: e['data'],
              ni: e['nid'] } }
        ).to eq([
          { d: "net.ntt.finance",
            n: "name", ni: "0", t: "var", v: "1" },
          { d: "net.ntt.finance",
            n: "a", :ni=>"0", t: "var", v: "2" },
          { d: "net.ntt",
            n: "talbot", ni: "0", t: "tag", v: nil },
          { d: "net.ntt.hr",
            n: "turbo", ni: "0_0", t: "tag", v: nil },
          { d: "net.ntt.hr",
            n: "remote", ni: "0_1", t: "tasker", v: "galactic" }
        ])
      end
    end

    describe 'GET /pointers/:exid' do

      it 'lists the pointers' do

        exid = @exids[1]

        r = @app.call(make_env(path: "/pointers/#{exid}"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].values.first
            .sort_by { |e|
              e['id'] }
            .collect { |e| {
              d: e['domain'],
              t: e['type'], n: e['name'], v: e['value'], #da: e['data'],
              ni: e['nid'] } }
        ).to eq([
          { d: "net.ntt.hr",
            n: "turbo", ni: "0_0", t: "tag", v: nil },
          { d: "net.ntt.hr",
            n: "remote", ni: "0_1", t: "tasker", v: "galactic" }
        ])
      end
    end

    describe 'GET /pointers/:domain' do

      it 'lists the pointers (net.ntt*)' do

        r = @app.call(make_env(path: "/pointers/net.ntt*"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].values.first
            .sort_by { |e|
              e['id'] }
            .collect { |e| {
              d: e['domain'],
              t: e['type'], n: e['name'], v: e['value'], #da: e['data'],
              ni: e['nid'] } }
        ).to eq([
          { d: "net.ntt.finance",
            n: "name", ni: "0", t: "var", v: "1" },
          { d: "net.ntt.finance",
            n: "a", :ni=>"0", t: "var", v: "2" },
          { d: "net.ntt",
            n: "talbot", ni: "0", t: "tag", v: nil },
          { d: "net.ntt.hr",
            n: "turbo", ni: "0_0", t: "tag", v: nil },
          { d: "net.ntt.hr",
            n: "remote", ni: "0_1", t: "tasker", v: "galactic" }
        ])
      end

      it 'lists the pointers (net.ntt)' do

        r = @app.call(make_env(path: "/pointers/net.ntt"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].values.first
            .sort_by { |e|
              e['id'] }
            .collect { |e| {
              d: e['domain'],
              t: e['type'], n: e['name'], v: e['value'], #da: e['data'],
              ni: e['nid'] } }
        ).to eq([
          { d: 'net.ntt',
            n: 'talbot', ni: '0', t: 'tag', v: nil },
        ])
      end
    end

    describe 'GET /pointers/:exid?types=var,tasker' do

      it 'lists the pointers' do

        exid = @exids[1]

        r = @app.call(
          make_env(pa: "/pointers/#{exid}", qs: 'types=var,tasker'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].values.first
            .sort_by { |e|
              e['id'] }
            .collect { |e| {
              d: e['domain'],
              t: e['type'], n: e['name'], v: e['value'], #da: e['data'],
              ni: e['nid'] } }
        ).to eq([
          { d: 'net.ntt.hr',
            n: 'remote', ni: '0_1', t: 'tasker', v: 'galactic' }
        ])
      end
    end

    describe 'GET /pointers/:domain?types=var,tasker' do

      it 'lists the pointers (net.ntt*)' do

        r = @app.call(
          make_env(pa: '/pointers/net.ntt*', qs: 'types=var,tasker'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].values.first
            .sort_by { |e|
              e['id'] }
            .collect { |e| {
              d: e['domain'],
              t: e['type'], n: e['name'], v: e['value'], #da: e['data'],
              ni: e['nid'] } }
        ).to eq([
          { d: "net.ntt.finance",
            n: "name", ni: "0", t: "var", v: "1" },
          { d: "net.ntt.finance",
            n: "a", :ni=>"0", t: "var", v: "2" },
          { d: "net.ntt.hr",
            n: "remote", ni: "0_1", t: "tasker", v: "galactic" }
        ])
      end
    end
  end
end

