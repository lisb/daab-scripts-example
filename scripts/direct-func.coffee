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
      options: ["OPT1", "OPT2", "OPT3", "0123456789012345678901234567890123456789012345678901234567890123456789"]

  robot.respond /task/i, (res) ->
    res.send
      title: "TODO"
      closing_type: 0 # ANY:0, ALL:1

  robot.respond /file/i, (res) ->
    res.send
      path:"sample.png"

  robot.respond /ft/i, (res) ->
    res.send
      text: "file with text"
      path: "sample.png"
      name: "pic.png"
      type: "image/png"
      onsend: (sent, msg) ->
        for file in msg.content.files
          robot.direct.api.deleteAttachment(file.file_id)

  robot.respond /multi/i, (res) ->
    res.send
      text: "multi upload"
      path: ['./sample.png', './sample2.png']
      name: ["name1.png", "name2.png"]

  robot.respond /pic/i, (res) ->
    res.send
      path:"sample.png"
      name:"pic.png"

  ## close action stamp

  robot.respond /close/, (res) ->
    res.send
      question: "CLOSE YESNO?"
      onsend: (sent) ->
         res.send
           close_yesno: sent.message.id
    res.send
      question: "CLOSE SELECT?"
      options: ["OPT1"]
      onsend: (sent) ->
         res.send
           close_select: sent.message.id
    res.send
      title: "CLOSE TODO?"
      closing_type: 0 # ANY:0, ALL:1
      onsend: (sent) ->
         res.send
           close_task: sent.message.id


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

  # reply to action stamps

  robot.respond "yesno", (res) ->
    if not res.json.response?
      console.log "in_reply_to " + res.message.id
      res.send
        in_reply_to: res.message.id
        response: true

  robot.respond "select", (res) ->
    if not res.json.response?
      res.send
        in_reply_to: res.message.id
        response: 0

  robot.respond "task", (res) ->
    if not res.json.done?
      res.send
        in_reply_to: res.message.id
        done: true

  # answers
  robot.respond /answers/i, (res) ->
    res.send
      question: "answer?"
      onsend: (sent) ->
        setTimeout ->
          sent.answer (trueUsers, falseUsers, r, q) ->
            console.log "YES", trueUsers
            console.log "NO", falseUsers
            console.log "===", r
            console.log "---", q
        , 5000


  onfile = (res, file) ->
    res.send "File received.
      name: #{file.name}
      type: #{file.content_type}
      size: #{file.content_size}bytes"
    res.download file, (path) ->
      res.send "downloaded to #{path}"
      if file.content_type.match(/^text/)
        res.send "content is " + require('fs').readFileSync(path, 'utf8').substring(0, 10)

  robot.respond "file", (res) ->
    console.log "message type: 'file'"
    onfile(res, res.json)

  robot.hear "files", (res) ->
    console.log "message type: 'files'"
    for file in res.json.files
      onfile(res, file)
    res.send "with text: #{res.json.text}" if res.json.text

  robot.direct.on "get_file_responsed", (res) ->
    console.log res.files
  robot.hear /fl/, (res) ->
    robot.direct.api.getAttachments { id: res.message.rooms[res.message.room].id_i64 }

  robot.respond "map", (res) ->
    res.send "Your location is #{res.json.place} at #{res.json.lat}, #{res.json.lng}"

  robot.hear "map", (res) ->
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

  robot.respond /usermap/i, (res) ->
    users = robot.brain.users()
    console.log Object.keys(users).map((id) ->
      u = users[id]
      "#{u.name}: #{robot.direct.stringifyInt64(u.id_i64)}"
    )

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
      onread: () -> true
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
      text: "Now sending..."
      onsend: (sent) ->
        res.send "completed. messageId: #{sent.message.id}"
    res.send
      path:"sample.png"
      onsend: (sent) ->
        console.log "sent file.", sent

  # Others

  robot.respond /bye/i, (res) ->
    res.send "Good bye!"
    res.leave()

  robot.hear /banned word/, (res) ->
    res.leave res.message.user

  robot.respond /announce( to (.*))?/i, (res) ->
    res.announce "THIS IS AN ANNOUNCEMENT!"

    search = res.match[2]
    if search?
      for id,domain of robot.brain.domains()
        robot.announce domain, "ANNOUNCEMENT!" if domain.name.indexOf(search) >= 0
                      # or { id: id }

  robot.respond /domainId/i, (res) ->
    id = res.message.rooms[res.message.room].domainId
    console.log id
    id64 = res.message.rooms[res.message.room].domainId_i64
    console.log robot.direct.stringifyInt64(id64)

  console.log robot.direct.parseInt64('288691111457718272')
  console.log robot.direct.stringifyInt64(robot.direct.parseInt64('288691111457718272'))

  robot.respond /uuu/, (res) ->
    console.log res.message.user
