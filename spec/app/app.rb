
#
# specifying flack
#
# Wed Jan 11 09:02:03 JST 2017
#

require 'spec_helper'


describe Flack::App do

  describe '.new' do

    it 'sets Flack::App.unit' do

      app = Flack::App.new('envs/test/etc/conf.json', start: false)

      expect(Flack::App.unit.object_id).to eq(app.unit.object_id)
      expect(Flack::App.unit.class).to eq(Flor::Scheduler)
    end
  end

  describe '.unit' do

    it 'returns the latest flor unit' do

      u0 = Flack::App.new('envs/test/etc/conf.json', start: false).unit
      u1 = Flack::App.new('envs/test/etc/conf.json', start: false).unit

      expect(u0.object_id).not_to eq(u1.object_id)
      expect(Flack::App.unit.object_id).to eq(u1.object_id)
    end
  end

  describe '.on_unit_created' do

    it 'is called when the flor unit is created' do

      def Flack.on_unit_created(unit)
        $RS = [ unit.class, unit.object_id ]
      end

      app = Flack::App.new('envs/test/etc/conf.json', start: false)

      expect($RS).to eq([ Flor::Scheduler, Flack::App.unit.object_id ])
    end
  end
end

