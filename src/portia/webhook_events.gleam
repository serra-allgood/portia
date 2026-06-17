import gleam/dynamic/decode
import gleam/http/request.{type Request}
import gleam/json
import gleam/result

pub type EventError {
  UnknownEvent
}

type EventType =
  String

pub type Event {
  VerificationEvent(event_type: EventType, challenge: String)
  WebhookEvent(event_type: EventType)
}

pub fn get_event(body: BitArray) -> Result(Event, EventError) {
  use event <- result.try(parse_event(body))
  case event.event_type {
    "webhook_verification" -> {
      let challenge_decoder = {
        use challenge <- decode.field("challenge", decode.string)
        decode.success(VerificationEvent(
          event_type: event.event_type,
          challenge:,
        ))
      }
      json.parse_bits(from: body, using: challenge_decoder)
      |> result.replace_error(UnknownEvent)
    }
    _ -> Error(UnknownEvent)
  }
}

fn parse_event(body: BitArray) -> Result(Event, EventError) {
  let event_decoder = {
    use event_type <- decode.field("type", decode.string)
    decode.success(WebhookEvent(event_type:))
  }
  json.parse_bits(from: body, using: event_decoder)
  |> result.replace_error(UnknownEvent)
}
