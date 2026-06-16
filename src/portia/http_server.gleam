import logging
import mist
import portia/http_server/router

pub fn supervised() {
  logging.configure()
  logging.set_level(logging.Debug)

  router.routes()
  |> mist.new()
  |> mist.bind("0.0.0.0")
  |> mist.port(8080)
  |> mist.supervised()
}
