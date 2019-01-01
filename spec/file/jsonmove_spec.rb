require 'spec_helper'

require './file/jsonmove.rb'

describe 'JsonMove' do
  context 'normal patterns' do
    it "has a constant 'Koma'" do
      expect(JsonMove.koma).to eq %w[FU KY KE GI KI KA HI OU TO NY NK NG UM RY]
    end
    it 'checks piece' do
      expect(JsonMove.checkpiece('__')).to be nil
      expect(JsonMove.checkpiece('FU')).to eq('FU')
      expect(JsonMove.checkpiece('KY')).to eq('KY')
      expect(JsonMove.checkpiece('KE')).to eq('KE')
      expect(JsonMove.checkpiece('GI')).to eq('GI')
      expect(JsonMove.checkpiece('KI')).to eq('KI')
      expect(JsonMove.checkpiece('KA')).to eq('KA')
      expect(JsonMove.checkpiece('HI')).to eq('HI')
      expect(JsonMove.checkpiece('OU')).to eq('OU')
      expect(JsonMove.checkpiece('TO')).to eq('TO')
      expect(JsonMove.checkpiece('NY')).to eq('NY')
      expect(JsonMove.checkpiece('NK')).to eq('NK')
      expect(JsonMove.checkpiece('NG')).to eq('NG')
      expect(JsonMove.checkpiece('UM')).to eq('UM')
      expect(JsonMove.checkpiece('RY')).to eq('RY')
    end
    it 'parses special text' do
      expect(JsonMove.fromtextspecial('%TORYO')).to eq(special: 'TORYO')
      expect(JsonMove.fromtextspecial('%TOKYO')).to eq(special: 'TOKYO')
    end
    it 'parses CSA-like text' do
      expect(JsonMove.fromtext('+1234FU__')).to eq(
        'from' => { 'x' => 1, 'y' => 2 },
        'to' => { 'x' => 3, 'y' => 4 },
        'piece' => 'FU',
        'color' => 0,
        # 'promote' => true
        # 'capture' => 'UM'
      )
      expect(JsonMove.fromtext('+2434HIFU')).to eq(
        'from' => { 'x' => 2, 'y' => 4 },
        'to' => { 'x' => 3, 'y' => 4 },
        'piece' => 'HI',
        'color' => 0,
        # 'promote' => true
        'capture' => 'FU'
      )
      expect(JsonMove.fromtext('-5678KAKYP')).to eq(
        'from' => { 'x' => 5, 'y' => 6 },
        'to' => { 'x' => 7, 'y' => 8 },
        'piece' => 'KA',
        'color' => 1,
        'promote' => true,
        'capture' => 'KY'
      )
      expect(JsonMove.fromtext('+0055KA__')).to eq(
        'from' => nil,
        'to' => { 'x' => 5, 'y' => 5 },
        'piece' => 'KA',
        'color' => 0
      )
      expect(JsonMove.fromtext('-0025FU__')).to eq(
        'from' => nil,
        'to' => { 'x' => 2, 'y' => 5 },
        'piece' => 'FU',
        'color' => 1
      )
      expect(JsonMove.fromtext('+5453FU__P')).to eq(
        'from' => { 'x' => 5, 'y' => 4 },
        'to' => { 'x' => 5, 'y' => 3 },
        'piece' => 'FU',
        'color' => 0,
        'promote' => true
      )
      expect(JsonMove.fromtext('%TORYO')).to eq(special: 'TORYO')
      expect(JsonMove.fromtext('%TOKYO')).to eq(special: 'TOKYO')
    end
  end

  context 'abnormal patterns' do
    it 'checks piece' do
      expect(JsonMove.checkpiece('_U')).to be nil
      expect(JsonMove.checkpiece('F_')).to be nil
      expect(JsonMove.checkpiece('__FU')).to be nil
      expect(JsonMove.checkpiece('FUa')).to be nil
      expect(JsonMove.checkpiece('KYb')).to be nil
      expect(JsonMove.checkpiece('ke')).to be nil
      expect(JsonMove.checkpiece('G1')).to be nil
      expect(JsonMove.checkpiece('ki')).to be nil
      expect(JsonMove.checkpiece('kA')).to be nil
      expect(JsonMove.checkpiece('H')).to be nil
      expect(JsonMove.checkpiece('')).to be nil
      expect(JsonMove.checkpiece(nil)).to be nil
      expect(JsonMove.checkpiece('_NY_')).to be nil
      expect(JsonMove.checkpiece('aaaaaaaNK')).to be nil
      expect(JsonMove.checkpiece(' NG ')).to be nil
      expect(JsonMove.checkpiece('UMOUKA')).to be nil
      expect(JsonMove.checkpiece('00')).to be nil
    end
    it 'parses special text' do
      expect(JsonMove.fromtextspecial('TORYO')).to eq(special: 'ORYO')
      expect(JsonMove.fromtextspecial('ORYO')).to eq(special: 'RYO')
      expect(JsonMove.fromtextspecial('RYO')).to eq(special: 'YO')
      expect(JsonMove.fromtextspecial('YO')).to eq(special: 'O')
      expect(JsonMove.fromtextspecial('O')).to eq(special: '')
      expect(JsonMove.fromtextspecial('')).to eq(special: nil)
    end
    it 'parses CSA-like text' do
      expect(JsonMove.fromtext('+5453__FUP')).to be nil
      expect(JsonMove.fromtext('*5453FU__')).to be nil
      expect(JsonMove.fromtext('/5453FU__P')).to be nil
      expect(JsonMove.fromtext('-5400FU__')).to be nil
      expect(JsonMove.fromtext('+5453KM__P')).to be nil
      expect(JsonMove.fromtext('-5467fu__')).to be nil
      expect(JsonMove.fromtext('-5467FU__p')).to be nil
      expect(JsonMove.fromtext('+AB53FUKIP')).to be nil
      expect(JsonMove.fromtext('+54CDKYKE')).to be nil
      expect(JsonMove.fromtext('TORYO')).to be nil
    end
  end
end
