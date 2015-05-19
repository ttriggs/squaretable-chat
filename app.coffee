
express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io')(server)
redis = require('redis')
redisClient = redis.createClient()
port = 8080
max_messages = 10

server.listen port, () ->
  console.log('Server listening at port %d', port)

# Routing
app.use(express.static(__dirname + '/public'))

storeMessage = (username, message) ->
  data = JSON.stringify({
    username: username
    message: message
  })
  redisClient.lpush("messages", data, ->
    redisClient.ltrim("messages", 0, max_messages)
  )


io.on 'connection', (socket) ->
  addedUser = false
  showOldMessages = ->
    redisClient.lrange "messages", 0, -1, (err, messages) ->
      for message in messages.reverse()
        socket.emit("new message", JSON.parse(message))

  socket.on 'add user', (username) ->
    showOldMessages()
    socket.username = username
    redisClient.sadd("users", username);
    addedUser = true
    socket.emit('login', username)
    socket.broadcast.emit("announcement",
                          "#{socket.username} has joined the chat...")

  socket.on 'new message', (message) ->
    storeMessage(socket.username, message)
    socket.broadcast.emit 'new message',
      { username: socket.username, message: message }

  socket.on 'disconnect', (username) ->
    if socket.username
      socket.broadcast.emit("announcement",
                            "#{socket.username} has left the chat...")
      redisClient.srem("users", socket.username)
