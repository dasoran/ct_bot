
request = require('request')
CronJob = require('cron').CronJob
CHANNEL_LIST_URL = 'https://slack.com/api/channels.list?token=' + process.env.HUBOT_SLACK_TOKEN

CHANNEL = "general"
#CHANNEL = "chocola_test"




module.exports = (robot) ->
  request CHANNEL_LIST_URL, (err, res, body) ->
    new CronJob '0 * * * * *', () ->
      channelId = findChannelId(JSON.parse(body).channels, CHANNEL)
      kptTitle = robot.brain.get('kpt_remind')
      kptTry = robot.brain.get(kptTitle + '-try')
      robot.send {room: channelId}, '現在のKPTのTryです！\n```\n' + kptTry + '```'
    , null, true, 'Asia/Tokyo'


  robot.respond /kpt new/i, (msg) ->
    request CHANNEL_LIST_URL, (err, res, body) ->
      channel = findChannel(JSON.parse(body).channels, msg.envelope.room)
      if (channel is CHANNEL)
        date = new Date()
        kptTitle = 'kpt-' + date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDay()
        kptTitleListJson = robot.brain.get('kpt_title_list')
        if kptTitleListJson is null
          kptTitleList = Array()
        else
          kptTitleList = JSON.parse(kptTitleListJson)
        if kptTitle not in kptTitleList
          kptTitleList.push(kptTitle)
          robot.brain.set('kpt_title_list', JSON.stringify(kptTitleList))
          robot.brain.set(kptTitle + '-keep', '')
          robot.brain.set(kptTitle + '-problem', '')
          robot.brain.set(kptTitle + '-try', '')
          msg.reply 'KPT「' + kptTitle + '」を作成しました！'
        else
          msg.reply 'KPT「' + kptTitle + '」はすでに存在します:guttari:'
  robot.respond /kpt list/i, (msg) ->
    request CHANNEL_LIST_URL, (err, res, body) ->
      channel = findChannel(JSON.parse(body).channels, msg.envelope.room)
      if (channel is CHANNEL)
        kptTitleListJson = robot.brain.get('kpt_title_list')
        if kptTitleListJson is null
          msg.reply 'KPTは存在しません:guttari:'
        else
          kptTitleList = JSON.parse(kptTitleListJson)
          if kptTitleList.length is 0
            msg.reply 'KPTは存在しません:guttari:'
          else
            resMsg = 'KPTは以下の通りです！\n```\n'
            for kptTitle in kptTitleList
              resMsg += kptTitle + '\n'
            resMsg += '```'
            msg.reply resMsg
  robot.respond /kpt set (.+) (.+) ((.|\s)+)/i, (msg) ->
    request CHANNEL_LIST_URL, (err, res, body) ->
      channel = findChannel(JSON.parse(body).channels, msg.envelope.room)
      if (channel is CHANNEL)
        kptTitle = msg.match[1]
        kptTitleListJson = robot.brain.get('kpt_title_list')
        if kptTitleListJson is null
          msg.reply 'KPTは存在しません:guttari:'
        else
          kptTitleList = JSON.parse(kptTitleListJson)
          if kptTitle not in kptTitleList
            msg.reply 'KPT「'+ kptTitle + '」は存在しません:guttari:'
          else
            status = msg.match[2]
            if status not in ['keep', 'problem', 'try']
              msg.reply '使い方は次の通りです！\n```\n@chocola kpt set [KPT名] [keep/problem/try] [内容]```'
            else
              contents = msg.match[3]
              robot.brain.set(kptTitle + '-' + status, contents)
              msg.reply 'KPT「' + kptTitle + '」の ' + status + ' を登録しました！'
  robot.respond /kpt delete (.+)/i, (msg) ->
    request CHANNEL_LIST_URL, (err, res, body) ->
      channel = findChannel(JSON.parse(body).channels, msg.envelope.room)
      if (channel is CHANNEL)
        kptTitle = msg.match[1]
        kptTitleListJson = robot.brain.get('kpt_title_list')
        if kptTitleListJson is null
          msg.reply 'KPTは存在しません:guttari:'
        else
          kptTitleList = JSON.parse(kptTitleListJson)
          if kptTitle not in kptTitleList
            msg.reply 'KPT「'+ kptTitle + '」は存在しません:guttari:'
          else
            kptTitleListRemoved = Array()
            for kptTitleInList in kptTitleList
              if kptTitleInList is kptTitle
                continue
              kptTitleListRemoved.push(kptTitleInList)
            robot.brain.set('kpt_title_list', JSON.stringify(kptTitleListRemoved))
            robot.brain.remove(kptTitle + '-keep')
            robot.brain.remove(kptTitle + '-problem')
            robot.brain.remove(kptTitle + '-try')
            msg.reply 'KPT「'+kptTitle+'」を削除しました！'
  robot.respond /kpt show (.+)/i, (msg) ->
    request CHANNEL_LIST_URL, (err, res, body) ->
      channel = findChannel(JSON.parse(body).channels, msg.envelope.room)
      if (channel is CHANNEL)
        kptTitle = msg.match[1]
        kptTitleListJson = robot.brain.get('kpt_title_list')
        if kptTitleListJson is null
          msg.reply 'KPTは存在しません:guttari:'
        else
          kptTitleList = JSON.parse(kptTitleListJson)
          if kptTitle not in kptTitleList
            msg.reply 'KPT「'+ kptTitle + '」は存在しません:guttari:'
          else
            resMsg = '\nKeep\n```\n'
            resMsg += robot.brain.get(kptTitle + '-keep')
            resMsg += '\n```\nProblem\n```\n'
            resMsg += robot.brain.get(kptTitle + '-problem')
            resMsg += '\n```\nTry\n```\n'
            resMsg += robot.brain.get(kptTitle + '-try')
            resMsg += '\n```'
            msg.reply resMsg
  robot.respond /kpt remind (.+)/i, (msg) ->
    request CHANNEL_LIST_URL, (err, res, body) ->
      channel = findChannel(JSON.parse(body).channels, msg.envelope.room)
      if (channel is CHANNEL)
        kptTitle = msg.match[1]
        kptTitleListJson = robot.brain.get('kpt_title_list')
        if kptTitleListJson is null
          msg.reply 'KPTは存在しません:guttari:'
        else
          kptTitleList = JSON.parse(kptTitleListJson)
          if kptTitle not in kptTitleList
            msg.reply 'KPT「'+ kptTitle + '」は存在しません:guttari:'
          else
            robot.brain.set('kpt_remind', kptTitle)
            msg.reply 'KPT「' + kptTitle + '」をリマインド登録しました！'
 


  robot.respond /kpt help/i, (msg) ->
    request CHANNEL_LIST_URL, (err, res, body) ->
      channel = findChannel(JSON.parse(body).channels, msg.envelope.room)
      if (channel is CHANNEL)
        resMsg = 'KPTの使い方です！\n```\n'
        resMsg += '@chocola kpt new\n'
        resMsg += '  - 今日の日付でkptを作成します\n'
        resMsg += '@chocola kpt list\n'
        resMsg += '  - 現在存在するKPTを表示します\n'
        resMsg += '@chocola kpt set [KPT名] [keep/problem/try] [内容]\n'
        resMsg += '  - KPTを設定します\n'
        resMsg += '@chocola kpt show [KPT名]\n'
        resMsg += '  - KPTを表示します\n'
        resMsg += '@chocola kpt delete [KPT名]\n'
        resMsg += '  - KPTを削除します\n'
        resMsg += '@chocola kpt remind [KPT名]\n'
        resMsg += '  - 毎日リマインドするKPTを設定します\n'
        resMsg += '```'
        msg.reply resMsg


findChannel = (channels, targetName) ->
  for channel_id of channels
    channel = channels[channel_id]
    if channel.id == targetName
      return channel.name
  return null

findChannelId = (channels, targetName) ->
  for channel_id of channels
    channel = channels[channel_id]
    if channel.name == targetName
      return channel.id
  return null



