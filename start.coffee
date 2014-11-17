start = ->
  div = document.getElementById 'app'
  xsize = 640
  ysize = 480
  app = new App div, xsize, ysize
  app.addEffect 'fire', (ctx) ->
    new Fire ctx, xsize, ysize
  app.addEffect 'starfield', (ctx) ->
    new Starfield ctx, xsize, ysize
  app.start()
