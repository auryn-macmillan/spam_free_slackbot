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


class Channel
  constructor: (@name) ->

  lineCount: 20
  lastLine: 0
  timeNow: 0
  lastTime: 0


class Response
  constructor: (@name) ->

  channel: {
    lastLine: null
    lastTime: null
  }
# number of lines between repeat responses
LINECOUNT = 20
# time (in miliseconds) between repeat responses
TIMELIMIT = 5 * 60 * 1000

SPAM = false

module.exports = (robot) ->

  robot.brain.data.ADMINS = {
    Shell: 'Shell', # comment out this line before you ship this!
    auryn_macmillan: 'auryn_macmillan'
  }

  # list of robot.brain.data.channels that gnobot where gnobot is allowed to respond.
  robot.brain.data.channels = {}
  #robot.brain.set('channelz', robot.brain.data.channels)

  # list of trigger response pairs
  robot.brain.data.responses = {}
  #robot.brain.set('responsez', robot.brain.data.responses)

  # set spam on or off
  robot.respond /spam (.*)/i, (res) ->
    if robot.brain.data.ADMINS[res.message.user.name]
      switch res.match[1]
        when "on"
          SPAM = true
          res.send "Aaaaww yis"
        when "off"
          SPAM = false
          res.send ":disappointed:"

  # admin [add/remove/list] [username]
  robot.respond /admin (.*) (.*)/i, (res) ->
    # check if user is in admin list
    if robot.brain.data.ADMINS[res.message.user.name]
      switch res.match[1]
        # list usernames in admin list (not working for some reason)
        when "list"
          list = []
          for x of robot.brain.data.ADMINS
            list.push(robot.brain.data.ADMINS[x])
          res.send "The following users have access to my admin commands:\n" + list
        # add username to admin list
        when "add"
          robot.brain.data.ADMINS[res.match[2]] = res.match[2]
          for x of robot.brain.data.ADMINS
            res.send robot.brain.data.ADMINS[x]
        # remove username from admin list
        when "remove"
          if res.match[2] != res.message.user.name
            delete robot.brain.data.ADMINS[res.match[2]]
            for x of robot.brain.data.ADMINS
              res.send robot.brain.data.ADMINS[x]
          else res.send "You cannot remove yourself from the admin list."
        # if you is not in admin list, send error message
        else res.send "beep boop beep - does not compute"


  # add current channel to allowed robot.brain.data.channels.
  robot.respond /channel allow/i, (res) ->
    if !robot.brain.data.channels[res.message.room] and robot.brain.data.ADMINS[res.message.user.name]
      robot.brain.data.channels[res.message.room] = new Channel res.message.room
      res.send "Thanks " + res.message.user.name + " glad to be here! :bowtie:"

  # remove current channel from allowed robot.brain.data.channels.
  robot.respond /channel shush/i, (res) ->
    if robot.brain.data.channels[res.message.room] and robot.brain.data.ADMINS[res.message.user.name]
      res.send "OK " + res.message.user.name + " , I won't post here anymore. :disappointed:"
      delete robot.brain.data.channels[res.message.room]

  # list allowed channels
  robot.respond /where you at?/i, (res) ->
    if robot.brain.data.channels[res.message.room] and robot.brain.data.ADMINS[res.message.user.name]
      for n of robot.brain.data.channels
        res.send robot.brain.data.channels[res.message.room].name

  #count lines in the current channel.
  robot.hear /(.*)/i, (res) ->
    if robot.brain.data.channels[res.message.room]
      robot.brain.data.channels[res.message.room].lineCount++

  # list trigger response pairs
  robot.respond /triggers list/i, (res) ->
    if robot.brain.data.channels[res.message.room] and robot.brain.data.ADMINS[res.message.user.name]
      for n of robot.brain.data.responses
        res.send "\nName: " + robot.brain.data.responses[n].name + "\n--Triggers: " + robot.brain.data.responses[n].triggers + "\n--Responses: " + robot.brain.data.responses[n].response

  # create new set of triggers with common response
  robot.respond /triggers new (.*); (.*); (.*)/i, (res) ->
    if robot.brain.data.channels[res.message.room] and robot.brain.data.ADMINS[res.message.user.name]
      robot.brain.data.responses[res.match[1]] = new Response res.match[1]
      robot.brain.data.responses[res.match[1]].triggers = res.match[2].toLowerCase().split ","
      robot.brain.data.responses[res.match[1]].response = res.match[3]
      #robot.brain.data.responses[res.match[1]].triggers = robot.brain.data.responses[res.match[1]].triggers
      res.send "\nFor these trigger words:\n" + robot.brain.data.responses[res.match[1]].triggers + "\nThe following response has been added:"

  # change response for a set of triggers
  robot.respond /triggers change response (.*); (.*)/i, (res) ->
    if robot.brain.data.ADMINS[res.message.user.name]
      robot.brain.data.responses[res.match[1]].response = res.match[2]
      res.send res.match[1] + " response changed to:\n"

  # change triggers for a repsonse
  robot.respond /triggers change triggers (.*); (.*)/i, (res) ->
    if robot.brain.data.ADMINS[res.message.user.name]
      robot.brain.data.responses[res.match[1]].triggers = res.match[2].split ","
      res.send res.match[1] + " triggers changed to:\n" + robot.brain.data.responses[res.match[1]].triggers

  # remove a set of triggers and their response
  robot.respond /triggers remove (.*)/i, (res) ->
    if robot.brain.data.channels[res.message.room] and robot.brain.data.ADMINS[res.message.user.name]
      res.send "Trigger-response pair [" + robot.brain.data.responses[res.match[1]].name + "] removed."
      delete robot.brain.data.responses[res.match[1]]

  # respond when corresponding trigger is heard.
  robot.hear /(.*)/i, (res) ->
    # check if robot.brain.data.responses are allowed in this channel,
    if robot.brain.data.channels[res.message.room]
      # get current time, -0 becasue otherwise 'new Date()' returns a string.
      robot.brain.data.channels[res.message.room].timeNow = new Date() - 0
    for comm of robot.brain.data.responses
      #res.send robot.brain.data.responses[comm][res.message.room]
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
