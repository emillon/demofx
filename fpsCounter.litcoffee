We need a way to display FPS data. Nothing is magic there: every time a frame is
drawn, we compare the time since last time and we get FPS. However, if we draw
the FPS number at every frame it moves too fast. So, it is necessary to throttle
it.

    class FpsCounter

      constructor: (@updateMillis) ->
        @lastCalledTime = Date.now()
        @fps = 0
        @fpsText = ''
        @drawFpsReady = false

These variables work in the following way: every `updateMillis`,
`@drawFpsCounter` is set to `true`, and at that time `@fps` is copied into
`@fpsText`.

      start: ->
        @interval = window.setInterval (=> @drawFpsReady = true), @updateMillis

      stop: ->
        window.clearInterval @interval
        @interval = undefined

The `tick` method is called at every frame. It returns a text to be displayed at
every frame. It will changes only every `@updateMillis`.

      tick: ->
        now = Date.now()
        delta = (now - @lastCalledTime) / 1000
        @lastCalledTime = now
        @fps = (1 / delta).toFixed(1)
        if @drawFpsReady
          @fpsText = @fps
          @drawFpsReady = false
        return @fpsText
