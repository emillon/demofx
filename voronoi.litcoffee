Imagine you have a set of cities. You can divide the land in regions so that
when you live in a region, the capital city is the closest one to you. This is
the concept of Voronoï cells.

    class Voronoi
      constructor: (@ctx, @xsize, @ysize) ->
        @request = window.requestAnimationFrame @drawFrame
        nparticles = 10
        @particles = (@randomParticle() for _ in [1..nparticles])

      randomParticle: ->
        randomUniform = (min, max) ->
          Math.random() * (max - min) + min

        randomUniformInt = (min, max) ->
          Math.floor(randomUniform min, max)

        randomGaussian = ->
          u = ->
            randomUniform(-1, 1)
          Math.floor(u() + u() + u())

        p =
          x: randomUniformInt(0, @xsize)
          y: randomUniformInt(0, @ysize)
          vx: randomGaussian()
          vy: randomGaussian()
        p

      stop: ->
        window.cancelAnimationFrame @request

      drawFrame: =>
        @request = window.requestAnimationFrame @drawFrame
        @ctx.fillStyle = "white"
        @ctx.fillRect 0, 0, @xsize, @ysize

        @animateParticles()
        @drawParticles()

The first step is to animate particles.

      animateParticles: ->
        for particle in @particles
          @animateParticle particle

      animateParticle: (p) ->
        p.x += p.vx
        p.y += p.vy

        if p.x < 0
          p.x = 0
          p.vx = -p.vx
        if p.x >= @xsize
          p.x = @xsize - 1
          p.vx = -p.vx
        if p.y < 0
          p.y = 0
          p.vy = -p.vy
        if p.y >= @ysize
          p.y = @ysize - 1
          p.vy = -p.vy

Then we draw them.

      drawParticles: ->
        for particle in @particles
          @drawParticle particle

      drawParticle: (p) ->
        @ctx.fillStyle = "black"
        @ctx.fillRect p.x, p.y, 3, 3
