
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
    @app.unit.storage.migrate
    @app.unit.storage.clear
    @app.unit.start
  end

  after :each do

    @app.unit.stop
    @app.unit.storage.clear
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

      it 'goes 400 if the domain is missing' do

        msg = { point: 'launch' }

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(400)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].join)

        expect(j['error']).to eq('missing domain')
      end

      it 'goes 400 if the tree is missing' do

        msg = { point: 'launch', domain: 'org.example' }

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(400)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].join)

        expect(j['error']).to eq('missing "tree" or "name" in launch msg')
      end

      it 'launches'
    end

    context 'a cancel msg' do
      it 'cancels'
    end
  end
end

