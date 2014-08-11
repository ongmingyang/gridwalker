###
  The UI class
###
class Interface
  constructor: (clones) ->
    @footer = $( "<div id='clones'></div>" ).appendTo 'body'
    @clones =
      reference: clones
      dom: {}
    dom = @clones.dom
    footer = @footer
    _.forOwn clones, (clone, key) ->
      dom[key] = $ "<div id='clone-#{key}' class='clone-icon'>#{clone.name}</div>"
      dom[key].appendTo footer
      return

    # Start off highlighting first clone
    @update 0

  update: (id) ->
    _.forOwn @clones.dom, (clone) ->
      clone.removeClass "clone-highlighted"
    @clones.dom[id].addClass "clone-highlighted"
    
