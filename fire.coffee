class Fire
  constructor: (@ctx, @xsize, @ysize) ->
    @buffer1 = @makeBuffer()
    @buffer2 = @makeBuffer()
    @cooling = @makeBuffer()
    @imageData = ctx.getImageData 0, 0, @xsize, @ysize
    @data = @imageData.data
    window.requestAnimationFrame @drawFrame
    @coolingOffset = 0
    @prepareCoolingBuffer()
    for y in [0 .. @ysize - 1]
      for x in [0 .. @xsize - 1]
        @putPixel @buffer1, x, y, 0x80

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
          @putPixel newBuf, x, y, v
      return newBuf

    randomIntFromInterval = (min, max) ->
        Math.floor (Math.random()*(max-min+1)+min)

    for i in [1..1000]
      x = randomIntFromInterval 1, (@xsize - 2)
      y = randomIntFromInterval 1, (@ysize - 2)
      v = randomIntFromInterval 0, 0xff
      @putPixel @cooling, x, y, v
    for i in [1..50]
      @cooling = smooth @cooling

  drawFrame: =>
    window.requestAnimationFrame @drawFrame

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
        @putPixel @buffer2, x, (y-1), p

    @putBuffer @buffer2
    @buffer2 = @buffer1
    @coolingOffset++

  putPixel: (buffer, x, y, v) ->
    buffer[x][y] = v

  putBuffer: (buffer) ->
    for y in [0 .. @ysize - 1]
      for x in [0 .. @xsize - 1]
        index = (y * @xsize + x) * 4
        value = buffer[x][y]
        rvalue = value
        gvalue = value
        bvalue = value
        avalue = 0xff
        @data[index + 0] = rvalue
        @data[index + 1] = gvalue
        @data[index + 2] = bvalue
        @data[index + 3] = avalue
    @ctx.putImageData @imageData, 0, 0
