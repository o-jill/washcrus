require 'spec_helper'

require './file/matchinfofile.rb'

describe 'MatchInfoFile' do
  it "is initialized with 'game-id'" do
    mi = MatchInfoFile.new('0123456')
    expect(mi.gid).to eq('0123456')
    expect(mi.playerb.id).to eq('')
    expect(mi.playerb.name).to eq('')
    expect(mi.playerb.email).to eq('')
    expect(mi.playerw.id).to eq('')
    expect(mi.playerw.name).to eq('')
    expect(mi.playerw.email).to eq('')
    expect(mi.creator).to eq('')
    expect(mi.dt_created).to eq('')
    expect(mi.teban).to eq('b')
    expect(mi.tegoma).to eq('-')
    expect(mi.nth).to eq('1')
    expect(mi.sfen).to eq(
      'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1'
    )
    expect(mi.lastmove).to eq('-9300FU')
    expect(mi.dt_lastmove).to eq('yyyy/mm/dd hh:mm:ss')
  end
  it 'can change player-b' do
    mi = MatchInfoFile.new('0123456')
    expect(mi.playerb.id).to eq('')
    expect(mi.playerb.name).to eq('')
    expect(mi.playerb.email).to eq('')
    expect(mi.playerw.id).to eq('')
    expect(mi.playerw.name).to eq('')
    expect(mi.playerw.email).to eq('')

    mi.setplayerb('idid', {name: 'name', pw: 'pw', email: 'em@i.l'})
    expect(mi.playerb.id).to eq('idid')
    expect(mi.playerb.name).to eq('name')
    expect(mi.playerb.email).to eq('em@i.l')
    expect(mi.playerw.id).to eq('')
    expect(mi.playerw.name).to eq('')
    expect(mi.playerw.email).to eq('')

    expect(mi.setplayerb('idid', nil)).to be nil
  end
  it 'can change player-w' do
    mi = MatchInfoFile.new('0123456')
    expect(mi.playerb.id).to eq('')
    expect(mi.playerb.name).to eq('')
    expect(mi.playerb.email).to eq('')
    expect(mi.playerw.id).to eq('')
    expect(mi.playerw.name).to eq('')
    expect(mi.playerw.email).to eq('')

    mi.setplayerw('idid', {name: 'name', pw: 'pw', email: 'em@i.l'})
    expect(mi.playerb.id).to eq('')
    expect(mi.playerb.name).to eq('')
    expect(mi.playerb.email).to eq('')
    expect(mi.playerw.id).to eq('idid')
    expect(mi.playerw.name).to eq('name')
    expect(mi.playerw.email).to eq('em@i.l')

    expect(mi.setplayerw('idid', nil)).to be nil
  end
  it 'can change creator' do
    mi = MatchInfoFile.new('0123456')
    expect(mi.creator).to eq('')
    expect(mi.dt_created).to eq('')
    mi.setcreator('name', 'yyyy/mm/dd hh:mm:ss')
    expect(mi.creator).to eq('name')
    expect(mi.dt_created).to eq('yyyy/mm/dd hh:mm:ss')
  end
  it 'can change lastmove' do
    mi = MatchInfoFile.new('0123456')
    expect(mi.lastmove).to eq('-9300FU')
    expect(mi.dt_lastmove).to eq('yyyy/mm/dd hh:mm:ss')
    mi.setlastmove('+7776FU__', 'YYYY/MM/DD HH:MM:SS')
    expect(mi.lastmove).to eq('+7776FU__')
    expect(mi.dt_lastmove).to eq('YYYY/MM/DD HH:MM:SS')
  end
  it 'has sfen text' do
    mi = MatchInfoFile.new('0123456')
    expect(mi.teban).to eq('b')
    expect(mi.tegoma).to eq('-')
    expect(mi.nth).to eq('1')
    expect(mi.sfen).to eq(
      'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1'
    )
    sfen = 'lnsgkgsnl/1r5b1/ppppppppp/9/9/3P5/PP1PPPPPP/1B5R1/LNSGKGSNL w - 2'
    mi.fromsfen(sfen)
    expect(mi.teban).to eq('w')
    expect(mi.tegoma).to eq('-')
    expect(mi.nth).to eq('2')
    expect(mi.sfen).to eq(sfen)
    sfen = 'lnsgkgsnl/1r5b1/ppppppppp/5p3/9/3P5/PP1PPPPPP/1B5R1/LNSGKGSNL b - 3'
    mi.fromsfen(sfen)
    expect(mi.teban).to eq('b')
    expect(mi.tegoma).to eq('-')
    expect(mi.nth).to eq('3')
    expect(mi.sfen).to eq(sfen)
    sfen = 'lnsgkgsnl/1r5+B1/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL w B 4'
    mi.fromsfen(sfen)
    expect(mi.teban).to eq('w')
    expect(mi.tegoma).to eq('B')
    expect(mi.nth).to eq('4')
    expect(mi.sfen).to eq(sfen)

    badsf = 'lnsgkgsnl/1r5+B1/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL w B4'
    expect(mi.fromsfen(badsf)).to be nil
    expect(mi.teban).to eq('w')
    expect(mi.tegoma).to eq('B')
    expect(mi.nth).to eq('4')
    expect(mi.sfen).to eq(sfen)

    badsf = 'lnsgkgsnl/1r5+B1/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL wB 4'
    expect(mi.fromsfen(badsf)).to be nil
    expect(mi.teban).to eq('w')
    expect(mi.tegoma).to eq('B')
    expect(mi.nth).to eq('4')
    expect(mi.sfen).to eq(sfen)

    badsf = 'lnsgkgsnl/1r5+B1/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNLw - 2'
    expect(mi.fromsfen(badsf)).to be nil
    expect(mi.teban).to eq('w')
    expect(mi.tegoma).to eq('B')
    expect(mi.nth).to eq('4')
    expect(mi.sfen).to eq(sfen)

    badsf = 'lnsgkgsnl/1r5+B1 ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL b B 5'
    expect(mi.fromsfen(badsf)).to be nil
    expect(mi.teban).to eq('w')
    expect(mi.tegoma).to eq('B')
    expect(mi.nth).to eq('4')
    expect(mi.sfen).to eq(sfen)

    badsf = 'lnsgkgsnl/1r5+B1ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL w B 4'
    expect(mi.fromsfen(badsf)).to be nil
    expect(mi.teban).to eq('w')
    expect(mi.tegoma).to eq('B')
    expect(mi.nth).to eq('4')
    expect(mi.sfen).to eq(sfen)

    badsf = 'nsgkgsnl/1r5+B1/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL b P 30'
    expect(mi.fromsfen(badsf)).to be nil
    expect(mi.teban).to eq('w')
    expect(mi.tegoma).to eq('B')
    expect(mi.nth).to eq('4')
    expect(mi.sfen).to eq(sfen)
  end
  it 'can check sfen' do
    # mi = MatchInfoFile.new('0123456')
    sfen = 'lnsgkgsnl/1r5+B1/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL'
    expect(MatchInfoFileUtil.checksfen(sfen)).to_not be nil
    sfen = 'lnsgkgsnl/1r5+B1/+p+p+p+p+p+p+p+p+p/5p3/9/3P5/' \
           '+P+P1+P+P+P+P+P+P/7R1/LNSGKGSNL'
    expect(MatchInfoFileUtil.checksfen(sfen)).to_not be nil

    sfen = 'nsgkgsnl/1r5+B1/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL'
    expect(MatchInfoFileUtil.checksfen(sfen)).to be nil
    sfen = 'lnsgkgsnl1r5+B1/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL'
    expect(MatchInfoFileUtil.checksfen(sfen)).to be nil
    sfen = 'lnsgkgsnl/1r5+B1/pppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL'
    expect(MatchInfoFileUtil.checksfen(sfen)).to be nil
    sfen = 'lnsgkgsnl/1r5+B/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL'
    expect(MatchInfoFileUtil.checksfen(sfen)).to be nil
    sfen = 'lnsgkgsnl/1r5+B/ppppppppp/5p3/9/3P5/PP1PPPPPP/7R1/LNSGKGSNL/'
    expect(MatchInfoFileUtil.checksfen(sfen)).to be nil
  end
end
