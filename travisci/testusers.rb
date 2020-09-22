# テスト用ユーザー情報
module TestUsers
  ADMININFO = {
    email: 'admin1@example.com',
    pwd: 'admin'
  }.freeze
  JOHN = {
    rname: 'john doe',
    remail: 'johndoe@example.com',
    remail2: 'johndoe@example.com',
    rpassword: 'john',
    rpassword2: 'john'
  }.freeze
  NEWJOHNINFO = { email: 'johndoe1@example.com', pwd: 'doee' }.freeze
  JOHNMANYMISS = {
    rname: 'doe',
    remail: 'johndoe1_example.com',
    remail2: 'nanashi@example.com',
    rpassword: 'doe',
    rpassword2: 'john'
  }.freeze
  STRANGEJOHN = {
    rname: 'john doe http://john.example.com yeah yeah',
    remail: 'johnjohndoe@example.com',
    remail2: 'johnjohndoe@example.com',
    rpassword: 'john',
    rpassword2: 'john'
  }.freeze
end
