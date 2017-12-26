require 'spec_helper'

require './game/timekeeper.rb'

describe 'TimeKeeper' do
  it 'is initialized' do
    tk = TimeKeeper.new
    expect(tk.dt_lasttick).to be nil
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 0
    expect(tk.extracount).to be 0
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NONE
  end

  it 'can read current status.' do
    now = Time.now
    tk = TimeKeeper.new
    tk.read(5*60, 30, 10, now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 300
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NONE
  end

  it 'can calc thinkingtime.' do
    now = Time.now
    tk = TimeKeeper.new
    tk.read(5*60, 30, 10, now)
    tk.tick_thinktime(-15)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 285
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NONE
    tk.tick_thinktime(-285)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NOTHINKINGTIME

    tk.read(5*60, 30, 10, now)
    tk.tick_thinktime(-315)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NOTHINKINGTIME

    tk.read(0, 30, 10, now)
    tk.tick_thinktime(-3)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NONE

    tk.read(5*60, 30, 10, now)
    tk.tick_thinktime(-330)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NOTHINKINGTIME

    tk.read(0, 30, 10, now)
    tk.tick_thinktime(-33)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NONE
  end

  it 'can calc byouyomi and extratime.' do
    now = Time.now
    tk = TimeKeeper.new
    tk.read(5*60, 30, 10, now)
    el = tk.tick_thinktime(-15)
    tk.tick_byouyomi(el) if el.nonzero?
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 285
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NONE
    el = tk.tick_thinktime(-285)
    tk.tick_byouyomi(el) if el.nonzero?
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NOTHINKINGTIME

    tk.read(5*60, 30, 10, now)
    el = tk.tick_thinktime(-315)
    tk.tick_byouyomi(el) if el.nonzero?
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 15
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NOTHINKINGTIME

    tk.read(0, 30, 10, now)
    el = tk.tick_thinktime(-3)
    tk.tick_byouyomi(el) if el.nonzero?
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 27
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NONE

    tk.read(5*60, 30, 10, now)
    el = tk.tick_thinktime(-330)
    tk.tick_byouyomi(el) if el.nonzero?
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 86_400
    expect(tk.extracount).to be 9
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_USEEXTRA

    tk.read(0, 30, 10, now)
    el = tk.tick_thinktime(-33)
    tk.tick_byouyomi(el) if el.nonzero?
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 86397
    expect(tk.extracount).to be 9
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_USEEXTRA

    tk.read(0, 30, 1, now)
    el = tk.tick_thinktime(-31)
    tk.tick_byouyomi(el) if el.nonzero?
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 86399
    expect(tk.extracount).to be 0
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NOEXTRA

    tk.read(0, 30, 0, now)
    el = tk.tick_thinktime(-31)
    tk.tick_byouyomi(el) if el.nonzero?
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 86399
    expect(tk.extracount).to be -1
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_TMOUT

    tk.read(30, 0, 0, now)
    el = tk.tick_thinktime(-31)
    tk.tick_byouyomi(el) if el.nonzero?
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 86399
    expect(tk.extracount).to be -1
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_TMOUT
  end

  it 'can manage thinking time.' do
    now = Time.now
    tk = TimeKeeper.new
    tk.read(5*60, 30, 10, now-15)
    tk.tick(now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to eq(285)
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NONE
    tk.read(285, 30, 10, now-285)
    tk.tick(now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to be 30
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NOTHINKINGTIME

    tk.read(5*60, 30, 10, now-315)
    tk.tick(now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to eq(15)
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NOTHINKINGTIME

    tk.read(0, 30, 10, now-3)
    tk.tick(now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to eq(27)
    expect(tk.extracount).to be 10
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NONE

    tk.read(5*60, 30, 10, now-330)
    tk.tick(now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to eq(86_400)
    expect(tk.extracount).to be 9
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_USEEXTRA

    tk.read(0, 30, 10, now-33)
    tk.tick(now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to eq(86397)
    expect(tk.extracount).to be 9
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_USEEXTRA

    tk.read(0, 30, 1, now-31)
    tk.tick(now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to eq(86399)
    expect(tk.extracount).to be 0
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_NOEXTRA

    tk.read(0, 30, 0, now-31)
    tk.tick(now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to eq(86399)
    expect(tk.extracount).to eq(-1)
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_TMOUT

    tk.read(30, 0, 0, now-31)
    tk.tick(now)
    expect(tk.dt_lasttick).to eq(now)
    expect(tk.thinktime).to be 0
    expect(tk.byouyomi).to eq(86399)
    expect(tk.extracount).to eq(-1)
    expect(tk.sec_extracount).to be 86_400 # 1day
    expect(tk.houchi).to be TimeKeeper::HOUCHI_TMOUT
  end
end
