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
        if window.location.hash == ''
          defaultFX = 'cube'
          window.location.hash = '#' + defaultFX

      onHashChange: =>
        name = window.location.hash.substring 1
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
        ctor = @ctors[name]
        @fx = ctor @ctx

      loadDoc: (hash) ->
        @iframe.src = "docs/#{hash}.html"
