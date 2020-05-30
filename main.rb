require 'discordrb'
require 'json'
require './signup'

config = JSON.parse(File.read 'config.json')
bot = Discordrb::Bot.new token: config['bot_token']
signup = SignupData.new(config)

bot.member_join do |event| 
  event.user.dm config["join_message"]

  check = "#{event.user.username}##{event.user.discriminator}"
  name = signup.name_from_discord check

  if name
    role = event.server.roles.select { |role| role.id == config["member_role"] }

    event.user.add_role role
    event.user.nickname = name

  end
end

bot.ready do |event| 
  bot.dnd
  bot.game = 'with illusions'
end

at_exit do
  bot.stop
end

bot.run
