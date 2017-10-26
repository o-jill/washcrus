# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
# require './game/userinfo.rb'
require './views/common_ui.rb'

#
# mail signature編集結果画面
#
class AdminSignatureUpdateScreen
  SIGNATUREFILE = './config/signature.txt'.freeze

  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
    @errmsg = ''
  end

  # 署名ファイルの更新
  #
  # @param signature 書き込む内容
  def update_param(params)
    if params['signature'].nil?
      @errmsg += 'invalid parameters...<br>'
    else
      write_signature(params['signature'][0])
    end
  end

  # 署名ファイルへの書き込み
  #
  # @param signature 書き込む内容
  def write_signature(signature)
    File.write(SIGNATUREFILE, signature.gsub("\r\n", "\n"))
  rescue => e
    @errmsg += 'failed to update...<pre>'
    @errmsg += e.to_s
    @errmsg += '</pre>'
  end

  # 編集結果の表示
  def put_signature
    msg = File.read(SIGNATUREFILE)

    puts <<-SIGNATURE_INFO.unindent
      <style type=text/css>
       .news {
         border: inset 5px blue;
         padding: 5px;
         text-align: left;
         width: 60vw;
       }
      </style>
      <div align='center'>
       Signature updated
       <div class='news'>
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
    return puts "Content-Type: text/plain;\n\nERR_NOT_ADMIN" \
        unless userinfo.admin

    update_param(params)

    CommonUI::HTMLHead(@header)
    CommonUI::HTMLmenu(userinfo)
    CommonUI::HTMLAdminMenu()

    if @errmsg.length.zero?
      put_signature
    else
      puts @errmsg
    end

    CommonUI::HTMLfoot()
  end
end
