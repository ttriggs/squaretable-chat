$ ->
  FADE_TIME = 150
  TYPING_TIMER_LENGTH = 400
  COLORS = [
    '#e21400', '#91580f', '#f8a700', '#f78b00',
    '#58dc00', '#287b00', '#a8f07a', '#4ae8c4',
    '#3b88eb', '#3824aa', '#a700ff', '#d300e7'
  ]

  # Initialize varibles
  $window = $(window)
  $usernameInput = $('.usernameInput') # Input for username
  $messages = $('.messages') # Messages area
  $inputMessage = $('.inputMessage') # Input message input box

  $loginPage = $('.login.page') # The login page
  $chatPage = $('.chat.page') # The chatroom page

  # Prompt for setting a username
  connected = false
  username = null
  $currentInput = $usernameInput.focus()

  socket = io()
  # Sets the clients username

  # Keyboard events
  $window.keydown (event) ->
    # Auto-focus the current input when a key is typed
    if (!(event.ctrlKey || event.metaKey || event.altKey))
      $currentInput.focus()
    # When the client hits ENTER on their keyboard
    if event.which is 13
      if username
        sendMessage()
        # socket.emit('stop typing')
        # typing = false
      else
        setUsername()

  setUsername = ->
    username = cleanInput($usernameInput.val().trim())
    console.log("client: USERNAME ENTERED: " + username)
    # If the username is valid
    if username?
      $loginPage.fadeOut()
      $chatPage.show()
      $loginPage.off('click')
      $currentInput = $inputMessage.focus()
      # Tell the server your username
      socket.emit('add user', username)

  # Sends a chat message
  sendMessage = ->
    # Prevent markup from being injected into the message
    message = cleanInput($inputMessage.val())
    console.log(username + " entered this message:" + message)
    # if there is a non-empty message and a server connection
    if (message && connected)
      $inputMessage.val('')
      addChatMessage
        username: username
        message: message
      # tell server to execute 'new message' and send along one parameter
      socket.emit('new message', message)

  # Log a message
  log = (message, options) ->
    $el = $('<li>').addClass('log').text(message)
    addMessageElement($el, options)

  # Adds the visual chat message to the message list
  addChatMessage = (data, options) ->
    $usernameDiv = $('<span class="username"/>')
      .text(data.username)
      .css('color', getUsernameColor(data.username))

    console.log("usernameDiv: " + $usernameDiv)

    $messageBodyDiv = $('<span class="messageBody">')
      .text(data.message)

    console.log("messageBodyDiv: " + $messageBodyDiv)

    $messageDiv = $('<li class="message"/>')
      .data('username', data.username)
      .addClass("")
      .append($usernameDiv, $messageBodyDiv)

    console.log("messageDiv: " + $messageDiv)

    addMessageElement($messageDiv, options)

  addMessageElement = (el, options={}) ->
    $el = $(el)

    # Setup default options
    options.fade = true unless options.fade?
    options.prepend = false unless options.prepend?

    # Apply options
    $el.hide().fadeIn(FADE_TIME) if options.fade
    if options.prepend
      $messages.prepend($el)
    else
      $messages.append($el)
    $messages[0].scrollTop = $messages[0].scrollHeight

  # Gets the color of a username through our hash function
  getUsernameColor = (username) ->
    # Compute hash code
    hash = 7
    for i in [0...username.length]
      hash = username.charCodeAt(i) + (hash << 5) - hash
    index = Math.abs(hash % COLORS.length)
    debugger;
    COLORS[index]

  # Prevents input from having injected markup
  cleanInput = (input) ->
    $('<div/>').text(input).text()

  # socket events
  socket.on 'login', (username) ->
    connected = true
    console.log("client: user connected:" + username)

  # Whenever the server emits 'new message', update the chat body
  socket.on 'new message', (data) ->
    addChatMessage(data)
