start = ->
  div = document.getElementById 'app'
  app = new App div, 640, 480
  app.addEffect 'fire'
  app.addEffect 'starfield'
  app.start()
