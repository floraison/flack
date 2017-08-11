
#
# specifying flack
#
# Tue Oct  4 05:45:10 JST 2016
#

require 'spec_helper'


describe '/message' do

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

  describe 'POST /message' do

    context 'any msg' do

      it 'goes 400 if the point is missing' do

        msg = {}

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(400)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].join)

        expect(j['error']).to eq('missing msg point')
        expect(j['_links']['self']['method']).to eq('POST')
      end

      it 'goes 400 if the point is unknown' do

        msg = { point: 'flip' }

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(400)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].join)

        expect(j['error']).to eq('bad msg point "flip"')
      end
    end

    context 'a launch msg' do

      it 'goes 400 if the tree is missing' do

        msg = { point: 'launch', domain: 'org.example' }

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(400)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].join)

        expect(j['error']).to eq('missing "tree" or "name" in launch msg')
      end

      it 'launches and goes 201' do

        t = Flor.parse("stall _", "#{__FILE__}:#{__LINE__}")

        msg = { point: 'launch', domain: 'org.example', tree: t }

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(201)
        expect(r[1]['Content-Type']).to eq('application/json')
        expect(r[1]['Location']).to match(/\A\/executions\/org\.example-u-2/)

        j = JSON.parse(r[2].join)

        expect(j['_status']).to eq(201)
        expect(j['_status_text']).to eq('Created')

        expect(
          j['_location']
        ).to match(/\A\/executions\/org\.example-u-2/)

        expect(
          j['_links']['flack:forms/message-created']['href']
        ).to match(/\A\/executions\/org\.example-u-2/)

        expect(j['exid']).to match(/\Aorg\.example-u-2/)

        wait_until { @app.unit.executions.count == 1 }

        exes = @app.unit.executions.all

        expect(exes.collect(&:exid)).to eq([ j['exid'] ])
        expect(exes.collect(&:domain)).to eq(%w[ org.example ])
        expect(exes.collect(&:status)).to eq(%w[ active ])
      end

      it 'launches and defaults to domain "domain0"' do

        t = Flor.parse("stall _", "#{__FILE__}:#{__LINE__}")

        msg = { point: 'launch', tree: t }

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(201)
        expect(r[1]['Content-Type']).to eq('application/json')
        expect(r[1]['Location']).to match(/\A\/executions\/domain0-/)

        j = JSON.parse(r[2].join)

        expect(j['_status']).to eq(201)
        expect(j['_status_text']).to eq('Created')

        expect(
          j['_location']
        ).to match(/\A\/executions\/domain0-u-2/)

        expect(
          j['_links']['flack:forms/message-created']['href']
        ).to match(/\A\/executions\/domain0-u-2/)

        expect(j['exid']).to match(/\Adomain0-u-2/)

        wait_until { @app.unit.executions.count == 1 }

        exes = @app.unit.executions.all

        expect(exes.collect(&:exid)).to eq([ j['exid'] ])
        expect(exes.collect(&:domain)).to eq(%w[ domain0 ])
        expect(exes.collect(&:status)).to eq(%w[ active ])
      end

      it 'launches and vars and payload fields defaults to empty hash' do

        t = Flor.parse("stall _", "#{__FILE__}:#{__LINE__}")

        msg = { point: 'launch', domain: 'org.example', tree: t }

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(201)
        expect(r[1]['Content-Type']).to eq('application/json')
        expect(r[1]['Location']).to match(/\A\/executions\/org\.example-u-2/)

        j = JSON.parse(r[2].join)

        expect(j['_status']).to eq(201)
        expect(j['_status_text']).to eq('Created')

        expect(
          j['_location']
        ).to match(/\A\/executions\/org\.example-u-2/)

        expect(
          j['_links']['flack:forms/message-created']['href']
        ).to match(/\A\/executions\/org\.example-u-2/)

        expect(j['exid']).to match(/\Aorg\.example-u-2/)

        wait_until { @app.unit.executions.count == 1 }

        exe = @app.unit.executions.first

        expect(exe.nodes['0']['vars']).to eq({})
        expect(exe.nodes['0']['payload']).to eq({})
      end

      it 'launches and accept vars and payload fields' do

        t = Flor.parse("stall _", "#{__FILE__}:#{__LINE__}")

        vars = {'var' => 'a_var'}
        fields = {'field' => 'a_field'}
        msg = { point: 'launch', domain: 'org.example', tree: t, vars: vars, fields: fields}

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(201)
        expect(r[1]['Content-Type']).to eq('application/json')
        expect(r[1]['Location']).to match(/\A\/executions\/org\.example-u-2/)

        j = JSON.parse(r[2].join)

        expect(j['_status']).to eq(201)
        expect(j['_status_text']).to eq('Created')

        expect(
          j['_location']
        ).to match(/\A\/executions\/org\.example-u-2/)

        expect(
          j['_links']['flack:forms/message-created']['href']
        ).to match(/\A\/executions\/org\.example-u-2/)

        expect(j['exid']).to match(/\Aorg\.example-u-2/)

        wait_until { @app.unit.executions.count == 1 }

        exe = @app.unit.executions.first

        expect(exe.nodes['0']['vars']).to eq(vars)
        expect(exe.nodes['0']['payload']).to eq(fields)
      end

    end

    context 'a cancel msg' do

      it 'goes 400 if the exid is missing' do

        msg = { point: 'cancel' }

        r = @app
          .call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(400)

        j = JSON.parse(r[2].join)

        expect(j['_status']).to eq(400)
        expect(j['_status_text']).to eq('Bad Request')

        expect(j['error']).to eq('missing exid')
      end

      it 'goes 404 if the execution does not exist' do

        msg = {
          point: 'cancel', exid: 'org.example-u-20161007.2140.gulisufebu' }

        r = @app
          .call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(404)

        j = JSON.parse(r[2].join)

        expect(j['_status']).to eq(404)
        expect(j['_status_text']).to eq('Not Found')

        expect(j['error']).to eq('missing execution')
      end

      it 'goes 404 if the execution node does not exist' do

        r = @app.unit
          .launch('stall _', domain: 'org.example', wait: '0 execute')

        exid = r['exid']

        msg = { point: 'cancel', exid: exid, nid: '0_1' }

        wait_until { @app.unit.executions.count == 1 }

        r = @app
          .call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(404)

        j = JSON.parse(r[2].join)

        expect(j['_status']).to eq(404)
        expect(j['_status_text']).to eq('Not Found')

        expect(j['error']).to eq('missing execution node')
      end

      it 'cancels at node 0 by default and goes 202' do

        r = @app.unit
          .launch('stall _', domain: 'org.example', wait: '0 execute')

        wait_until { @app.unit.executions.count == 1 }

        exid = r['exid']

        msg = { point: 'cancel', exid: exid }

        r = @app
          .call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(202)
        expect(r[1]['Location']).to eq('/executions/' + exid)

        j = JSON.parse(r[2].join)

        expect(j['_status']).to eq(202)
        expect(j['_status_text']).to eq('Accepted')

        wait_until {
          @app.unit.executions
            .all
            .collect(&:status) == [ 'terminated' ] }
      end

      it 'cancels at a given nid and goes 202' do

        r = @app.unit
          .launch(
            %{
              sequence
                stall _
                stall _
            },
            domain: 'org.example',
            wait: '0_0 execute')

        exid = r['exid']

        wait_until { @app.unit.executions.count == 1 }

        msg = { point: 'cancel', exid: exid, nid: '0_0' }

        r = @app
          .call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(202)

        wait_until { @app.unit.executions.first.nodes.keys == %w[ 0 0_1 ] }

        exes = @app.unit.executions.all

        expect(exes.size).to eq(1)
        expect(exes.first.exid).to eq(exid)
        expect(exes.first.status).to eq('active')
      end
    end
  end
end

