require 'spec_helper'

require './file/jsonmove.rb'

describe 'JsonMove' do
  context 'normal patterns' do
    it "is named 'OU' at first" do
      jsmv = JsonMove.new
      expect(jsmv.piece).to eq 'OU'
    end
    it 'is located -1,-1 at first' do
      jsmv = JsonMove.new
      expect(jsmv.from).to eq('x' => -1, 'y' => -1)
    end
    it 'is moved -1,-1 at first' do
      jsmv = JsonMove.new
      expect(jsmv.to).to eq('x' => -1, 'y' => -1)
    end
    it 'is black at first' do
      jsmv = JsonMove.new
      expect(jsmv.color).to eq(0)
    end
    it 'is not promoted at first' do
      jsmv = JsonMove.new
      expect(jsmv.promote).to be false
    end
    it 'is promoted' do
      jsmv = JsonMove.new
      jsmv.nari
      expect(jsmv.promote).to be true
    end
    it 'can check if it is same position as opponents move' do
      jsmv = JsonMove.new
      jsmv2 = JsonMove.new
      expect(jsmv.same).to be false
      expect(jsmv2.same).to be false
      jsmv.checkdou(jsmv2.genhash)
      expect(jsmv.same).to be true
      expect(jsmv2.same).to be false
      jsmv2.move({ 'x' => 2, 'y' => 8 }, { 'x' => 8, 'y' => 8 }, 'KA', 0)
      jsmv.checkdou(jsmv2.genhash)
      expect(jsmv.same).to be false
      expect(jsmv2.same).to be false
      jsmv2.move({ 'x' => 2, 'y' => 8 }, { 'x' => -1, 'y' => 8 }, 'KA', 0)
      jsmv.checkdou(jsmv2.genhash)
      expect(jsmv.same).to be false
      expect(jsmv2.same).to be false
      jsmv2.move({ 'x' => 2, 'y' => 8 }, { 'x' => 8, 'y' => -1 }, 'KA', 0)
      jsmv.checkdou(jsmv2.genhash)
      expect(jsmv.same).to be false
      expect(jsmv2.same).to be false
    end
    it 'have not captured at first' do
      jsmv = JsonMove.new
      expect(jsmv.capture).to be_nil
    end
    it "captured 'RY'uou" do
      jsmv = JsonMove.new
      jsmv.toru('RY')
      expect(jsmv.capture).to eq('RY')
    end
    it "can 'UTSU' 'UM'" do
      jsmv = JsonMove.new
      jsmv.nari
      jsmv.toru('RY')
      jsmv.utu({ 'x' => 8, 'y' => 8 }, 'UM', 1)
      expect(jsmv.genhash).to eq(
        'from' => nil,
        'to' => { 'x' => 8, 'y' => 8 },
        'piece' => 'UM',
        'color' => 1,
        # 'promote' => true
        # 'capture' = 'UM'
        # 'same' => false
      )
    end
    it 'can generate hash' do
      jsmv = JsonMove.new
      expect(jsmv.genhash).to eq(
        'from' => { 'x' => -1, 'y' => -1 },
        'to' => { 'x' => -1, 'y' => -1 },
        'piece' => 'OU',
        'color' => 0,
        # 'promote' => true
        # 'capture' = 'UM'
        # 'same' => false
      )
    end
    it 'can generate hash correctly' do
      jsmv = JsonMove.new
      jsmv.nari
      expect(jsmv.genhash).to eq(
        'from' => { 'x' => -1, 'y' => -1 },
        'to' => { 'x' => -1, 'y' => -1 },
        'piece' => 'OU',
        'color' => 0,
        'promote' => true,
        # 'capture' => 'UM'
        # 'same' => false
      )

      jsmv.toru('UM')
      expect(jsmv.genhash).to eq(
        'from' => { 'x' => -1, 'y' => -1 },
        'to' => { 'x' => -1, 'y' => -1 },
        'piece' => 'OU',
        'color' => 0,
        'promote' => true,
        'capture' => 'UM'
        # 'same' => false
      )

      jsmv.move({ 'x' => 2, 'y' => 8 }, { 'x' => 2, 'y' => 2 }, 'HI', 1)
      expect(jsmv.genhash).to eq(
        'from' => { 'x' => 2, 'y' => 8 },
        'to' => { 'x' => 2, 'y' => 2 },
        'piece' => 'HI',
        'color' => 1,
        # 'promote' => true,
        # 'capture' => 'UM'
        # 'same' => false
      )
      jsmv.toru('KE')
      expect(jsmv.genhash).to eq(
        'from' => { 'x' => 2, 'y' => 8 },
        'to' => { 'x' => 2, 'y' => 2 },
        'piece' => 'HI',
        'color' => 1,
        # 'promote' => true,
        'capture' => 'KE'
        # 'same' => false
      )
      jsmv.nari
      expect(jsmv.genhash).to eq(
        'from' => { 'x' => 2, 'y' => 8 },
        'to' => { 'x' => 2, 'y' => 2 },
        'piece' => 'HI',
        'color' => 1,
        'promote' => true,
        'capture' => 'KE'
        # 'same' => false
      )
      jsmv2 = JsonMove.new
      jsmv2.move({ 'x' => 2, 'y' => 8 }, { 'x' => 8, 'y' => 8 }, 'KA', 0)
      jsmv.checkdou(jsmv2.genhash)
      expect(jsmv.genhash).to eq(
        'from' => { 'x' => 2, 'y' => 8 },
        'to' => { 'x' => 2, 'y' => 2 },
        'piece' => 'HI',
        'color' => 1,
        'promote' => true,
        'capture' => 'KE',
        # 'same' => false
      )
      jsmv2.move({ 'x' => 8, 'y' => 8 }, { 'x' => 2, 'y' => 2 }, 'KA', 0)
      jsmv.checkdou(jsmv2.genhash)
      expect(jsmv.genhash).to eq(
        'from' => { 'x' => 2, 'y' => 8 },
        'to' => { 'x' => 2, 'y' => 2 },
        'piece' => 'HI',
        'color' => 1,
        'promote' => true,
        'capture' => 'KE',
        'same' => true
      )
    end
    it "has a constant 'Koma'" do
      expect(JsonMove::Koma).to eq %w[FU KY KE GI KI KA HI OU TO NY NK NG UM RY]
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
