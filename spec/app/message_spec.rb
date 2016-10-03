
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

    context 'a launch msg' do

      it 'launches' do

        msg = { domain: 'org.nada' }

        r = @app.call(make_env(method: 'POST', path: '/message', body: msg))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')
# TODO
      end
    end

    context 'a cancel msg' do
      it 'cancels'
    end
  end
end

