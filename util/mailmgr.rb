# -*- encoding: utf-8 -*-

# require 'rubygems'
require 'yaml'
require 'mail'
require 'unindent'

#
# wrapper class to use mail function.
#
class MailManager
  # 初期化
  def initialize
    @dlvcfg = YAML.load_file(PathList::MAILSETTINGFILE)
  end

  attr_reader :dlvcfg

  # メールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  def send_mail(addr, subject, msg)
    mail = Mail.new do
      # from    @dlvcfg['mailaddress']
      to      addr
      subject subject
      body    msg
    end
    mail['from'] = @dlvcfg['mailaddress']

    mail.delivery_method(@dlvcfg['type'],
                         address: @dlvcfg['address'],
                         port: @dlvcfg['port'],
                         domain: @dlvcfg['domain'],
                         authentication: @dlvcfg['authentication'],
                         user_name: @dlvcfg['user_name'],
                         password: @dlvcfg['password'])

    mail.deliver
  end

  # 添付ファイル付きメールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  # @param attach  添付ファイル {filename: name, content: content}
  def send_mailex(addr, subject, msg, attach)
    mail = Mail.new do
      # from    @dlvcfg['mailaddress']
      to      addr
      subject subject
      body    msg
      add_file filename: attach[:filename], content: attach[:content]
    end
    mail['from'] = @dlvcfg['mailaddress']

    mail.delivery_method(@dlvcfg['type'],
                         address: @dlvcfg['address'],
                         port: @dlvcfg['port'],
                         domain: @dlvcfg['domain'],
                         authentication: @dlvcfg['authentication'],
                         user_name: @dlvcfg['user_name'],
                         password: @dlvcfg['password'])

    mail.deliver
  end

  # メール本文に追加するフッタ
  def self.footer
    msg = <<-FOOTER_MSG.unindent
      * Please delete this email if you believe you are not the intended recipient.
      * Please do not respond to this auto-generated email.
      FOOTER_MSG
    msg += File.read(PathList::SIGNATUREFILE, encoding: 'utf-8')
    msg
  end
end
