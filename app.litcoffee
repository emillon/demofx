So we need some kind of player for these demo effects.

    class App
      constructor: (@div, @xsize, @ysize) ->
        @defaultFX = 'cube'
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
        aboutDiv = document.createElement 'div'
        aboutDiv.className = 'about'
        aboutDiv.textContent = "
        To see the different effects,
        please click on the 'Jump to'
        button in the top right corner.
        "
        demoDiv.appendChild aboutDiv
        @docDiv = document.createElement 'div'
        @docDiv.className = 'documentation'
        @iframe = document.createElement 'iframe'
        @iframe.src = 'about:blank'
        @div.appendChild @docDiv
        @docDiv.appendChild @iframe

Adding an effect just registers it into `@ctors`.

      addEffect: (name, ctor) ->
        @ctors[name] = ctor

Then, we have some bookkeeping to do to keep several things in sync:

  - the main URL's hash;
  - the fx running;
  - the documentation iframe;

When the hash changes, it is necessary to update the fx and the doc.
When the iframe changes (for example, if the user navigates to another page from
within the iframe), it is necessary to update the fx and the hash.

      start: ->
        window.onhashchange = @onHashChange
        @iframe.onload = @onIFrameLoad
        @onHashChange()

      onHashChange: =>
        hash = window.location.hash
        if hash == ''
          hash = '#' + @defaultFX
        name = hash.substring 1
        @changeFx name
        @loadDoc name

Since we will be updating the hash in this next function, it is not necessary to
explicitely call `@changeFx` from `@onIFrameLoad`.

      onIFrameLoad: =>
        last = (arr) ->
          arr[arr.length - 1]
        lastPath = last(@iframe.contentWindow.location.pathname.split('/'))
        name = lastPath.split('.')[0]
        window.location.hash = "#" + name

The following function replaces `@fx` with the correct effect instance.

      changeFx: (name) =>
        if @fx?
          @fx.stop()
        console.log name
        ctor = @ctors[name]
        @fx = ctor @ctx

      loadDoc: (hash) ->
        @iframe.src = "docs/#{hash}.html"
