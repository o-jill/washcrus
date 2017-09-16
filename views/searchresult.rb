# -*- encoding: utf-8 -*-

# require 'rubygems'
# require 'unindent'

require './game/userinfo.rb'
require './views/common_ui.rb'
require './file/taikyokufile.rb'

def findgameid(tdb, ply1, ply2, from, to)
  id1 = []
  id2 = []
  id3 = []

  unless ply1.empty?
    res1 = tdb.findnameb(ply1)
    return nil if res1.empty?
    id1 = res1.keys
  end

  unless ply2.empty?
    res2 = tdb.findnamew(ply2)
    return nil if res2.empty?
    id2 = res2.keys
  end

  id12 =
    if id1.empty? && id2.empty?
      []
    elsif id1.empty?
      id2
    elsif id2.empty?
      id1
    else
      id1.merge(id2)
    end

  unless from.empty? && to.empty?
    res3 = tdb.findtime(from, to)
    return nil if res3.empty?
    id3 = res3.keys
  end

  id12.concat(id3)
end

def searchgames(ply1, ply2, from, to)
  tdb = TaikyokuFile.new
  tdb.read

  foundid = findgameid(tdb, ply1, ply2, from, to)

  return nil if foundid.nil? || foundid.empty?

  res = []
  id123.each do |i|
    res << tdb.probe(i)
  end
  res
end

#
# 検索結果画面
#
def searchresult_screen(header, title, name, userinfo, params)
  res = searchgames(params['player1'][0], params['player2'][0],
                    params['time_frame_from'][0], params['time_frame_to'][0])

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenuLogIn(name, !userinfo.invalid?)

  # print <<-TABLE_FORM.unindent
  #   <TABLE align='center' class='inpform' border='3'>
  #    <TR><TD>player1</TD><TD>#{params['player1']}</TD></TR>
  #    <TR><TD>player2</TD><TD>#{params['player2']}</TD></TR>
  #    <TR><TD>time_frame from</TD><TD>#{params['time_frame_from']}</TD></TR>
  #    <TR><TD>time_frame to</TD><TD>#{params['time_frame_to']}</TD></TR>
  #   </TABLE>
  #   TABLE_FORM

  if res.nil? || res.empty?
    print '<p>not found ...</p>'
  else
    print "<TABLE align='center' border='1'>\n" \
          '<tr><th>id</th><th>nameb</th><th>namew</th>' \
          "<th>time</th><th>download</th></tr>\n"
    res.each do |game|
      print <<-GAMEINFO.unindent
        <tr>
         <td><a href='washcrus.rb?game/#{game[:id]}' target=_blank>#{game[:id]}</a></td>
         <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
         <td><a href='dlkifu.rb?#{game[:id]}' target=_blank>download</a></td>
        </tr>
        GAMEINFO
    end
    print '</TABLE>'
  end

  CommonUI::HTMLfoot()
end
