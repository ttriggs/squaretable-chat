
express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io')(server)
redis = require('redis')
redisClient = redis.createClient()
port = 8080

server.listen port, () ->
  console.log('Server listening at port %d', port)

# Routing
app.use(express.static(__dirname + '/public'))

io.on 'connection', (socket) ->
  console.log('new connection!')
  addedUser = false

  socket.on 'add user', (username) ->
    socket.username = username
    addedUser = true
    socket.emit('login', username)
    console.log("server: USERNAME ENTERED: " + username)

  socket.on 'new message', (data) ->
    socket.broadcast.emit 'new message', {
      username: socket.username, message: data
    }

