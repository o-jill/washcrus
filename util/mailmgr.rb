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

  # メールの設定
  attr_reader :dlvcfg

  def setdeliverymethod
    @mail.delivery_method(@dlvcfg['type'],
                          address: @dlvcfg['address'],
                          port: @dlvcfg['port'],
                          domain: @dlvcfg['domain'],
                          authentication: @dlvcfg['authentication'],
                          user_name: @dlvcfg['user_name'],
                          password: @dlvcfg['password'])
    @mail.charset = 'utf-8' # It's important!
  end

  # フッターを付けてメールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  def send_mail_withfooter(addr, subject, msg)
    msg += MailManager.footer
    send_mail(addr, subject, msg)
  end

  # フッターを付けてメールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  def send_htmlmail_withfooter(addr, subject, msg, html)
    msg += MailManager.footer
    html += "<pre>#{MailManager.footer}</pre>"
    send_htmlmail(addr, subject, msg, html)
  end

  # メールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  def send_mail(addr, subject, msg)
    @mail = Mail.new do
      # from    @dlvcfg['mailaddress']
      to      addr
      subject subject
      body    msg
    end
    @mail['from'] = @dlvcfg['mailaddress']

    setdeliverymethod

    @mail.deliver
  end

  # フッターを付けて添付ファイル付きメールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  def send_mailex_withfooter(addr, subject, msg, attached)
    msg += MailManager.footer
    send_mailex(addr, subject, msg, attached)
  end

  # 添付ファイル付きメールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  # @param attach  添付ファイル {filename: name, content: content}
  def send_mailex(addr, subject, msg, attach)
    @mail = Mail.new do
      # from    @dlvcfg['mailaddress']
      to      addr
      subject subject
      body    msg
      add_file filename: attach[:filename], content: attach[:content]
    end
    @mail['from'] = @dlvcfg['mailaddress']

    setdeliverymethod

    @mail.deliver
  end

  # HTMLメールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  # @param html    HTML本文
  def send_htmlmail(addr, subject, msg, html)
    @mail = Mail.new do
      # from    @dlvcfg['mailaddress']
      to      addr
      subject subject
      text_part do
        body msg
      end
      html_part do
        content_type 'text/html; charset=utf-8'
        body html
      end
      # add_file filename: attach[:filename], content: attach[:content]
    end
    @mail['from'] = @dlvcfg['mailaddress']

    setdeliverymethod

    @mail.deliver
  end

  # フッターを付けて添付ファイル付きメールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  def send_htmlmailex_withfooter(addr, subject, msg, html, attached)
    msg += MailManager.footer
    html += "<pre>#{MailManager.footer}</pre>"
    send_htmlmailex(addr, subject, msg, html, attached)
  end

  # 添付ファイル付きメールの送信
  #
  # @param addr    メールアドレス
  # @param subject 件名
  # @param msg     本文
  # @param html    HTML本文
  # @param attach  添付ファイル {filename: name, content: content}
  def send_htmlmailex(addr, subject, msg, html, attach)
    @mail = Mail.new do
      # from    @dlvcfg['mailaddress']
      to      addr
      subject subject
      body    msg
      text_part do
        body msg
      end
      html_part do
        content_type 'text/html; charset=utf-8'
        body html
      end
      add_file attach
    end
    @mail['from'] = @dlvcfg['mailaddress']

    setdeliverymethod

    @mail.deliver
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
