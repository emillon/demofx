start = ->
  canvas = document.createElement 'canvas'
  xsize = 640
  ysize = 480
  canvas.width = xsize
  canvas.height = ysize
  div = document.getElementById 'app'
  div.appendChild canvas
  ctx = canvas.getContext '2d'
  fire = new Fire ctx, xsize, ysize
