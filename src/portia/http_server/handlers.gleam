import gleam/bytes_tree
import gleam/dynamic/decode
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/result
import mist.{type Connection, type ResponseData}
import portia/types.{VerificationEvent}

pub fn echo_handler(req: Request(Connection)) -> Response(ResponseData) {
  let content_type =
    req
    |> request.get_header("content-type")
    |> result.unwrap("text/plain")

  mist.read_body(req, 1024 * 1024 * 10)
  |> result.map(fn(req) {
    response.new(200)
    |> response.set_body(mist.Bytes(bytes_tree.from_bit_array(req.body)))
    |> response.set_header("content-type", content_type)
  })
  |> result.lazy_unwrap(fn() {
    response.new(400)
    |> response.set_body(mist.Bytes(bytes_tree.new()))
  })
}

pub fn ping_handler(_request: Request(Connection)) -> Response(ResponseData) {
  response.new(200)
  |> response.set_header("content-type", "text/plain")
  |> response.set_body(mist.Bytes(bytes_tree.from_string("pong")))
}

pub fn replicant_hook_handler(
  req: Request(Connection),
) -> Response(ResponseData) {
  let empty_response =
    response.new(400)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  let base_event_decoder = {
    use event_type <- decode.field("type", decode.string)
    decode.success(VerificationEvent(event_type:, challenge: ""))
  }

  req
  |> mist.read_body(1024 * 1024 * 10)
  |> result.map(fn(req) {
    json.parse_bits(from: req.body, using: base_event_decoder)
    |> result.map(fn(event) {
      case event.event_type {
        "webhook_verification" -> {
          let verification_decoder = {
            use challenge <- decode.field("challenge", decode.string)
            decode.success(VerificationEvent(..event, challenge:))
          }

          json.parse_bits(from: req.body, using: verification_decoder)
          |> result.map(fn(event) {
            let body = {
              json.object([
                #("challenge", json.string(event.challenge)),
              ])
            }

            response.new(200)
            |> response.set_body(
              mist.Bytes(bytes_tree.from_string(json.to_string(body))),
            )
          })
          |> result.unwrap(empty_response)
        }

        _ -> empty_response
      }
    })
    |> result.unwrap(empty_response)
  })
  |> result.unwrap(empty_response)
}
