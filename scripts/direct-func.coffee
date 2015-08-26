# Description:
#   direct 専用のメッセージ(スタンプや機能スタンプなど)を送信します。
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot 案件 - 最新5件の案件を表示します。
#
# Author:
#   masataka.takeuchi

module.exports = (robot) ->

  # Sending

  robot.respond /text/i, (res) ->
    res.send
      text: "This message is text."

  robot.respond /stamp/i, (res) ->
    res.send
      stamp_set: "3"
      stamp_index: "1152921507291203198"

  robot.respond /textstamp/i, (res) ->
    res.send
      stamp_set: "3"
      stamp_index: "1152921507291203198"
      text: "Hello"

  robot.respond /yesno/i, (res) ->
    res.send
      question: "YES or NO?"

  robot.respond /select/i, (res) ->
    res.send
      question: "SELECT?"
      options: ["OPT1", "OPT2", "OPT3"]

  robot.respond /task/i, (res) ->
    res.send
      title: "TODO"
      closing_type: 0 # ANY:0, ALL:1

  robot.respond /file/i, (res) ->
    res.send
      path:"sample.png"

  robot.respond /pic/i, (res) ->
    res.send
      path:"sample.png"
      name:"pic.png"

  # Receiving

  robot.respond "stamp", (res) ->
    res.send "#{res.json.stamp_set} - #{res.json.stamp_index}"

  robot.respond "yesno", (res) ->
    if not res.json.response?
      res.send "Your question is #{res.json.question}."
    else
      res.send "Your answer is #{res.json.response}."

  robot.respond "select", (res) ->
    if not res.json.response?
      res.send "Your question is #{res.json.question}."
    else
      res.send "Your answer is #{res.json.options[res.json.response]}."

  robot.respond "task", (res) ->
    if not res.json.done?
      res.send "Your task is #{res.json.title}."
    else
      res.send "Your task is #{if res.json.done then 'done' else 'undone'}."

  robot.respond "file", (res) ->
    res.send "File received.
      name: #{res.json.name}
      type: #{res.json.content_type}
      size: #{res.json.content_size}bytes"
    res.download res.json, (path) ->
      res.send "downloaded to #{path}"
      if res.json.content_type.match(/^text/)
        res.send "content is " + require('fs').readFileSync(path, 'utf8').substring(0, 10)

  robot.respond "map", (res) ->
    res.send "Your location is #{res.json.place} at #{res.json.lat}, #{res.json.lng}"

  robot.respond /({.*})/, (res) ->
    text = res.match[1]
    res.send "ECHO: " + text, text

  # Talk Info

  robot.respond /room/i, (res) ->
    console.log res

    res.send "This room type is " + ["unknown", "pair", "group"][res.message.roomType]

    if res.message.roomType == 2  # Group talk
      res.send "Group name is #{res.message.roomTopic}"

    res.topic "BotGroup"

    text = ""
    for user in res.message.roomUsers
      text += "#{user.name} #{user.email} #{user.profile_url}\n\n"
    res.send text

    text = ""
    for id,talk of res.message.rooms
      text += "name:#{talk.topic} type:#{talk.type} users:#{talk.users}\n\n"
    res.send text

  robot.respond /brain/i, (res) ->
    text = ""
    for id,talk of robot.brain.rooms()
      text += "name:#{talk.topic} type:#{talk.type} users:#{talk.users}\n\n"
    res.send text

  robot.respond /talks/i, (res) ->
    console.log JSON.stringify(robot.brain.rooms())

  # User Info

  robot.respond /users/i, (res) ->
    users = robot.brain.users()
    res.send JSON.stringify(users)

    userId = Object.keys(users)[0]
    res.send JSON.stringify(robot.brain.userForId(userId))

    user = users[userId]
    res.send JSON.stringify(robot.brain.userForName(user.name))


  # Domain Info

  robot.respond /domains/i, (res) ->
    domains = robot.brain.domains()
    console.log( JSON.stringify(domains) )


  # Events

  robot.topic (res) ->
    res.send "Topic is changed: #{res.message.text}"

  robot.join (res) ->
    res.send "Nice to meet you!"

  robot.enter (res) ->
    res.send "Hi! #{res.message.user.name}"

  robot.leave (res) ->
    res.send "Good bye! #{res.message.user.name}"

  robot.hear /read after/, (res) ->
    res.send
      text: "Read thie message, please!"
      onsend: (sent) ->
        console.log sent
        setTimeout ->
          text = []
          text.push "#{user.name} read after 5sec." for user in sent.readUsers
          text.push "#{user.name} did't read after 5sec." for user in sent.unreadUsers
          res.send text.join("\n")
        , 5000

  robot.hear /read now/, (res) ->
    res.send
      text: "Read thie message, please!"
      onread: (readNowUsers, readUsers, unreadUsers) ->
        text = []
        text.push "#{user.name} read now." for user in readNowUsers
        res.send text.join("\n")

  robot.hear /onsend/, (res) ->
    res.send
      text: "Check console."
      onsend: (sent) ->
        console.log "sent text.", sent
    res.send
      path:"sample.png"
      onsend: (sent) ->
        console.log "sent file.", sent

  # Others

  robot.respond /bye/i, (res) ->
    res.send "Good bye!"
    res.leave()

  robot.respond /announce( to (.*))?/i, (res) ->
    res.announce "THIS IS AN ANNOUNCEMENT!"

    search = res.match[2]
    if search?
      for id,domain of robot.brain.domains()
        robot.announce domain, "ANNOUNCEMENT!" if domain.name.indexOf(search) >= 0
                      # or { id: id }

  console.log robot.direct.parseInt64('288691111457718272')
  console.log robot.direct.stringifyInt64(robot.direct.parseInt64('288691111457718272'))

