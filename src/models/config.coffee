class Config
  @adminList = -> process.env.HUBOT_TEAM_ADMIN
  @admins = ->
    if @adminList()
      @adminList().split ','
    else
      []

module.exports = Config
