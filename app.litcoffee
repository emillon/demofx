So we need some kind of player for these demo effects.

    class App
      constructor: (@div, @xsize, @ysize) ->
        canvas = document.createElement 'canvas'
        canvas.width = @xsize
        canvas.height = @ysize
        @ctx = canvas.getContext '2d'
        @div.appendChild canvas
        @fx = null

      addEffect: (name) ->
        link = document.createElement 'a'
        link.className = 'fxsel'
        link.href = '#' + name
        link.textContent = name
        @div.appendChild link

      start: ->
        window.onhashchange = @changeFx
        @changeFx()

      changeFx: =>
        if @fx?
          @fx.stop()
        hash = window.location.hash or '#fire'
        switch hash
          when '#fire'
            @fx = new Fire @ctx, @xsize, @ysize
          when '#starfield'
            @fx = new Starfield @ctx, @xsize, @ysize
