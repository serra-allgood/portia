import gleam/bytes_tree
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import logging
import mist.{type Connection, type ResponseData}
import portia/http_server/handlers

pub fn routes() {
  let not_found =
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  fn(req: Request(Connection)) -> Response(ResponseData) {
    case mist.get_connection_info(req.body) {
      Ok(info) -> {
        logging.log(
          logging.Info,
          "Got a request from: " <> mist.connection_info_to_string(info),
        )
      }
      Error(_nil) -> {
        logging.log(logging.Info, "Failed to get connection info")
      }
    }
    case req.method, request.path_segments(req) {
      http.Post, ["echo"] -> handlers.echo_handler(req)
      http.Get, ["ping"] -> handlers.ping_handler(req)
      http.Post, ["replicant-hook"] -> handlers.replicant_hook_handler(req)

      _, _ -> not_found
    }
  }
}
