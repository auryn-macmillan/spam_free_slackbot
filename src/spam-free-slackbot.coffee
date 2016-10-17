# Description
#   Provides canned responses for sets of trigger words.
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot admin add [username]- adds user to admin list
#   hubot admin remove [username]- removes user from admin list
#   hubot admin list users - shows admin list
#   hubot channel allow - Invites me to the party in this channel!
#   hubot channel shush - Informs me that I'm being a nuisance and should leave this channel.
#   hubot triggers new [name]; [comma,separated,trigger,words]; [your response here] - adds new trigger-response set.
#   hubot triggers remove [name] - removes trigger-response set.
#   hubot triggers list - List current trigger-response sets.
#   hubot triggers change response [name] [new response]
#   hubot triggers change triggers [name] [new comma separated triggers]
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Auryn Macmillan <aurynmacmillan@gmail.com>

# defines channel storage structure.
class Channel
  constructor: (@name) ->

  lineCount: 20
  lastLine: 0
  timeNow: 0
  lastTime: 0

# defines trigger-response storage structure.

class Response
  constructor: (@name) ->

# number of lines between repeat responses
LINECOUNT = 20

# time (in miliseconds) between repeat responses
TIMELIMIT = 5 * 60 * 1000

# spam on/off(default)
SPAM = false

