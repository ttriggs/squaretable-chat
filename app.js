
var express = require('express');
var app = express();
var server = require('http').createServer(app);
var io = require('socket.io')(server);
var redis = require('redis');
var redisClient = redis.createClient();
var port = 8080;

server.listen(port, function () {
  console.log('Server listening at port %d', port);
});

// Routing
app.use(express.static(__dirname + '/public'));


io.on('connection', function(socket) {
  console.log('new connection!');
  var addedUser = false;

  socket.on('add user', function (username) {
    socket.username = username;
    addedUser = true;
    socket.emit('login', username)
    console.log("server: USERNAME ENTERED: " + username)
  });

  socket.on('new message', function (data) {
    // we tell the client to execute 'new message'
    socket.broadcast.emit('new message', {
      username: socket.username,
      message: data
    });
  });



});



//   client.on('join', function(name) {
//     client.nickname = name;
//     client.broadcast.emit("chat", name + " joined ze chat");
//     // show any old messages
//     // messages.forEach(function(message) {
//     //   client.emit("messages", message.name + ": " + message.data);
//     // });
//   });

//   // client.on('messages', function(data) {
//   //   var nickname = client.nickname;
//   //   client.broadcast.emit("message", nickname + ": "+ message); // for them
//   //   client.emit("messages", nickname + ": " + message); // for me
//   //   storeMessage(name, message);
//   // });
