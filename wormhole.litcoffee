    class Wormhole
      constructor: (@ctx, @xsize, @ysize) ->
        @spokes = 1600
        @divs = @spokes / 2

        @dx = 0
        @dy = 0

        @spokeCosCalc = new Array @spokes
        @spokeSinCalc = new Array @spokes
        @initTables()

        @imageData = @ctx.getImageData 0, 0, @xsize, @ysize
        buf = new ArrayBuffer @imageData.data.length
        @buf8 = new Uint8ClampedArray buf
        @data = new Uint32Array buf

        @fpsCounter = new FpsCounter 1000
        @fpsCounter.start()

        @request = window.requestAnimationFrame @drawFrame

      initTables: ->
        for i in [0 .. @spokes - 1]
          sc = 2 * Math.PI * i / @spokes
          @spokeCosCalc[i] = Math.cos sc
          @spokeSinCalc[i] = Math.sin sc

      stop: ->
        @fpsCounter.stop()
        window.cancelAnimationFrame @request
        @request = undefined

      drawFrame: =>
        @request = window.requestAnimationFrame @drawFrame

        @ctx.fillStyle = "black"
        @ctx.fillRect 0, 0, @xsize, @ysize

        @dx = (@dx + 1) % 40
        @dy = (@dy + 1) % 40

        xcenter = 5 * @xsize / 8
        ycenter = @ysize / 4

        for _, i in @data
          @data[i] = 0xff000000

        for j in [0 .. @divs - 1]
          z = -1.0 + Math.log(2.0 * j / @divs)
          divCalcX = @xsize * j / @divs
          divCalcY = @ysize * j / @divs
          for i in [0 .. @spokes - 1]
            x = divCalcX * @spokeCosCalc[i]
            y = divCalcY * @spokeSinCalc[i]

            # this creates the downward curve in the center
            y = y - 25 * z

            # start circling outwards from center
            x += xcenter
            y += ycenter

            x |= 0
            y |= 0

            # only place pixels within the range of the wormImg resolution
            if (0 <= x) && (x < @xsize) && (0 <= y) && (y < @ysize)
              texturex = ((i / 8) % 40) | 0
              texturey = ((j / 6) % 40) | 0
              index = y * @xsize + x
              if (texturex % 20 == @dx % 20) || (texturey % 20 == @dy % 20)
                @data[index] = 0xffffffff

        @imageData.data.set @buf8
        @ctx.putImageData @imageData, 0, 0

        fpsText = @fpsCounter.tick()
        @ctx.fillStyle = "red"
        @ctx.fillText fpsText, 10, 10