module.exports = (robot) ->

  robot.brain.data.ADMINS = {
    Shell: 'Shell', # comment out this line before you ship this!
    auryn_macmillan: 'auryn_macmillan'
  }

  # list of robot.brain.data.channels that gnobot where gnobot is allowed to respond.
  robot.brain.data.channels = {}

  # list of trigger response pairs
  robot.brain.data.responses = {}

  # respond commands
  robot.respond /(.*)/i, (res) ->
    # split input into array by spaces
    commArray = res.match[1].split " "
    # if user is in hubot's admin list
    if robot.brain.data.ADMINS[res.message.user.name]
      # look for first command term
      switch commArray[0]
        # admin commands
        when "admin"
          switch commArray[1]
            # list usernames in admin list (not working for some reason)
            when "list"
              list = []
              for x of robot.brain.data.ADMINS
                list.push(robot.brain.data.ADMINS[x])
              res.send "The following users have access to my admin commands:\n" + list
            # add username to admin list
            when "add"
              list = []
              robot.brain.data.ADMINS[commArray[2]] = commArray[2]
              for x of robot.brain.data.ADMINS
                list.push(robot.brain.data.ADMINS[x])
              res.send "My current admin users are: " + list
            # remove username from admin list
            when "remove"
              list = []
              if res.match[2] != res.message.user.name
                delete robot.brain.data.ADMINS[commArray[2]]
                for x of robot.brain.data.ADMINS
                  list.push(robot.brain.data.ADMINS[x])
                res.send "My current admin users are: " + list
              else res.send "You cannot remove yourself from the admin list."
        # spam on/off
        when "spam"
          switch commArray[1]
            when "on"
              SPAM = true
              res.send "Aaaaww yis"
            when "off"
              SPAM = false
              res.send ":disappointed:"
        # list
        when "list"
          switch commArray[1]
            when "channels"
              chans = []
              for x of robot.brain.data.channels
                chans.push(robot.brain.data.channels[x].name)
              res.send chans
            when "admins"
              list = []
              for x of robot.brain.data.ADMINS
                list.push(robot.brain.data.ADMINS[x])
              res.send "The following users have access to my admin commands:\n" + list
            when "triggersets"
              for n of robot.brain.data.responses
                res.send "\n*Set name:* " + robot.brain.data.responses[n].name + "\n--Triggers: " + robot.brain.data.responses[n].triggers + "\n--Responses: " + robot.brain.data.responses[n].response
        # channel commands
        when "channel"
          switch commArray[1]
            when "allow"
              if !robot.brain.data.channels[res.message.room]
                robot.brain.data.channels[res.message.room] = new Channel res.message.room
                res.send "Thanks " + res.message.user.name + " glad to be here! :bowtie:"
              else
                res.send "I'm already allowed in this channel, but thanks anyway."
            when "disallow"
              if robot.brain.data.channels[res.message.room]
                res.send "OK " + res.message.user.name + " , I won't post here anymore. :disappointed:"
                delete robot.brain.data.channels[res.message.room]
              else
                res.send "I'm already not allowed, no need to rub it in."
            when "list"
              chans = []
              for x of robot.brain.data.channels
                chans.push(robot.brain.data.channels[x].name)
              res.send chans
        # triggers commands
        when "triggers"
          switch commArray[1]
            when "list"
              for n of robot.brain.data.responses
                res.send "\n*Set name:* " + robot.brain.data.responses[n].name + "\n--Triggers: " + robot.brain.data.responses[n].triggers + "\n--Responses: " + robot.brain.data.responses[n].response
            # create new trigger-response set.
            when "new"
              # remove first two elements ("trigger" and "new") from commArray
              commArray.splice(0,2)
              # store trigger name
              trigName = commArray[0]
              # remove trigger name from array
              commArray.splice(0,1)
              # create new trigger-response object
              robot.brain.data.responses[trigName] = new Response trigName
              # create empty string
              newString = ""
              # reconstruct the remaining array elements into a string
              for x in commArray
                newString = newString + x + " "
              # split string into triggers and response
              commArray = newString.split " -> "
              # split triggers string into array
              robot.brain.data.responses[trigName].triggers = commArray[0].toLowerCase().split ","
              # save response
              robot.brain.data.responses[trigName].response = commArray[1]
              res.send "*For these trigger words:*\n" + robot.brain.data.responses[trigName].triggers + "\n*The following response has been added:*"#\n" + robot.brain.data.responses[trigName].response = commArray[1]
            # remove trigger-response set.
            when "remove"
              res.send "Trigger-response pair [" + robot.brain.data.responses[commArray[2]].name + "] removed."
              delete robot.brain.data.responses[commArray[2]]
            # modify trigger-response set.
            when "modify"
              switch commArray[2]
                # modify triggers
                when "triggers"
                  # save trigger-response set name.
                  trigName = commArray[3]
                  # remove first four elements (triggers, modify, triggers, trigName) from commArray
                  commArray.splice(0,4)
                  # push new triggers to array
                  newTrigs = []
                  for x of commArray
                    newTrigs.push(commArray[x])
                  # replace original trigger array with new trigger array
                  robot.brain.data.responses[trigName].triggers = newTrigs
                  # confirmation message
                  res.send "*[" + trigName + "] triggers changed to:*\n" + robot.brain.data.responses[trigName].triggers
                # modify responses
                when "responses"
                  # save trigger-response set name.
                  trigName = commArray[3]
                  # remove first four elements (triggers, modify, responses, trigName) from commArray
                  commArray.splice(0,4)
                  # reconstruct response from what is left of commArray
                  newString = ""
                  #res.send commArray
                  for x in commArray
                    newString = newString + x + " "
                  robot.brain.data.responses[trigName].response = newString
                  res.send "*[" + robot.brain.data.responses[trigName].name + "] response changed to:*\n" + robot.brain.data.responses[trigName].response

  # listen for triggers
  robot.hear /(.*)/i, (res) ->
    # check if robot.brain.data.responses are allowed in this channel,
    if robot.brain.data.channels[res.message.room]
      # iterate line count
      robot.brain.data.channels[res.message.room].lineCount++
      # get current time, -0 becasue otherwise 'new Date()' returns a string.
      robot.brain.data.channels[res.message.room].timeNow = new Date() - 0
    for comm of robot.brain.data.responses
      if !robot.brain.data.responses[comm][res.message.room]
        robot.brain.data.responses[comm][res.message.room] = new Channel res.message.room
      # check if robot.brain.data.responses are allowed in this channel,
      # and check the current time is more than 5 minutes from the last time this message was posted,
      # and check that there has been at least 20 lines posted since the last time this message was posted.
      if robot.brain.data.channels[res.message.room] and (SPAM or (robot.brain.data.channels[res.message.room].timeNow - robot.brain.data.responses[comm][res.message.room].lastTime > TIMELIMIT and robot.brain.data.channels[res.message.room].lineCount - robot.brain.data.responses[comm][res.message.room].lastLine > LINECOUNT))
        for trig of robot.brain.data.responses[comm].triggers
          if res.match[1].toLowerCase().includes(robot.brain.data.responses[comm].triggers[trig])
            res.send robot.brain.data.responses[comm].response
            robot.brain.data.responses[comm][res.message.room].lastTime = robot.brain.data.channels[res.message.room].timeNow
            robot.brain.data.responses[comm][res.message.room].lastLine = robot.brain.data.channels[res.message.room].lineCount
            break
