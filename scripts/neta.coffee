
request = require('request')
fs = require('fs')
exec = require('child_process').exec

CHANNEL_LIST_URL = 'https://slack.com/api/channels.list?token=' + process.env.HUBOT_SLACK_TOKEN
SINCHOKU_PATH ="sinchoku_pict"

module.exports = (robot) ->
  robot.hear /^進捗どう(ですか?)?/, (msg) ->
    fs.readdir SINCHOKU_PATH, (err, files) ->
      if err
        throw err
      fileList = []
      files.filter((file) ->
          return fs.statSync(SINCHOKU_PATH + '/' + file).isFile() && /.*\.jpg$/.test(file)
      ).forEach((file) ->
          fileList.push(file)
      )
      filename = msg.random fileList
      request CHANNEL_LIST_URL, (err, res, body) ->
        channel = findChannel(JSON.parse(body).channels, msg.envelope.room)
        exec "curl -F file=@#{SINCHOKU_PATH}/#{filename} -F channels=#{channel} -F token=#{process.env.HUBOT_SLACK_TOKEN} https://slack.com/api/files.upload", (err, stdout, stderr) ->
          if err
            console.log(err,stdout,stderr)

findChannel = (channels, targetName) ->
  for channel_id of channels
    channel = channels[channel_id]
    if channel.id == targetName
      return channel.name
  return null
