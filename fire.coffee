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
    @lastCalledTime = Date.now()
    @fps = 0
    @fpsText = ''
    @drawFpsReady = false
    window.setInterval (=> @drawFpsReady = true), 1000

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
        index = (ydest * @xsize + x) * 4
        value = p
        rvalue = value
        gvalue = value
        bvalue = value
        avalue = 0xff
        @data[index + 0] = rvalue
        @data[index + 1] = gvalue
        @data[index + 2] = bvalue
        @data[index + 3] = avalue

    @ctx.putImageData @imageData, 0, 0
    @buffer1 = @buffer2
    @coolingOffset++

    now = Date.now()
    delta = (now - @lastCalledTime)/1000
    @lastCalledTime = now
    @fps = (1/delta).toFixed(1)
    if @drawFpsReady
      @fpsText = @fps
      @drawFpsReady = false
    @ctx.fillStyle = "red"
    @ctx.fillText @fpsText, 10, 10
