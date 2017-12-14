require 'spec_helper'

require './file/chatfile.rb'
require './file/pathlist.rb'

describe 'ChatFile' do
  it "is initialized with 'game-id'" do
    cf = ChatFile.new('0123456')
    expect(cf.id).to eq('0123456')
    expect(cf.path).to eq(PathList::TAIKYOKUDIR + '0123456' + PathList::CHATFILE)
    expect(cf.msg).to eq(ChatFile::ERRMSG)
  end
end
