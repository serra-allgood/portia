import gleam/bytes_tree
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/result
import mist.{type Connection, type ResponseData}
import portia/http_server/logging.{log_body}
import portia/webhook_events as events

pub fn replicant_hook_handler(
  req: Request(Connection),
) -> Response(ResponseData) {
  {
    use request_body <- result.try(read_body(req))
    use event <- result.map(events.get_event(request_body))
    let response_body = get_response_body(event)
    response.new(200)
    |> response.set_body(response_body)
  }
  |> result.lazy_unwrap(empty_response)
}

fn empty_response() {
  response.new(400)
  |> response.set_body(mist.Bytes(bytes_tree.new()))
}

fn get_response_body(event: events.Event) -> ResponseData {
  case event {
    events.VerificationEvent(challenge: challenge, ..) -> {
      json.object([
        #("challenge", json.string(challenge)),
      ])
      |> json.to_string()
      |> bytes_tree.from_string()
      |> mist.Bytes()
    }
    _ -> mist.Bytes(bytes_tree.new())
  }
}

fn read_body(req: Request(Connection)) -> Result(BitArray, events.EventError) {
  req
  |> mist.read_body(1024 * 1024 * 10)
  |> result.map(fn(req) { req.body })
  |> result.replace_error(events.UnknownEvent)
  |> result.try(log_body)
}
