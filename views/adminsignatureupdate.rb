# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'unindent'
# require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# mail signature編集結果画面
#
class AdminSignatureUpdateScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
    @errmsg = ''
  end

  # 署名ファイルの更新
  #
  # @param params パラメータハッシュオブジェクトのparams['signature']
  def update_param(params)
    if params
      write_signature(params[0])
    else
      @errmsg += 'invalid parameters...<br>'
    end
  end

  # 署名ファイルへの書き込み
  #
  # @param signature 書き込む内容
  def write_signature(signature)
    File.write(PathList::SIGNATUREFILE, signature.gsub("\r\n", "\n"))
  rescue StandardError => er
    @errmsg += 'failed to update...<pre>'
    @errmsg += er.to_s
    @errmsg += '</pre>'
  end

  # 編集結果の表示
  def put_signature
    msg = File.read(PathList::SIGNATUREFILE, encoding: 'utf-8')

    puts <<-SIGNATURE_INFO.unindent
      <style type=text/css>
       .signature {
         border: inset 5px blue;
         padding: 5px;
         text-align: left;
         width: 60vw;
       }
      </style>
      <div align='center'>
       Signature updated
       <div class='signature'>
        <pre>#{msg}</pre>
       </div>
      </div>
    SIGNATURE_INFO
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    update_param(params['signature'])

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    if @errmsg.empty?
      put_signature
    else
      puts @errmsg
    end

    CommonUI.html_foot
  end
end
