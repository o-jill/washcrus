require "spec_helper"

require "./file/jsonmove.rb"

describe "JsonMove" do
  it "is named 'OU' at first" do
    jsmv = JsonMove.new
    expect(jsmv.piece).to eq 'OU'
  end
  it "is located -1,-1 at first" do
    jsmv = JsonMove.new
    expect(jsmv.from).to eq({ 'x' => -1, 'y' => -1 })
  end
  it "is moved -1,-1 at first" do
    jsmv = JsonMove.new
    expect(jsmv.to).to eq({ 'x' => -1, 'y' => -1 })
  end
  it "is black at first" do
    jsmv = JsonMove.new
    expect(jsmv.color).to eq(0)
  end
  it "is not promoted at first" do
    jsmv = JsonMove.new
    expect(jsmv.promote).to be false
  end
  it "is promoted" do
    jsmv = JsonMove.new
    jsmv.nari
    expect(jsmv.promote).to be true
  end
  it "have not captured at first" do
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
    jsmv.utu({ 'x' => 8, 'y' => 8}, 'UM', 1)
    expect(jsmv.genhash).to eq(
      {
        'from' => nil,
        'to' => { 'x' => 8, 'y' => 8 },
        'piece' => 'UM',
        'color' => 1,
        # 'promote' => true
        # 'capture' = 'UM'
      })
  end
  it "can generate hash" do
    jsmv = JsonMove.new
    expect(jsmv.genhash).to eq(
      {
        'from' => { 'x' => -1, 'y' => -1 },
        'to' => { 'x' => -1, 'y' => -1 },
        'piece' => 'OU',
        'color' => 0,
        # 'promote' => true
        # 'capture' = 'UM'
      })
  end
  it "can generate hash correctly" do
    jsmv = JsonMove.new
    jsmv.nari
    expect(jsmv.genhash).to eq(
      {
        'from' => { 'x' => -1, 'y' => -1 },
        'to' => { 'x' => -1, 'y' => -1 },
        'piece' => 'OU',
        'color' => 0,
        'promote' => true,
        # 'capture' => 'UM'
      })

    jsmv.toru('UM')
    expect(jsmv.genhash).to eq(
      {
        'from' => { 'x' => -1, 'y' => -1 },
        'to' => { 'x' => -1, 'y' => -1 },
        'piece' => 'OU',
        'color' => 0,
        'promote' => true,
        'capture' => 'UM'
      })

    jsmv.move({ 'x' => 2, 'y' => 8}, { 'x' => 2, 'y' => 2}, 'HI', 1)
    expect(jsmv.genhash).to eq(
      {
        'from' => { 'x' => 2, 'y' => 8 },
        'to' => { 'x' => 2, 'y' => 2 },
        'piece' => 'HI',
        'color' => 1,
        # 'promote' => true,
        # 'capture' => 'UM'
      })
    jsmv.toru('KE')
    expect(jsmv.genhash).to eq(
      {
        'from' => { 'x' => 2, 'y' => 8 },
        'to' => { 'x' => 2, 'y' => 2 },
        'piece' => 'HI',
        'color' => 1,
        # 'promote' => true,
        'capture' => 'KE'
      })
    jsmv.nari
    expect(jsmv.genhash).to eq(
      {
        'from' => { 'x' => 2, 'y' => 8 },
        'to' => { 'x' => 2, 'y' => 2 },
        'piece' => 'HI',
        'color' => 1,
        'promote' => true,
        'capture' => 'KE'
      })
  end
  it "has a constant 'Koma'" do
    expect(JsonMove::Koma).to eq(%w[FU KY KE GI KI KA HI OU TO NY NK NG UM RY])
  end
  it "checks piece" do
    jsmv = JsonMove.new

    expect(JsonMove::checkpiece('__')).to be nil
    expect(JsonMove::checkpiece('FU')).to eq('FU')
    expect(JsonMove::checkpiece('KY')).to eq('KY')
    expect(JsonMove::checkpiece('KE')).to eq('KE')
    expect(JsonMove::checkpiece('GI')).to eq('GI')
    expect(JsonMove::checkpiece('KI')).to eq('KI')
    expect(JsonMove::checkpiece('KA')).to eq('KA')
    expect(JsonMove::checkpiece('HI')).to eq('HI')
    expect(JsonMove::checkpiece('OU')).to eq('OU')
    expect(JsonMove::checkpiece('TO')).to eq('TO')
    expect(JsonMove::checkpiece('NY')).to eq('NY')
    expect(JsonMove::checkpiece('NK')).to eq('NK')
    expect(JsonMove::checkpiece('NG')).to eq('NG')
    expect(JsonMove::checkpiece('UM')).to eq('UM')
    expect(JsonMove::checkpiece('RY')).to eq('RY')

    expect(JsonMove::checkpiece('_U')).to be nil
    expect(JsonMove::checkpiece('F_')).to be nil
    expect(JsonMove::checkpiece('__FU')).to be nil
    expect(JsonMove::checkpiece('FUa')).to be nil
    expect(JsonMove::checkpiece('KYb')).to be nil
    expect(JsonMove::checkpiece('ke')).to be nil
    expect(JsonMove::checkpiece('G1')).to be nil
    expect(JsonMove::checkpiece('ki')).to be nil
    expect(JsonMove::checkpiece('kA')).to be nil
    expect(JsonMove::checkpiece('H')).to be nil
    expect(JsonMove::checkpiece('')).to be nil
    expect(JsonMove::checkpiece(nil)).to be nil
    expect(JsonMove::checkpiece('_NY_')).to be nil
    expect(JsonMove::checkpiece('aaaaaaaNK')).to be nil
    expect(JsonMove::checkpiece(' NG ')).to be nil
    expect(JsonMove::checkpiece('UMOUKA')).to be nil
    expect(JsonMove::checkpiece('00')).to be nil
  end
  it "parses special text" do
    jsmv = JsonMove.new
    expect(JsonMove::fromtextspecital('%TORYO')).to eq('TORYO')
    expect(JsonMove::fromtextspecital('%TOKYO')).to eq('TOKYO')
    expect(JsonMove::fromtextspecital('TORYO')).to eq('ORYO')
    expect(JsonMove::fromtextspecital('ORYO')).to eq('RYO')
    expect(JsonMove::fromtextspecital('RYO')).to eq('YO')
    expect(JsonMove::fromtextspecital('YO')).to eq('O')
    expect(JsonMove::fromtextspecital('O')).to eq('')
    expect(JsonMove::fromtextspecital('')).to be nil
  end
  it "parses CSA-like text" do
    expect(JsonMove::fromtext('+1234FU__')).to eq(
      {
        'from' => { 'x' => 1, 'y' => 2 },
        'to' => { 'x' => 3, 'y' => 4 },
        'piece' => 'FU',
        'color' => 0,
        # 'promote' => true
        # 'capture' => 'UM'
      })
    expect(JsonMove::fromtext('-5678KAKYP')).to eq(
      {
        'from' => { 'x' => 5, 'y' => 6 },
        'to' => { 'x' => 7, 'y' => 8 },
        'piece' => 'KA',
        'color' => 1,
        'promote' => true,
        'capture' => 'KY'
      })
  end
end
