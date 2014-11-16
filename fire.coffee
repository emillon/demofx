class Fire
  constructor: (@ctx, @xsize, @ysize) ->
    @buffer1 = new Array @xsize
    @buffer2 = new Array @xsize
    for x in [0 .. @xsize - 1]
      @buffer1[x] = new Array @ysize
      @buffer2[x] = new Array @ysize
      for y in [0 .. @ysize - 1]
        @buffer1[x][y] = 0
        @buffer2[x][y] = 0
    @imageData = ctx.getImageData 0, 0, @xsize, @ysize
    @data = @imageData.data
    window.requestAnimationFrame @drawFrame
    @coolingOffset = 0
    for y in [0 .. @ysize - 1]
      for x in [0 .. @xsize - 1]
        @putPixel @buffer1, x, y, 0x80

  drawFrame: =>
    window.requestAnimationFrame @drawFrame

    for y in [1 .. @ysize - 2]
      for x in [1 .. @xsize - 2]
        n1 = @getPixel @buffer1, (x+1), y
        n2 = @getPixel @buffer1, (x-1), y
        n3 = @getPixel @buffer1, x, (y+1)
        n4 = @getPixel @buffer1, x, (y-1)

        c = @cooling x, y
        p = (n1+n2+n3+n4) / 4
        p = p - c
        if p < 0
          p = 0
        @putPixel @buffer2, x, (y-1), p

    @putBuffer @buffer2
    @buffer2 = @buffer1
    @coolingOffset++

  cooling: (x, ybase) ->
    y = ybase + @coolingOffset
    xok = (@xsize / 4 < x) and (x < @xsize / 2)
    yok = (@ysize / 4 < y) and (y < @ysize / 2)
    if xok and yok
      return 0
    else
      return 1

  getPixel: (buffer, x, y) ->
    buffer[x][y]

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
