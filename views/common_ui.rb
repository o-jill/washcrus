# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
# require 'unindent'

require './util/settings.rb'

#
# UI parts used in common
#
module CommonUI
  # HTMLヘッダ出力
  #
  # @param header HTMLヘッダ
  def self.html_head(header)
    print header
    stg = Settings.instance
    title = stg.value['wintitle']
    print <<-HEADER_TAG.unindent
      <HTML lang=ja>
      <HEAD>
       <title>#{title}</title>
       <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >
       <META name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
       <meta name='theme-color' content='#cc9933'>
       <link rel='shortcut icon' href='./image/favicon.ico' />
       <link rel='stylesheet' type='text/css' href='./css/washcrus.v019.css'>
      </HEAD>
      <BODY>
    HEADER_TAG
  end

  # HTMLヘッダ出力(no cookie)
  def self.html_head2
    print <<-HEADER.unindent
      Content-Type: text/html; charset=UTF-8
      Set-Cookie: _washcrus_session=; expires=Thu, 01 Jan 1970 00:00:00 GMT
      Pragma: no-cache
      Cache-Control: no-cache
      Expires: Thu, 01 Jan 1970 00:00:00 GMT\n
    HEADER
    html_head('')
  end

  # メニュー部分の出力
  #
  # @param userinfo ユーザ情報
  def self.html_menu(userinfo = nil)
    index = 'index.rb' # File.basename($PROGRAM_NAME)
    stg = Settings.instance
    sup = stg.value['support_url']
    title = stg.value['title']

    marquee_news
    bsignup = !userinfo || userinfo.invalid?
    return html_menu_signup(title, index, sup) if bsignup

    return html_menu_admin(title, index, sup) if userinfo.admin

    html_menu_login(title, index, sup)
  end

  # メニュー部分の出力 ログイン前
  #
  # @param title ページタイトル
  # @param index CGI本体
  # @param sup   サポートページのURL
  def self.html_menu_signup(title, index, sup)
    print <<-MENU.unindent
      <header><div align='center' class='menubase'>
      <a class='menu' href='#{index}'> Top </a>
      <a class='menu' href='#{index}?news'> News </a>
      <a class='menu menu_signup' href='#{index}?signup'> Sign Up </a>
      <a class='menu' href='#{index}?login'> Log In </a>
      <a class='menu' href='#{sup}' target='_blank'> Support </a>
      </div></header><hr>
      <div align='center'>#{title}</div><hr>
    MENU
  end

  # ポップアップメニュー制御スクリプトの出力
  def self.put_popupscript
    puts '<script type="text/javascript" src="./js/popupmenu.js"></script>'
  end

  # マイページのメニューの出力
  #
  # @param index CGI本体
  def self.menubase_mypage(index)
    "<a class='menu' href='#{index}'> Top </a>\n" \
    "<a class='menu' href='#{index}?news'> News </a>\n" \
    "<a class='menu' href='#{index}?mypage'> My Page </a>\n" \
    "<a class='menu' href='#{index}?lounge'> Lounge </a>\n" \
    "<a class='menu' href='#{index}?matchlist'> Watch </a>\n" \
    "<span class='menu' id='menu_parent_popup'>▼▼</span>\n"
  end

  # メニュー部分の出力
  #
  # @param title ページタイトル
  # @param index CGI本体
  # @param sup   サポートページのURL
  def self.html_menu_login(title, index, sup)
    print <<-MENU_LOGGEDIN.unindent
      <header><div class='menubase'>#{menubase_mypage(index)}</div>
      <div class='popup' id='menu_popup'>
       <ul>
        <li><a class='menu' href='#{index}?searchform'> Search </a></li><hr>
        <li><a class='menu' href='#{sup}' target='_blank'> Support </a></li><hr>
        <li><a class='menu' href='#{index}?logout'> Log Out </a></li>
       </ul>
      </div></header>
      <hr><div align='center'>#{title}</div><hr>
    MENU_LOGGEDIN
    put_popupscript
  end

  # メニュー部分の出力
  #
  # @param title ページタイトル
  # @param index CGI本体
  # @param sup   サポートページのURL
  def self.html_menu_admin(title, index, sup)
    print <<-MENU_LOGGEDIN.unindent
      <header><div class='menubase'>
        #{menubase_mypage(index)}
      </div>
      <div class='popup' id='menu_popup'>
       <ul>
        <li><a class='menu' href='#{index}?adminmenu'> Administration </a></li><hr>
        <li><a class='menu' href='#{index}?searchform'> Search </a></li><hr>
        <li><a class='menu' href='#{sup}' target='_blank'> Support </a></li><hr>
        <li><a class='menu' href='#{index}?logout'> Log Out </a></li>
       </ul>
      </div></header>
      <hr><div align='center'>#{title}</div><hr>
    MENU_LOGGEDIN
    put_popupscript
  end

  # Administrationメニュー
  def self.html_adminmenu
    index = 'index.rb' # File.basename($PROGRAM_NAME)
    puts <<-ADMINMENU.unindent
      <div class='menubase'>
      <a class='menu' href='#{index}?adminsettings'> Settings </a>
      <a class='menu' href='#{index}?adminnews'> News </a>
      <a class='menu' href='#{index}?adminmqnews'> Marquee News </a>
      <a class='menu' href='#{index}?adminsignature'> Signature </a>
      <a class='menu' href='#{index}?userlist'> Users </a>
      <a class='menu' href='#{index}?adminuserstg'> User Management </a>
      <a class='menu' href='#{index}?newgame'> New Game </a>
      <a class='menu' href='#{index}?admingamemanage'> Game Management </a>
      <a class='menu' href='#{index}?adminmenu'> Version </a>
      </div><hr>
    ADMINMENU
  end

  # フッターの出力
  def self.html_foot
    puts '<HR><footer><div align=right>' \
         "&copy;ぢるっち 2017-2021 with Ruby v#{RUBY_VERSION}" \
         '</div></footer></BODY></HTML>'
  end

  # 横に流れるニュース欄の出力
  def self.marquee_news
    puts '<div class="marquee-anim"><span id="mqnews">読み込み中</span></div>' \
         '<script type="text/javascript" src="js/marqueenews.js" defer>' \
         '</script>'
  end

  TEBANTEXT = [
    { sign: 'b',  text: '先手番' },
    { sign: 'w',  text: '後手番' },
    { sign: 'fb', text: '先手勝ち' },
    { sign: 'fw', text: '後手勝ち' },
    { sign: 'd',  text: '引き分け' }
  ].freeze

  # 手番文字をわかりやすい言葉に変換
  #
  # @param trn 手番文字
  # @return 手番情報文字列
  def self.turn2str(trn)
    TEBANTEXT.each do |elem|
      return elem[:text] if trn == elem[:sign]
    end
    'エラー'
  end
end
