class Team

  @robot = null

  @store: ->
    throw new Error('robot is not set up') unless @robot
    @robot.brain.data.teams or= {}

  @defaultName: ->
    '__default__'

  @all: ->
    teams = []
    for key, teamData of @store()
      continue if key is @defaultName()
      teams.push new Team(teamData.name, teamData.members)
    teams

  @default: (members = [])->
    unless @exists @defaultName()
      @create(@defaultName(), members)
    @find(@defaultName())

  @count: ->
    Object.keys(@store()).length

  @find: (name)->
    return false unless @exists name
    teamData = @store()[name]
    new Team(teamData.name, teamData.members)

  @exists: (name)->
    name of @store()

  @create: (name, members = [])->
    return false if @exists name
    @store()[name] =
      name: name
      members: members
    new Team(name, members)

  @destroy: (name)->
    return false unless @exists name
    delete @store()[name]

  constructor: (name, @members = [])->
    @name = name or Team.defaultName()

  addMember: (member)->
    return false if member in @members
    @members.push member

  removeMember: (member)->
    return false if member not in @members
    index = @members.indexOf(member)
    @members.splice(index, 1)
    true

  membersCount: ->
    @members.length

  clear: ->
    Team.store()[@name].members = []
    @members = []

  isDefault: ->
    @name is Team.defaultName()

  label: ->
    if @isDefault()
      'team'
    else
      "`#{@name}` team"

module.exports = Team
