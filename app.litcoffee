So we need some kind of player for these demo effects.

    class App
      constructor: (@div, @xsize, @ysize) ->
        demoDiv = document.createElement 'div'
        demoDiv.className = 'demo'
        demoDiv.style.width = @xsize + 'px'
        @div.appendChild demoDiv
        canvas = document.createElement 'canvas'
        canvas.width = @xsize
        canvas.height = @ysize
        @ctx = canvas.getContext '2d'
        demoDiv.appendChild canvas
        @fx = null
        @ctors = {}
        @linkDiv = document.createElement 'div'
        demoDiv.appendChild @linkDiv
        @docDiv = document.createElement 'div'
        @docDiv.className = 'documentation'
        @iframe = document.createElement 'iframe'
        @iframe.src = 'about:blank'
        @div.appendChild @docDiv
        @docDiv.appendChild @iframe

Adding an effect has two... effects.
First, it creates a link which links to a URL fragment.
And it registers it into `@ctors`.

      addEffect: (name, ctor) ->
        link = document.createElement 'a'
        link.className = 'fxsel'
        link.href = '#' + name
        link.textContent = name
        @ctors[name] = ctor
        @linkDiv.appendChild link

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
        @loadDoc hash

Finally, when an effect is reloaded, update the documentation iframe.

      loadDoc: (hash) ->
        @iframe.src = "docs/#{hash}.html"
