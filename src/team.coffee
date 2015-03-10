# Description:
#   Create a team using hubot
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_TEAM_ADMIN - A comma separate list of user names
#
# Commands:
#   hubot create <team_name> team - create team called <team_name>
#   hubot (delete|remove) <team_name> team - delete team called <team_name>
#   hubot list teams - list all existing teams
#   hubot (<team_name>) team +1 - add me to the team
#   hubot (<team_name>) team -1 - remove me from the team
#   hubot (<team_name>) team add (me|<user>) - add me or <user> to team
#   hubot (<team_name>) team remove (me|<user>) - remove me or <user> from team
#   hubot (<team_name>) team count - list the current size of the team
#   hubot (<team_name>) team (list|show) - list the people in the team
#   hubot (<team_name>) team (empty|clear) - clear team list
#
# Author:
#   mihai

Config          = require './models/config'
Team            = require './models/team'
responseMessage = require './helpers/response_message'
UserNormalizer  = require './helpers/user_normalizer'

module.exports = (robot) ->
  robot.brain.data.teams or= {}
  Team.robot = robot

  unless Config.adminList()
    robot.logger.warning 'HUBOT_TEAM_ADMIN environment variable not set'

  ##
  ## hubot create <team_name> team - create team called <team_name>
  ##
  robot.respond /create (\S*) team ?.*/i, (msg) ->
    teamName = msg.match[1]
    message = if team = Team.create teamName
                responseMessage.teamCreated(team)
              else
                responseMessage.teamAlreadyExists(teamName)
    msg.send message

  ##
  ## hubot (delete|remove) <team_name> team - delete team called <team_name>
  ##
  robot.respond /(delete|remove) (\S*) team ?.*/i, (msg) ->
    teamName = msg.match[2]
    return msg.reply responseMessage.adminRequired() unless msg.message.user.name in Config.admins()
    message = if Team.destroy(teamName)
                responseMessage.teamDeleted(teamName)
              else
                responseMessage.teamNotFound(teamName)
    msg.send message


  ##
  ## hubot list teams - list all existing teams
  ##
  robot.respond /list teams ?.*/i, (msg) ->
    teams = Team.all()
    msg.send responseMessage.listTeams(teams)

  ##
  ## hubot <team_name> team add (me|<user>) - add me or <user> to team
  ##
  robot.respond /(\S*)? team add (\S*) ?.*/i, (msg) ->
    teamName  = msg.match[1]
    team      = if teamName
                  Team.find(teamName)
                else
                  Team.default()
    return msg.send responseMessage.teamNotFound(teamName) unless team
    user = UserNormalizer.normalize(msg.message.user.name, msg.match[2])
    message = if team.addMember user
                responseMessage.memberAddedToTeam(user, team)
              else
                responseMessage.memberAlreadyAddedToTeam(user, team)
    msg.send message

  ##
  ## hubot <team_name> team +1 - add me to the team
  ##
  robot.respond /(\S*)? team \+1 ?.*/i, (msg) ->
    teamName  = msg.match[1]
    team      = if teamName
                  Team.find(teamName)
                else
                  Team.default()
    return msg.send responseMessage.teamNotFound(teamName) unless team
    user = UserNormalizer.normalize(msg.message.user.name)
    message = if team.addMember user
                responseMessage.memberAddedToTeam(user, team)
              else
                responseMessage.memberAlreadyAddedToTeam(user, team)
    msg.send message

  ##
  ## hubot <team_name> team remove (me|<user>) - remove me or <user> from team
  ##
  robot.respond /(\S*)? team remove (\S*) ?.*/i, (msg) ->
    teamName  = msg.match[1]
    team      = if teamName
                  Team.find(teamName)
                else
                  Team.default()
    return msg.send responseMessage.teamNotFound(teamName) unless team
    user = UserNormalizer.normalize(msg.message.user.name, msg.match[2])
    message = if team.removeMember user
                responseMessage.memberRemovedFromTeam(user, team)
              else
                responseMessage.memberAlreadyOutOfTeam(user, team)
    msg.send message

  ##
  ## hubot <team_name> team -1 - remove me from the team
  ##
  robot.respond /(\S*)? team -1/i, (msg) ->
    teamName  = msg.match[1]
    team      = if teamName
                  Team.find(teamName)
                else
                  Team.default()
    return msg.send responseMessage.teamNotFound(teamName) unless team
    user = UserNormalizer.normalize(msg.message.user.name)
    message = if team.removeMember user
                responseMessage.memberRemovedFromTeam(user, team)
              else
                responseMessage.memberAlreadyOutOfTeam(user, team)
    msg.send message

  ##
  ## hubot <team_name> team count - list the current size of the team
  ##
  robot.respond /(\S*)? team count$/i, (msg) ->
    teamName  = msg.match[1]
    team      = if teamName
                  Team.find(teamName)
                else
                  Team.default()
    message = if team
                responseMessage.teamCount(team)
              else
                responseMessage.teamNotFound(teamName)
    msg.send message

  ##
  ## hubot <team_name> team (list|show) - list the people in the team
  ##
  robot.respond /(\S*)? team (list|show)$/i, (msg) ->
    teamName  = msg.match[1]
    team      = if teamName
                  Team.find teamName
                else
                  Team.default()
    message = if team
                responseMessage.listTeam(team)
              else
                responseMessage.teamNotFound(teamName)
    msg.send message

  ##
  ## hubot <team_name> team (empty|clear) - clear team list
  ##
  robot.respond /(\S*)? team (clear|empty)$/i, (msg) ->
    teamName  = msg.match[1]
    team      = if teamName
                  Team.find teamName
                else
                  Team.default()
    return msg.reply responseMessage.adminRequired() unless msg.message.user.name in Config.admins()
    team.clear()
    msg.send responseMessage.teamCleared(team)
