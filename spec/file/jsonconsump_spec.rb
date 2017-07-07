require 'spec_helper'

require './file/jsonconsump.rb'

describe 'JsonConsumption' do
  context 'normal patterns' do
    it 'is initialize zero at first' do
      jc = JsonConsumption.new
      expect(jc.genhash).to eq(
        'now' => { 'm' => 0, 's' => 0 },
        'total' => { 'm' => 0, 's' => 0 }
      )
    end
    it 'can offset total time' do
      jc = JsonConsumption.new
      jc.settotal('m' => 0, 's' => 1)
      expect(jc.genhash).to eq(
        'now' => { 'm' => 0, 's' => 0 },
        'total' => { 'm' => 0, 's' => 1 }
      )
      jc.settotal('m' => 2, 's' => 0)
      expect(jc.genhash).to eq(
        'now' => { 'm' => 0, 's' => 0 },
        'total' => { 'm' => 2, 's' => 1 }
      )
      jc.settotal('h' => 3, 'm' => 0, 's' => 0)
      expect(jc.genhash).to eq(
        'now' => { 'm' => 0, 's' => 0 },
        'total' => { 'h' => 3, 'm' => 2, 's' => 1 }
      )
    end
    it 'can calculate consumption time' do
      jc = JsonConsumption.new
      told = Time.parse('2000/01/01 12:34:56')
      tnew = Time.parse('2000/01/01 12:45:00')
      jc.diff(tnew, told)
      expect(jc.genhash).to eq(
        'now' => { 'm' => 10, 's' => 4 },
        'total' => { 'm' => 10, 's' => 4 }
      )
      told = Time.parse('2000/01/01 12:34:56')
      tnew = Time.parse('2000/01/01 12:45:06')
      jc.diff(tnew, told)
      expect(jc.genhash).to eq(
        'now' => { 'm' => 10, 's' => 10 },
        'total' => { 'm' => 20, 's' => 14 }
      )
      told = Time.parse('2000/01/01 12:34:56')
      tnew = Time.parse('2000/01/01 13:15:56')
      jc.diff(tnew, told)
      expect(jc.genhash).to eq(
        'now' => { 'm' => 41, 's' => 0 },
        'total' => { 'h' => 1, 'm' => 1, 's' => 14 }
      )
    end
    it 'can calculate consumption time' do
      jc = JsonConsumption.new
      told = '2000/01/01 12:34:56'
      tnew = '2000/01/01 12:45:00'
      jc.diff_t(tnew, told)
      expect(jc.genhash).to eq(
        'now' => { 'm' => 10, 's' => 4 },
        'total' => { 'm' => 10, 's' => 4 }
      )
      told = '2000/01/01 12:34:56'
      tnew = '2000/01/01 12:45:06'
      jc.diff_t(tnew, told)
      expect(jc.genhash).to eq(
        'now' => { 'm' => 10, 's' => 10 },
        'total' => { 'm' => 20, 's' => 14 }
      )
      told = '2000/01/01 12:34:56'
      tnew = '2000/01/01 13:15:56'
      jc.diff_t(tnew, told)
      expect(jc.genhash).to eq(
        'now' => { 'm' => 41, 's' => 0 },
        'total' => { 'h' => 1, 'm' => 1, 's' => 14 }
      )
    end
  end
end
