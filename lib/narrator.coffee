###
  This class handles all narration that occurs in the game
###
class Narrator
  constructor: ->
    @textbox = $( "<div id='narration-container'><div id='narration-textbox'></div></div>" ).appendTo 'body'
    @text = @textbox.children 'div#narration-textbox'
    @screen = $( window.renderer.domElement )
    @narrate "Press ENTER, N, SPACE or ESC to exit this message"
    $( window ).keydown bind(this, @onKeyDown)

  # Class function binds key event listeners to window
  # NOTE: we need to bind this separately from controls because
  # controls are frozen when player.freeze is true
  bind = (scope, fn) ->
    return ->
      fn.apply scope, arguments
      return

  onKeyDown: (event) ->
    switch event.keyCode
      when 13, 78, 27, 32 # ENTER, N, ESC
        @fadeOut()

  fadeOut: ->
    window.player.freeze = false
    @textbox.addClass 'exit'
    @screen.removeClass 'dark'
    return

  fadeIn: ->
    window.player.freeze = true
    @textbox.removeClass 'exit'
    @screen.addClass 'dark'
    return

  narrate: (message) ->
    @text.html message
    @fadeIn()
    return
