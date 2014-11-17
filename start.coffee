start = ->
  canvas = document.createElement 'canvas'
  xsize = 640
  ysize = 480
  canvas.width = xsize
  canvas.height = ysize
  div = document.getElementById 'app'
  ctx = canvas.getContext '2d'

  addLink = (name) ->
    link = document.createElement 'a'
    link.href = '#' + name
    link.textContent = name
    div.appendChild link

  addLink 'fire'
  addLink 'starfield'

  reloadHash = ->
    hash = window.location.hash or '#fire'
    switch hash
      when '#fire'
        fire = new Fire ctx, xsize, ysize
      when '#starfield'
        starfield = new Starfield ctx, xsize, ysize

  window.onhashchange = reloadHash
  reloadHash()

  div.appendChild canvas
