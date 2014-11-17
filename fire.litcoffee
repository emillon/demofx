The fire effect is perhaps the most recognizable demo effect. With it you can
make burning letters, burning skulls, burning whatever.

This effect can be seen as a simple cellular automaton: the temperature of every
cell (pixel) is directly based on the temperature of its neighbours. Of course,
this is not enough, or otherwise the effect will quickly converge to an array of
tepid pixels.

This one is largely inspired from the description that can be found on [Hugo
Elias' website](http://freespace.virgin.net/hugo.elias/models/m_fire.htm).

    class Fire
      constructor: (@ctx, @xsize, @ysize) ->

We need to use several buffers here:

  - `@buffer1` is the current temperature;
  - `@buffer2` is temperature we're computing (it's not possible to do it in a
    single pass, like in the game of life);
  - `@cooling` is a cooling map, that is to say the intensity with which the
    temperature will be adjusted.

        @buffer1 = @makeBuffer()
        @buffer2 = @makeBuffer()
        @cooling = @makeBuffer()

To manipulate the canvas' context, it is possible to use the normal underlying
uint8, but I found it faster to use a typed uint32 array (and
[jsperf](http://jsperf.com/canvas-pixel-manipulation) agrees). So, we define an
`ArrayBuffer` and two views on this buffer: `@buf8` for 8-bit access, and
`@data` for 32-bit access. These variables alias the same underlying memory: we
will fill `@data` and copy back using `@buf8`.

        @imageData = ctx.getImageData 0, 0, @xsize, @ysize
        buf = new ArrayBuffer @imageData.data.length
        @buf8 = new Uint8ClampedArray buf
        @data = new Uint32Array buf

Next we prepare the cooling buffer to contain random data, but no so random.
More on this later.

        @coolingOffset = 0
        @prepareCoolingBuffer()

Prepare a FPS counter that will update its text every second.

        @fpsCounter = new FpsCounter 1000
        @fpsCounter.start()

Finally, register the `@drawFrame` callback.

        window.requestAnimationFrame @drawFrame

      makeBuffer: ->
        buf = new Array @xsize
        for x in [0 .. @xsize - 1]
          buf[x] = new Array @ysize
          for y in [0 .. @ysize - 1]
            buf[x][y] = 0

      prepareCoolingBuffer: ->
        smooth = (buf) =>
          newBuf = @makeBuffer()
          for x in [1 .. @xsize - 2]
            for y in [1 .. @ysize - 2]
              v = 0
              for dx in [-1 .. 1]
                for dy in [-1 .. 1]
                  v += buf[x + dx][y + dy]
              v /= 9
              newBuf[x][y] = v
          return newBuf

        randomIntFromInterval = (min, max) ->
            Math.floor (Math.random()*(max-min+1)+min)

        for i in [1..1000]
          x = randomIntFromInterval 1, (@xsize - 2)
          y = randomIntFromInterval 1, (@ysize - 2)
          v = randomIntFromInterval 0, 0xff
          @cooling[x][y] = v
        for i in [1..50]
          @cooling = smooth @cooling

      drawFrame: =>
        window.requestAnimationFrame @drawFrame
        for y in [@ysize - 3 .. @ysize - 1]
          for x in [0 .. @xsize - 1]
            @buffer1[x][y] = 0x80

        for y in [1 .. @ysize - 2]
          for x in [1 .. @xsize - 2]
            n1 = @buffer1[x+1][y]
            n2 = @buffer1[x-1][y]
            n3 = @buffer1[x][y+1]
            n4 = @buffer1[x][y-1]

            c = @cooling[x][(y+@coolingOffset) % @ysize]
            p = (n1+n2+n3+n4) / 4
            p = p - c
            if p < 0
              p = 0

            ydest = y - 1
            @buffer2[x][ydest] = p
            index = (ydest * @xsize + x)
            value = p
            rvalue = value
            gvalue = value
            bvalue = value
            avalue = 0xff
            @data[index] = (rvalue) | (gvalue << 8) | (bvalue << 16) | (avalue << 24)

        @imageData.data.set @buf8
        @ctx.putImageData @imageData, 0, 0
        @buffer1 = @buffer2
        @coolingOffset++

        fpsText = @fpsCounter.tick()
        @ctx.fillStyle = "red"
        @ctx.fillText fpsText, 10, 10
