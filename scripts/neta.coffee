progress = [
  'http://livedoor.blogimg.jp/matometters/imgs/4/c/4cc416b4.jpg'
  'http://forum.shimarin.com/uploads/default/3/5a6b5c05cceb7cf3.png'
  'http://37.media.tumblr.com/3497ded6d8b569cfe0d0152f8fc6bc9d/tumblr_mzyaeoXEIS1sckns5o1_500.jpg'
  'http://forum.shimarin.com/uploads/default/6/8b3c7003765d0f2e.jpg'
  'http://38.media.tumblr.com/31ab4065305e3607b951332dde32b789/tumblr_mrkrlyMMIU1sckns5o1_500.jpg'
]



module.exports = (robot) ->
  robot.hear /^進捗どう(ですか?)?/, (msg) ->
    msg.send msg.random progress

