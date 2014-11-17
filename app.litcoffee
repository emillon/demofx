So we need some kind of player for these demo effects.

    class App
      constructor: (@div, @xsize, @ysize) ->
        canvas = document.createElement 'canvas'
        canvas.width = @xsize
        canvas.height = @ysize
        @ctx = canvas.getContext '2d'
        @div.appendChild canvas
        @fx = null
        @ctors = {}

Adding an effect has two... effects.
First, it creates a link which links to a URL fragment.
And it registers it into `@ctors`.

      addEffect: (name, ctor) ->
        link = document.createElement 'a'
        link.className = 'fxsel'
        link.href = '#' + name
        link.textContent = name
        @ctors[name] = ctor
        @div.appendChild link

      start: ->
        window.onhashchange = @changeFx
        @changeFx()

The following function is called on two occasions: at start, and whenever the
hash changes (ie, when a '#name' link is clicked). It replaces `@fx` with the
correct effect instance.

      changeFx: =>
        if @fx?
          @fx.stop()
        hash = window.location.hash.substring 1 or 'fire'
        ctor = @ctors[hash]
        @fx = ctor @ctx
