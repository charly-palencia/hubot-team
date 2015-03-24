Team            = require './team'
ResponseMessage = require '../helpers/response_message'

class TeamManager
  @getTeam: (teamName)->
    if teamName then Team.get(teamName) else Team.getDefault()

  @teamCount: (teamName)->
    team = @getTeam teamName
    if team
      ResponseMessage.teamCount team
    else
      ResponseMessage.teamNotFound teamName

  @clearTeam: (teamName)->
    if team = @getTeam teamName
      team.clear()
      ResponseMessage.teamCleared(team)
    else
      ResponseMessage.teamNotFound(teamName)

  @listTeam: (teamName)->
    if team = @getTeam teamName
      ResponseMessage.listTeam team
    else
      ResponseMessage.teamNotFound teamName

  @addMemberToTeam: (member, teamName)->
    if team = @getTeam teamName
      isMemberAdded = team.addMember member
      if isMemberAdded
        ResponseMessage.memberAddedToTeam(member, team)
      else
        ResponseMessage.memberAlreadyAddedToTeam(member, team)
    else
      ResponseMessage.teamNotFound(teamName)

  @removeMemberFromTeam: (member, teamName)->
    if team = @getTeam teamName
      isMemberRemoved = team.removeMember member
      if isMemberRemoved
        message = ResponseMessage.memberRemovedFromTeam(member, team)
      else
        message = ResponseMessage.memberAlreadyOutOfTeam(member, team)
    else
      ResponseMessage.teamNotFound(teamName)

module.exports = TeamManager
