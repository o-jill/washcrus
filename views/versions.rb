# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'

require './file/taikyokufile.rb'
require './file/userinfofile.rb'
require './views/common_ui.rb'

#
# version情報画面
#
class VersionsScreen
  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name
  end

  def put_err_sreen(errmsg, userinfo)
    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name, userinfo)
    puts errmsg
    CommonUI::HTMLfoot()
  end

  def put_githash
    gitlog = File.read('./REVISION')
    print <<-VERSIONINFO.unindent
      <div align='center'>
       <div class='githash'>
        Git hash:
        <pre>#{gitlog}</pre>
        DO NOT forget to update REVISION file in updating this system.
       </div>
      </div>
      VERSIONINFO
  rescue StandardError => _e
    puts <<-REVISION_FILE_ERR.unindent
      <div align='center'>
       <div class='githash'>
        failed to read REVISION file.<BR>
        please make REVISION file by running ex.'git log -1 >REVISION'.
       </div>
      </div>
      REVISION_FILE_ERR
  end

  def put_geminfo
    gemlog = File.read('./Gemfile.lock')
    print <<-GEMINFO.unindent
      <div align='center'>
       <div class='geminfo'>
        Gem information in Gemfile.lock:
        <pre>#{gemlog}</pre>
       </div>
      </div>
      GEMINFO
  rescue StandardError => _e
    puts <<-GEMLOCK_FILE_ERR.unindent
      <div align='center'>
       <div class='geminfo'>
        failed to read Gemfile.lock file.<BR>
        please use 'bundle' to run this system.
       </div>
      </div>
      GEMLOCK_FILE_ERR
  end

  def show(userinfo)
    return put_err_sreen("your log-in information is wrong ...\n", userinfo) \
      if userinfo.nil? || userinfo.invalid?

    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name, userinfo)

    CommonUI::HTMLAdminMenu()

    put_githash

    put_geminfo

    CommonUI::HTMLfoot()
  end
end
