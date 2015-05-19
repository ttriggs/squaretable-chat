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
  $usernameInput = $('.usernameInput')
  $messages = $('.messages')
  $inputMessage = $('.inputMessage')

  $loginPage = $('.login.page')
  $chatPage = $('.chat.page')

  connected = false
  username = null
  $currentInput = $usernameInput.focus()

  socket = io()

  # Keyboard events
  $window.keydown (event) ->
    # Auto-focus the current input when a key is typed
    if (!(event.ctrlKey || event.metaKey || event.altKey))
      $currentInput.focus()
    # When the client hits ENTER on their keyboard
    if event.which is 13
      if username
        sendMessage()
      else
        setUsername()

  setUsername = ->
    username = cleanInput($usernameInput.val().trim())
    if username?
      $loginPage.fadeOut()
      $chatPage.show()
      $loginPage.off('click')
      $currentInput = $inputMessage.focus()
      socket.emit('add user', username)

  sendMessage = ->
    message = cleanInput($inputMessage.val())
    if (message && connected)
      $inputMessage.val('')
      socket.emit('new message', message)
      addChatMessage
        username: username
        message: message

  log = (message, options) ->
    $el = $('<li>').addClass('log').text(message)
    addMessageElement($el, options)

  addChatMessage = (data, options) ->

    userColor = getUsernameColor(data.username)
    $usernameDiv = $('<span class="username"/>')
      .text(data.username)
      .css('color', userColor)
    $messageBodyDiv = $('<span class="messageBody">')
      .text(data.message)
    $messageDiv = $('<li class="message"/>')
      .data('username', data.username)
      .addClass("")
      .append($usernameDiv, $messageBodyDiv)
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
  getUsernameColor = (name) ->
    hash = 7
    for i in [0...name.length]
      hash = name.charCodeAt(i) + (hash << 5) - hash
    index = Math.abs(hash % COLORS.length)
    COLORS[index]

  # Prevents input from having injected markup
  cleanInput = (input) ->
    $('<div/>').text(input).text()

  # socket events
  socket.on 'login', (username) ->
    connected = true

  socket.on 'new message', (data, options) ->
    addChatMessage(data, options)

  socket.on 'announcement', (message) ->
    log(message)
