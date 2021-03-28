
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

    describe 'GET /executions?status=active' do

      it 'returns an empty list' do

        r = @app.call(make_env(path: '/executions', qs: 'status=active'))

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

      @app.unit.executions
        .where(domain: %w[ net.ntt.hr net.nttc ])
        .update(status: 'terminated')
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
          j['_embedded'].values.first
            .collect { |e| e['exid'] }
            .sort
        ).to eq(
          @exids
        )
        expect(
          j['_embedded'].values.first
            .collect { |e| e['domain'] }
            .sort
        ).to eq(%w[
          net.ntt net.ntt net.ntt.finance net.ntt.hr net.nttc
        ])
      end
    end

    describe 'GET /executions?status=active' do

      it 'lists the executions' do

        r = @app.call(make_env(path: '/executions', qs: 'status=active'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        expect(
          j['_embedded'].keys
        ).to eq(%w[
          flack:executions
        ])

        expect(
          j['_embedded'].values.first
            .collect { |e| e['exid'] }
            .sort
        ).to eq(
          @exids
            .reject { |i| i.match(/\A(net\.ntt\.hr|net.nttc)-/) }
        )
        expect(
          j['_embedded'].values.first
            .collect { |e| e['domain'] }
            .sort
        ).to eq(%w[
          net.ntt net.ntt net.ntt.finance
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
          j['_embedded'].values.first
            .collect { |e| e['domain'] }
            .sort
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
          j['_embedded'].values.first
            .collect { |e| e['domain'] }
            .sort
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
          j['_embedded'].values.first
            .collect { |e| e['domain'] }
            .sort
        ).to eq(%w[
          net.ntt.finance net.ntt.hr
        ])
      end
    end
  end

  describe 'DELETE /executions/:exid' do

    before :each do

      @exids = %w[ net.ntt net.ntt.hr ]
        .collect { |d| @app.unit.launch(%{ sleep '1d' }, domain: d) }
        .sort
      @app.unit.wait('idle')
    end

    it 'goes 200 if the execution exists' do

      exid = @exids.first
#p exid

      r = @app.call(make_env(me: 'DELETE', path: "/executions/#{exid}"))

      expect(r[0]).to eq(200)
      expect(r[1]['Content-Type']).to eq('application/json')

      j = JSON.parse(r[2].first)
#pp j

      expect(j['_links']['self']
        ).to eq(
          'href' => "/executions/#{exid}", 'method' => 'DELETE')

      expect(j['exid']
        ).to eq(exid)
      expect(j['counts']
        ).to eq(
          'messages' => 0, 'executions' => 1, 'pointers' => 0,
          'timers' => 1, 'traps' => 0)

      expect(@app.unit.executions.map(:exid).sort
        ).to eq(@exids - [ exid ])
    end

    it 'goes 404 if the execution does not exist' do

      exid = @exids.first + 'NADA'

      r = @app.call(make_env(me: 'DELETE', path: "/executions/#{exid}"))

      expect(r[0]).to eq(404)
      expect(r[1]['Content-Type']).to eq('application/json')
    end
  end
end

