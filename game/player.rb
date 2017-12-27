# -*- encoding: utf-8 -*-

# 対局者情報
class Player
  # 初期化
  #
  # @param id_ ID
  # @param nm 名前
  # @param em メールアドレス
  def initialize(id_, nm, em)
    @id = id_
    @name = nm
    @email = em
    @thinktime = 0
    @extracount = 20
  end

  # ID
  attr_reader :id

  # 名前
  attr_reader :name

  # メールアドレス
  attr_reader :email

  # 持ち時間
  attr_accessor :thinktime

  # 考慮時間回数
  attr_accessor :extracount

  # 持ち時間の設定
  #
  # @param hash { thinktime: thinktime, extracount: extracount }
  def setmochijikan(hash)
    @thinktime = hash[:thinktime]
    @extracount = hash[:extracount]
  end

  # ハッシュの生成
  #
  # @return { id: @id, name: @name, mail: @email }
  def genhash
    { id: @id, name: @name, mail: @email }
  end

  # 持ち時間ハッシュの生成
  #
  # @return { thinktime: @thinktime, extracount: @extracount }
  def gentimehash
    { thinktime: @thinktime, extracount: @extracount }
  end

  # 自分のIDと同じかどうか
  #
  # @return 同じIDの時true
  def myid?(some_id)
    @id == some_id
  end
end
