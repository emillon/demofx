start = ->
  canvas = document.createElement 'canvas'
  canvas.height = 1024
  canvas.width = 1024
  div = document.getElementById 'app'
  div.appendChild canvas
  ctx = canvas.getContext '2d'
  fire = new Fire ctx
