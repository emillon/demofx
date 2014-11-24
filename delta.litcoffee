I saw a piece named [delta] the other day, and I would like to recreate it (or
at least, an impression of it) in the browser.

Visually, this piece is a red rectangle on which white rectangles "zoom" in.
This comes with an audio effect known as a [Shepard tone][shepardtone]. The
tones are in sync with the rectangles zooming in.

[delta]: http://www.ratsi.com/works/echolyse/delta/
[shepardtone]: https://en.wikipedia.org/wiki/Shepard_tone

A few words on the instance variables:

  - `@rects` contains the relative sizes of the rectangles. 1 is a full-frame
    rectangle.
  - `@accel` is the amount it will be multiplicated by at every frame.
  - `@audioCtx` is the Web Audio context.
  - `@tones` is an array containing couples of (oscillator node, gain node).
  - `@phase` is an animation phase, between 0 and 1. When a rectangle hits the
    border, it is approximately 1 and will reset to 0.
  - `@overlap` is the number of active tones at a given time.
  - `@freqStart` and `@freqEnd` are extreme frequencies. When oscillators have
    this frequency, their gain is 0.
  - `@drawDebug` defines whether to draw debug information (frequencies and
    gains: hit a key and it should be displayed on the screen).

    class Delta
      constructor: (@ctx, @xsize, @ysize) ->
        @request = window.requestAnimationFrame @drawFrame
        @rects = (0.05 ** (i / 9) for i in [1..18])
        @accel = 1 + 0.001
        @audioCtx = new AudioContext()
        @tones = []
        @phase = 0
        @overlap = 4
        @freqStart = 55
        @freqEnd = 220
        @drawDebug = false
        document.onkeydown = =>
          @drawDebug = true
        document.onkeyup = =>
          @drawDebug = false

      stop: ->
        window.cancelAnimationFrame @request
        @request = undefined
        for [osc, _] in @tones
          osc.stop()
        document.onkeydown = undefined
        document.onkeyup = undefined

The Web Audio API is quite straightforward: you create nodes, connect them
together, et voilà. Here, every oscillator node is connected to a gain node.
Here, multiple gain nodes are connected to the same output node
`@audioCtx.destination`. In that case, the inputs are mixed together.

      startTone: ([osc, gain]) ->
        osc.start()
        gain.connect @audioCtx.destination

      stopTone: ([osc, gain]) ->
        osc.stop()

      newTone: ->
        osc = @audioCtx.createOscillator()
        gain = @audioCtx.createGain()
        osc.type = 'triangle'
        osc.connect gain
        tone = [osc, gain]
        freq = @freqStart
        osc.frequency.value = freq
        gain.gain.value = 0
        return [osc, gain]

The frame drawing code is very much like the starfield effect: we keep track of
an array of rectangles that grow in an exponential fashion.

      drawFrame: =>
        @request = window.requestAnimationFrame @drawFrame

        @ctx.fillStyle = "red"
        @ctx.fillRect 0, 0, @xsize, @ysize

        @ctx.strokeStyle = "white"
        for size, i in @rects
          @drawRect size
          size *= @accel
          if size >= 1
            size = 0.05
            @updateTones()
          @rects[i] = size

        @phase += 3 * (Math.log @accel)
        for tone, i in @tones
          @adjustTone tone, i

      drawRect: (size) ->
        lw = 10 * size
        @ctx.lineWidth = lw
        xs = size * @xsize
        ys = size * @ysize
        x = (@xsize - xs) / 2
        y = (@ysize - ys) / 2
        @ctx.strokeRect x, y, xs, ys

This function is called whenever a rectangle hits the border. We either create a
new oscillator, or put the most ancient one in head position. Its frequency will
be automatically adusted.

      updateTones: ->
        @phase = 0
        if @tones.length >= @overlap
          tone = @tones.pop()
          @tones.unshift tone
        else
          tone = @newTone()
          @startTone tone
          @tones.unshift tone

This is called at every frame to adjust parameters of every tone with respect to
`@phase`. The thing is, `@phase` is common to every tone, so we have to map it
to a tone-local `phi` (still between 0 and 1) first.

      adjustTone: ([osc, gain], i) ->
        phi = (i + @phase) / @overlap

        g = 0.5 - 0.5 * Math.cos(phi * 2 * Math.PI)
        gain.gain.value = g
        freq = @freqStart + phi * (@freqEnd - @freqStart)
        osc.frequency.value = freq

        if @drawDebug
          x = @freqStart / 2
          @ctx.fillStyle = "green"
          @ctx.fillRect x, 0, ((@freqEnd - @freqStart) / 2), 10
          @ctx.fillRect x, (10 * (i + 1)), ((freq - @freqStart) / 2), 10

          x = 500
          @ctx.fillStyle = "blue"
          @ctx.fillRect x, 0, 100, 10
          @ctx.fillRect x, (10 * (i + 1)), (g * 100), 10
