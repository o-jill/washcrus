require 'spec_helper'

require './file/jkftime.rb'

describe 'JkfTime' do
  context 'normal patterns' do
    it 'is initialized with zero at first' do
      jt = JkfTime.new
      expect(jt.hour).to eq 0
      expect(jt.min).to eq 0
      expect(jt.sec).to eq 0
    end
    it 'can be added second to' do
      jt = JkfTime.new
      jt.addsec(30)
      expect(jt.hour).to eq 0
      expect(jt.min).to eq 0
      expect(jt.sec).to eq 30
      jt.addsec(30)
      expect(jt.hour).to eq 0
      expect(jt.min).to eq 1
      expect(jt.sec).to eq 0
      jt.addsec(30)
      expect(jt.hour).to eq 0
      expect(jt.min).to eq 1
      expect(jt.sec).to eq 30
      jt.addsec(3600 - 90)
      expect(jt.hour).to eq 1
      expect(jt.min).to eq 0
      expect(jt.sec).to eq 0
    end
    it 'can be added' do
      jt = JkfTime.new
      jt.addsec(30)
      jt2 = JkfTime.new
      jt2.addsec(10)
      jt.add(jt2)
      expect(jt.hour).to eq 0
      expect(jt.min).to eq 0
      expect(jt.sec).to eq 40
      jt3 = JkfTime.new
      jt3.addsec(20)
      jt.add(jt3)
      expect(jt.hour).to eq 0
      expect(jt.min).to eq 1
      expect(jt.sec).to eq 0
      jt4 = JkfTime.new
      jt4.addsec(59 * 60)
      jt.add(jt4)
      expect(jt.hour).to eq 1
      expect(jt.min).to eq 0
      expect(jt.sec).to eq 0
    end
    it 'can generate a hash' do
      jt = JkfTime.new
      expect(jt.genhash).to eq('m' => 0, 's' => 0)
      jt.addsec(3738)
      expect(jt.genhash).to eq('h' => 1, 'm' => 2, 's' => 18)
    end
    it 'can be shifted by a hash' do
      jt = JkfTime.new
      jt << { 'h' => 1, 'm' => 1, 's' => 18 }
      expect(jt.genhash).to eq('h' => 1, 'm' => 1, 's' => 18)
      jt << { 'h' => 1, 'm' => 1, 's' => 18 }
      expect(jt.genhash).to eq('h' => 2, 'm' => 2, 's' => 36)
      jt << { 'h' => 1, 'm' => 1, 's' => 18 }
      expect(jt.genhash).to eq('h' => 3, 'm' => 3, 's' => 54)
      jt << { 'h' => 1, 'm' => 1, 's' => 18 }
      expect(jt.genhash).to eq('h' => 4, 'm' => 5, 's' => 12)
      # jt2 = JkfTime.new
      # jt2 << { 'h' => '1', 'm' => '3', 's' => '18' }
      # expect(jt2.genhash).to eq('h' => 1, 'm' => 3, 's' => 18)
    end
  end
end
