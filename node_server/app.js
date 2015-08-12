var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

var socket_map = {};

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

io.on('connection', function(socket){
  console.log('user: ' + socket.id + ' connected');

  io.to(socket.id).emit('server_message', 'welcome, tell me what\'s your name');

  socket_map[socket.id] = {}

  socket.on('disconnect', function(){
    console.log('user: ' + socket.id + ' disconnected');
    if(socket_map[socket.id]['room'])
    {
      io.to(socket_map[socket.id]['room']).emit('server_message', socket_map[socket.id]['name'] + ' have left room: ' + socket_map[socket.id]['room']);
    }
    delete socket_map[socket.id];
  });

  socket.on('client_message', function(msg){
    console.log('user: ' + socket.id + ' send message: ' + msg);
    var name;
    if(socket_map[socket.id]['name'] != null)
      name = socket_map[socket.id]['name'];
    else {
      io.to(socket.id).emit('server_message', 'you must set your name first');
      return;
    }

    if(socket_map[socket.id]['room'])
      io.to(socket_map[socket.id]['room']).emit('client_message', socket.id, name, msg);
    else
      io.to(socket.id).emit('server_message', 'you must enter someroom first');
  });

  socket.on('set_name', function(name){
    console.log('user: ' + socket.id + ' set name to: ' + name);
    socket_map[socket.id]['name'] = name;
    io.to(socket.id).emit('server_message', 'hello ' + name + ', which room would you want to enter?');
  });

  socket.on('set_room', function(room_name){
    console.log('user: ' + socket.id + ' called room_enter: ' + room_name);

    if(socket_map[socket.id]['name'] == null) {
      io.to(socket.id).emit('server_message', 'you must set your name first');
      return;
    };

    for (var i = socket.rooms.length - 1; i >= 0; i--) {
      var temp = socket.rooms[i];
      if (socket.rooms[i] != socket.id) {
        socket.leave(socket.rooms[i], function() {
          console.log('user: ' + socket.id + ' has left room: ' + temp);
        });
      }
    };

    socket.join(room_name, function(){
      console.log('user: ' + socket.id + ' has entered room: ' + room_name);
      io.to(room_name).emit('server_message', socket_map[socket.id]['name'] + ' have entered room: ' + room_name);
      socket_map[socket.id]['room'] = room_name;
    });
  });

  socket.on('init', function(){
    io.to(socket.id).emit('init', socket.id);
  });
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});
