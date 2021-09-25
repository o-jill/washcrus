# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'bundler/setup'

require 'unindent'

require './game/sfensvgimage.rb'

CONFIGS = [
  {
    sfen: 'lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1',
    sente: '□先手太郎□', gote: '□後手花子□', title: '□たいとるだよ□', last: '-',
    turn: 'b', svg: 'test00.svg'
  },
  {
    sfen: 'lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL' \
      ' w 2P2p 2',
    sente: '□先手太郎□', gote: '□後手花子□', title: '□たいとるだよ□', last: '76',
    turn: 'd', svg: 'test01.svg'
  },
  {
    sfen: 'Rr+R+rR+r+RrR/+B+bBbBbB+b+B/gGgGgGgGg/+sSs+Ss+SsS+s/' \
      'n+n+NNnnN+N+n/lLL+l+L+l+lLl/+p+P+p+P+p+P+p+P+p/PpPpPpPpP/kKkKkKkKk' \
      ' w 2R2B4G4S4N4L18P2r2b4g4s4n4l18p 105',
    sente: '□先手太郎□', gote: '□後手花子□', title: '□たいとるだよ□', last: '99',
    turn: 'fb', svg: 'test02.svg'
  },
  {
    sfen: '1n4gn1/4r2sk/5Snll/2p2ppBp/1p2pP3/2P3PS1/1P1+p3GL/2S2+b1KL/8R' \
      ' b GNPg6p 105',
    sente: '□先手太郎□', gote: '□後手花子□', title: '□たいとるだよ□', last: '55',
    turn: 'fw', svg: 'test03.svg'
  },
  {
    sfen: 'l6nl/1r4gk1/4bs1p1/2pp+Spp1s/pp1n5/2PS2PP1/PP1G1P3/1KGB3R1/LN6L' \
      ' w GPn4p 64',
    sente: '□先手太郎□', gote: '□後手花子□', title: '□たいとるだよ□', last: '15',
    turn: 'w', svg: 'test04.svg'
  }
].freeze

idxarr = ARGV.grep(/-N\d+/)
idx = idxarr.size.zero? ? 0 : idxarr[0].slice(2, 10).to_i
stg = CONFIGS[idx] || CONFIGS[0]

ssi = SfenSVGImage.new(stg[:sfen])
ssi.setnames(stg[:sente], stg[:gote])
ssi.settitle(stg[:title])
ssi.setmoveinfo(stg[:last], stg[:turn])
# ssi.setui(@piecetype)

puts ssi.gen
