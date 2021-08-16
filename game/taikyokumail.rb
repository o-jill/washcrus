# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'erb'
require 'logger'

require './file/matchinfofile.rb'
require './file/chatfile.rb'
require './game/sfenkyokumentxt.rb'
require './game/userinfo.rb'
require './util/mailmgr.rb'
require './util/settings.rb'

#
# 対局メール生成
#
class TaikyokuMail
  # 初期化
  #
  # @param gid     [String] 対局ID
  # @param userid  [UserInfo] ユーザー情報オブジェクト
  # @param now     [Time] 着手日時オブジェクト
  def initialize(gid, useri, now, mov)
    load_settings
    @gameid = gid
    @userinfo = useri
    @nowstr = now.strftime('%Y/%m/%d %H:%M:%S')
    @move = mov
  end

  # MatchInfoFile情報の設定
  #
  # @param mainfoi [MatchInfoFile] オブジェクト
  def setmif(mainfi)
    @mif = mainfi
    @plysnm = mif.playerb.name
    @plygnm = mif.playerw.name
  end

  # @!attribute [r] plysnm
  #   @return 先手の対局者名。erbで使用。
  # @!attribute [r] plygnm
  #   @return 後手の対局者名。erbで使用。
  # @!attribute [r] gameid
  #   @return 対局ID。erbで使用。
  # @!attribute [r] mif
  #   @return　MatchInfoFileオブジェクト
  # @!attribute [r] userinfo
  #   @return ユーザー情報 erbで使用。
  # @!attribute [r] nowstr
  #   @return 現在の時刻文字列 'yyyy/mm/dd hh:mm:ss' erbで使用。
  attr_reader :baseurl, :gameid, :mif, :plysnm, :plygnm, :userinfo,
              :usehtml, :nowstr, :move

  # 設定値の読み込み
  def load_settings
    stg = Settings.instance
    @baseurl = stg.value['base_url']
    @usehtml = stg.value['mailformat'] == 'html'
  end

  # 対局終了メールのタイトルの生成
  def build_finishedtitle
    "the game was over. (#{mif.to_vs})"
  end

  # 対局終了メールの本文の生成
  #
  # @param filename 添付ファイル名。erbで使用。
  def build_finishedmsg(filename)
    msg = ERB.new(
      File.read('./mail/finishedmsg.erb', encoding: 'utf-8')
    ).result(binding)

    msg += build_kyokumenzu

    chat = ChatFile.new(gameid).read
    msg + msginchat(chat.stripped_msg)
  end

  # メール用チャット文の生成
  #
  # @param msg チャット内容
  # @param tag 行の先頭に付加するhtmlタグ
  # @param taglast 終端htmlタグ
  #
  # @return メール用チャット文
  def msginchat(msg, tag = '', taglast = '')
    "#{tag}---- messages in chat ----\n#{tag}#{msg}" \
    "#{tag}---- messages in chat ----\n#{taglast}\n"
  end

  # 対局終了メールの本文の生成
  #
  # @param filename 添付ファイル名。erbで使用。
  #
  # @return 対局終了メールの本文
  def build_finishedhtmlmsg(filename)
    # erbで使用。
    url = "#{baseurl}index.rb?game/#{gameid}"

    msg = ERB.new(
      File.read('./mail/finishedhtml.erb', encoding: 'utf-8')
    ).result(binding)

    chat = ChatFile.new(gameid).read
    msg + msginchat(chat.msg, '<p>')
  end

  # 添付ファイル名の生成
  #
  # @return 添付ファイル名
  def build_attachfilename
    # 数字だけの時刻の文字列の生成
    dt = mif.dt_lastmove.delete('/:').sub(' ', '_')

    fname = "#{plysnm}_#{plygnm}_#{dt}.kif"

    fname.gsub(%r{[\\/*:<>?|]},
               '\\' => '￥', '/' => '／', '*' => '＊', ':' => '：',
               '<' => '＜', '>' => '＞', '?' => '？', '|' => '｜')
  end

  # 署名をつけてHTMLメールを送信
  #
  # @param subject 題名
  # @param msg 本文テキスト
  # @param html 本文テキスト
  # @param kifufile 棋譜ファイル
  def send_htmlmailex_withfooter(subject, msg, html, kifufile)
    bemail = mif.playerb.email
    wemail = mif.playerw.email

    mmgr = MailManager.new
    mmgr.send_htmlmailex_withfooter(bemail, subject, msg, html, kifufile)
    mmgr.send_htmlmailex_withfooter(wemail, subject, msg, html, kifufile)
  end

  # 署名をつけてテキストメールを送信
  #
  # @param subject 題名
  # @param msg 本文テキスト
  # @param kifufile 棋譜ファイル
  def send_mailex_withfooter(subject, msg, kifufile)
    bemail = mif.playerb.email
    wemail = mif.playerw.email

    mmgr = MailManager.new
    mmgr.send_mailex_withfooter(bemail, subject, msg, kifufile)
    mmgr.send_mailex_withfooter(wemail, subject, msg, kifufile)
  end

  # 終局メールの生成と送信
  def send_mail_finished(kifu)
    subject = build_finishedtitle

    # dt = build_short_dt
    filename = build_attachfilename

    # filename: tkd.escape_fnu8(filename),
    kifufile = { filename: filename, content: kifu }

    # mif = tkd.mif

    msg = build_finishedmsg(filename)

    return send_mailex_withfooter(subject, msg, kifufile) unless usehtml

    html = build_finishedhtmlmsg(filename)
    send_htmlmailex_withfooter(subject, msg, html, kifufile)
  end

  # 局面図の生成
  def build_kyokumenzu
    skt = SfenKyokumenTxt.new(mif.sfen)
    skt.settitle('タイトル')
    skt.setmoveinfo(move)
    skt.setnames(plysnm, plygnm)
    skt.gen + "\n"
  end

  # 局面図のURLの生成
  def bulid_svgurl
    "#{baseurl}sfenimage.rb?" \
    "sfen=#{mif.sfen.gsub('+', '%2B')}&lm=#{move[3, 2]}&" \
    "sname=#{plysnm}&gname=#{plygnm}"
  end

  # 指されましたメールの本文の生成
  #
  # @param name 手番の人の名前
  def build_nextturnmsg(name)
    msg = ERB.new(
      File.read('./mail/nextturn.erb', encoding: 'utf-8')
    ).result(binding)

    msg += build_kyokumenzu

    chat = ChatFile.new(gameid).read
    msg + msginchat(chat.stripped_msg)
  end

  # 指されましたメールの本文の生成
  #
  # @param name 手番の人の名前
  def build_nextturnhtmlmsg(name)
    # erbで使用。
    url = "#{baseurl}index.rb?game/#{gameid}"

    msg = ERB.new(
      File.read('./mail/nextturnhtml.erb', encoding: 'utf-8')
    ).result(binding)

    chat = ChatFile.new(gameid).read
    msg + "<pre>\n" + msginchat(chat.stripped_msg, '', '</pre>')
  end

  # 対戦相手の情報を取得
  #
  # @return [名前, メールアドレス]
  def getopponentinfo
    opp = mif.getopponent(userinfo.user_id)
    [opp[:name], opp[:mail]]
    # opnm = opp[:name]
    # opem = opp[:mail]
    # @log.debug("opp:#{opp}")
  end

  # 指されましたメールの生成と送信
  def send_mail_next
    subject = "it's your turn!! (#{mif.to_vs})"

    (opnm, opem) = getopponentinfo

    msg = build_nextturnmsg(opnm)

    mmgr = MailManager.new
    return mmgr.send_mail_withfooter(opem, subject, msg) unless usehtml

    mmgr.send_htmlmail_withfooter(
      opem, subject, msg,
      build_nextturnhtmlmsg(opnm)
    )
  end

  # usage
  #
  # @param finished [boolean] 終局したかどうか
  # @param now      [Time]    着手日時オブジェクト
  # def send_mail(finished, now)
  #   tkd.read # これいるの？
  #   kifu = tkd.jkf.to_kif
  #   tmail = TaikyokuMail.new(gid, userinfo, now, move)
  #   tmail.setmif(tkd.mif)
  #   finished ? tmail.send_mail_finished(kifu) : tmail.send_mail_next
  # end
end

# tmail = TaikyokuMail.new('', '', '', '')
