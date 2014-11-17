Most of you will recognize starfields as "that futuristic Windows screensaver".
Not so futuristic in 2014, but still does the trick.

First, generate a few stars.

    class Starfield
      constructor: (@ctx, @xsize, @ysize) ->
        nstars = 200
        @stars = (@randomStar() for _ in [1..nstars])

        window.requestAnimationFrame @drawFrame

The stars here are uniformly distributed. This is nice for initial stars but a
bit awkward for later stars since they seem to pop from anywhere.

      randomStar: ->
        x = Math.floor (Math.random() * @xsize)
        y = Math.floor (Math.random() * @ysize)
        [x, y]

At every frame, we just draw the stars (1 white pixel each, the rest is black)
and call `@scatterStars`.

      drawFrame: =>
        window.requestAnimationFrame @drawFrame

        @ctx.fillStyle = "black"
        @ctx.fillRect 0, 0, @xsize, @ysize

        @ctx.fillStyle = "white"
        for [x, y] in @stars
          @ctx.fillRect x, y, 1, 1

        @scatterStars()

This next function pulls the stars away from the center.
The acceleration is proportional to the distance from the center, creating a
sort of tunnel effect.

      scatterStars: ->
        for [x, y], i in @stars
          accel = 0.01
          dx = accel * (x - (@xsize / 2))
          dy = accel * (y - (@ysize / 2))
          newStar = [x + dx, y + dy]
          if !@inbounds newStar
            newStar = @randomStar()
          @stars[i] = newStar

When a star is not inbounds any more, it gets replaced by a new one.
The circle of life.

      inbounds: ([x, y]) ->
        (0 <= x) and (x < @xsize) and (0 <= y) and (y < @xsize)
