type EventType =
  String

pub type WebhookEvent {
  VerificationEvent(event_type: EventType, challenge: String)
}
