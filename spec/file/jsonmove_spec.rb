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

    jsmv.nari
    expect(jsmv.genhash).to eq(
      {
        'from' => { 'x' => -1, 'y' => -1 },
        'to' => { 'x' => -1, 'y' => -1 },
        'piece' => 'OU',
        'color' => 0,
        'promote' => true
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
  end
end
