
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

      it 'returns an empty list' do

        r = @app.call(make_env(path: '/executions'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['_embedded']).to eq({ 'flack:executions' => [] })
      end
    end

    describe 'GET /executions/:exid' do

      it 'goes 404 when the execution does not exist' do

        r = @app.call(make_env(path: '/executions/not.existing.exid-123-123'))

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

    describe 'GET /executions/:domain' do

      it 'returns an empty list' do

        r = @app.call(make_env(path: '/executions/net.ntt'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['_embedded']).to eq({ 'flack:executions/domain' => [] })
      end
    end

    describe 'GET /executions/:domain*' do

      it 'returns an empty list' do

        r = @app.call(make_env(path: '/executions/net.*'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded']
        ).to eq({
          'flack:executions/domain-dot-star' => []
        })
      end
    end
  end

  context 'with ongoing executions' do

    before :each do

      @exids = %w[ net.ntt net.ntt net.ntt.finance net.ntt.hr net.nttc ]
        .collect { |d| @app.unit.launch(%{ stall _ }, domain: d) }
        .sort
      @app.unit.wait('idle')
    end

    describe 'GET /executions' do

      it 'lists the executions' do

        r = @app.call(make_env(path: '/executions'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].keys
        ).to eq(%w[
          flack:executions
        ])

        expect(
          j['_embedded'].values.first.collect { |e| e['exid'] }
        ).to eq(
          @exids
        )
        expect(
          j['_embedded'].values.first.collect { |e| e['domain'] }
        ).to eq(%w[
          net.ntt net.ntt net.ntt.finance net.ntt.hr net.nttc
        ])
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

        exid = @exids.first

        pr = @app.call(make_env(path: "/executions/#{exid}"))
        pj = JSON.parse(pr[2].first)
        pi = pj['id']

        r = @app.call(make_env(path: "/executions/#{pi}"))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)
        expect(j['exid']).to eq(exid)
      end
    end

    describe 'GET /executions/:domain' do

      it 'lists all the execution in the given domain' do

        r = @app.call(make_env(path: '/executions/net.ntt'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].keys
        ).to eq(%w[
          flack:executions/domain
        ])

        expect(
          j['_embedded'].values.first.collect { |e| e['domain'] }
        ).to eq(%w[
          net.ntt net.ntt
        ])
      end
    end

    describe 'GET /executions/:domain*' do

      it 'lists alls the executions in the domain and its subdomains' do

        r = @app.call(make_env(path: '/executions/net.ntt*'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].keys
        ).to eq(%w[
          flack:executions/domain-star
        ])

        expect(
          j['_embedded'].values.first.collect { |e| e['domain'] }
        ).to eq(%w[
          net.ntt net.ntt net.ntt.finance net.ntt.hr
        ])
      end
    end

    describe 'GET /executions/:domain.*' do

      it 'lists the executions in the sub-domains' do

        r = @app.call(make_env(path: '/executions/net.ntt.*'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].keys
        ).to eq(%w[
          flack:executions/domain-dot-star
        ])

        expect(
          j['_embedded'].values.first.collect { |e| e['domain'] }
        ).to eq(%w[
          net.ntt.finance net.ntt.hr
        ])
      end
    end
  end
end

