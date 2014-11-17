The cube effect is just a rotating wireframe cube, without occlusion.

First, we define the points and edges of the cube.

    class Cube
      constructor: (@ctx, @xsize, @ysize) ->
        @request = window.requestAnimationFrame @drawFrame
        #      G ------- H
        #     /|        /|
        # y  / |       / |
        # ^ /  |   z  /  |
        # |/   |  /  /   |
        # E ------- F    |
        # |    |/   |    |
        # |    C ---|--- D
        # |   /     |   /
        # |  /      |  /
        # | /       | /
        # |/        |/
        # A ------- B --> x
        a = [-1,-1,-1]
        b = [+1,-1,-1]
        c = [-1,+1,-1]
        d = [+1,+1,-1]
        e = [-1,-1,+1]
        f = [+1,-1,+1]
        g = [-1,+1,+1]
        h = [+1,+1,+1]
        @edges = [ [a,b] , [a,c] , [b,d] , [c,d]
                 , [e,f] , [e,g] , [f,h] , [g,h]
                 , [a,e] , [b,f] , [c,g] , [d,h]
                 ]
        @frameNum = 0

      stop: ->
        window.cancelAnimationFrame @request
        @request = undefined

At every frame, we compute a new position. This path goes along a circle in
front of the cube.

      drawFrame: =>
        @request = window.requestAnimationFrame @drawFrame
        omega = 0.05
        @frameNum++
        position =
          x: 3 * Math.cos(omega * @frameNum)
          y: 3 * Math.sin(omega * @frameNum)
          z: -10
        @ctx.fillStyle = "black"
        @ctx.fillRect 0, 0, @xsize, @ysize

        @ctx.strokeStyle = "white"
        @ctx.beginPath()
        for [p1, p2] in @edges
          [x1, y1] = @threeToTwo p1, position
          [x2, y2] = @threeToTwo p2, position
          @ctx.moveTo x1, y1
          @ctx.lineTo x2, y2
        @ctx.stroke()

The magic happens in this function. It projects a three-dimensional point onto
the screen. It does this in a way such that the origin stays at the center of
the screen.

      threeToTwo: ([px, py, pz], position) ->
        x = position.x - px
        y = position.y - py
        z = position.z - pz

        zoom = Math.min @xsize, @ysize

        sx = zoom * (x / z - position.x / position.z) + @xsize / 2
        sy = zoom * (y / z - position.y / position.z) + @ysize / 2
        [sx, sy]
