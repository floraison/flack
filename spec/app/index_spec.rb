
#
# specifying flack
#
# Mon Sep 19 11:35:06 JST 2016
#

require 'spec_helper'


describe '/' do

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

  describe 'GET /' do

    it 'returns links to the various endpoints' do

      r = @app.call(make_env(path: '/'))

      expect(r[0]).to eq(200)
      expect(r[1]['Content-Type']).to eq('application/json')

      j = JSON.parse(r[2].first)

      expect(
        j['_links']
      ).to eqj(
        {"self"=>{"href"=>"/"},
         "curies"=>
          [{"name"=>"flack",
            "href"=>
             "https://github.com/floraison/flack/blob/master/doc/rels.md\#{rel}",
            "templated"=>true}],
         "flack:executions"=>
          {"href"=>"/executions{?status,exid,dexid}", "templated"=>true},
         "flack:executions/domain"=>
          {"href"=>"/executions/{domain}{?status}", "templated"=>true},
         "flack:executions/domain-star"=>
          {"href"=>"/executions/{domain}*{?status}", "templated"=>true},
         "flack:executions/domain-dot-star"=>
          {"href"=>"/executions/{domain}.*{?status}", "templated"=>true},
         "flack:executions/exid"=>
          {"href"=>"/executions/{exid}", "templated"=>true},
         "flack:executions/id"=>{"href"=>"/executions/{id}", "templated"=>true},
         "flack:messages"=>{"href"=>"/messages"},
         "flack:messages/point"=>
          {"href"=>"/messages/{point}", "templated"=>true},
         "flack:messages/exid/point"=>
          {"href"=>"/messages/{exid}/{point}", "templated"=>true},
         "flack:messages/exid"=>{"href"=>"/messages/{exid}", "templated"=>true},
         "flack:messages/id"=>{"href"=>"/messages/{id}", "templated"=>true},
         "flack:pointers"=>
          {"href"=>"/pointers{?types,exid,dexid}", "templated"=>true},
         "flack:pointers/exid"=>
          {"href"=>"/pointers/{exid}{?types}", "templated"=>true},
         "flack:pointers/domain"=>
          {"href"=>"/pointers/{domain}{?types}", "templated"=>true},
         "flack:pointers/domain-star"=>
          {"href"=>"/pointers/{domain}*{?types}", "templated"=>true},
         "flack:pointers/domain-dot-star"=>
          {"href"=>"/pointers/{domain}.*{?types}", "templated"=>true}}
      )

      expect(
        j['_links'].select { |k, v| k == 'curies' }
      ).to eqj({
        'curies' => [
          { name: 'flack',
            href: 'https://github.com/floraison/flack/blob/master/doc/rels.md#{rel}',
            templated: true }
        ]
      })

      f = j['_forms']['flack:forms/message']

      expect(
        f
      ).to eqj({
        'action' => '/message',
        'method' => 'POST',
        '_inputs' => { 'flack:forms/message-content' => { type: 'json' } }
      })
    end

    context 'when SCRIPT_NAME' do

      it 'returns links to the various endpoints' do

        r = @app.call(make_env(path: '/', script_name: '/flack'))

        expect(r[0]).to eq(200)
        expect(r[1]['Content-Type']).to eq('application/json')

        j = JSON.parse(r[2].first)

        curies_href =
          'https://github.com/floraison/flack/blob/master/doc/rels.md#{rel}'

        expect(
          j['_links']
        ).to eqj(
          {"self"=>{"href"=>"/flack/"},
           "curies"=>
            [{"name"=>"flack",
              "href"=>
               "https://github.com/floraison/flack/blob/master/doc/rels.md\#{rel}",
              "templated"=>true}],
           "flack:executions"=>
            {"href"=>"/flack/executions{?status,exid,dexid}", "templated"=>true},
           "flack:executions/domain"=>
            {"href"=>"/flack/executions/{domain}{?status}", "templated"=>true},
           "flack:executions/domain-star"=>
            {"href"=>"/flack/executions/{domain}*{?status}", "templated"=>true},
           "flack:executions/domain-dot-star"=>
            {"href"=>"/flack/executions/{domain}.*{?status}", "templated"=>true},
           "flack:executions/exid"=>
            {"href"=>"/flack/executions/{exid}", "templated"=>true},
           "flack:executions/id"=>
            {"href"=>"/flack/executions/{id}", "templated"=>true},
           "flack:messages"=>{"href"=>"/flack/messages"},
           "flack:messages/point"=>
            {"href"=>"/flack/messages/{point}", "templated"=>true},
           "flack:messages/exid/point"=>
            {"href"=>"/flack/messages/{exid}/{point}", "templated"=>true},
           "flack:messages/exid"=>
            {"href"=>"/flack/messages/{exid}", "templated"=>true},
           "flack:messages/id"=>
            {"href"=>"/flack/messages/{id}", "templated"=>true},
           "flack:pointers"=>
            {"href"=>"/flack/pointers{?types,exid,dexid}", "templated"=>true},
           "flack:pointers/exid"=>
            {"href"=>"/flack/pointers/{exid}{?types}", "templated"=>true},
           "flack:pointers/domain"=>
            {"href"=>"/flack/pointers/{domain}{?types}", "templated"=>true},
           "flack:pointers/domain-star"=>
            {"href"=>"/flack/pointers/{domain}*{?types}", "templated"=>true},
           "flack:pointers/domain-dot-star"=>
            {"href"=>"/flack/pointers/{domain}.*{?types}", "templated"=>true}}
        )
        expect(
          j['_forms']
        ).to eqj({
          'curies' => [ { name: 'flack', href: curies_href, templated: true } ],
          'flack:forms/message' => {
            action: '/flack/message',
            method: 'POST',
            _inputs: {
              'flack:forms/message-content' => { type: 'json' } } },
          'flack:forms/execution-deletion' => {
            action: '/flack/executions/{exid}',
            method: 'DELETE',
            _inputs: {},
            templated: true }
        })
      end
    end
  end
end

