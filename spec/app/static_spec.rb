
#
# specifying flack
#
# Fri Sep 30 06:36:50 SGT 2016
#

require 'spec_helper'


describe '/static' do

  before :each do

    @app = Flack::App.new('envs/test/', start: false)
  end

  describe 'GET /static/site.css' do

    it 'serves file' do

      r = @app.call(make_env(path: '/static/site.css'))

      expect(r[0]).to eq(200)
      expect(r[1]['Content-Type']).to eq('text/css')
      expect(r[1]['Last-Modified']).not_to eq(nil)
      expect(r[2].class).to eq(Rack::File)
    end

    it 'stays in static/' do

      r = @app.call(make_env(path: '/static/../app.rb'))

      expect(r[0]).to eq(404)
    end
  end
end

