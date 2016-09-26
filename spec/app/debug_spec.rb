
#
# specifying flack
#
# Fri Sep 16 09:03:24 JST 2016
#

require 'spec_helper'


describe '/debug' do

  before :each do

    @app = Flack::App.new('envs/test/', start: false)
    #@unit.conf['unit'] = 'u'
    #@unit.hook('journal', Flor::Journal)
    #@unit.storage.migrate
    #@unit.start
  end

  after :each do

    #@unit.stop
    #@unit.storage.clear
    #@unit.shutdown
  end

  describe 'GET /debug' do

    it 'returns env details' do

      r = @app.call(make_env(path: '/debug'))

      expect(r[0]).to eq(200)
      expect(r[1]['Content-Type']).to eq('application/json')
      expect(JSON.parse(r[2].join)['REQUEST_PATH']).to eq('/debug')
    end
  end
end
