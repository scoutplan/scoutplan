class FlipperMailInterceptor
  def self.delivering_email(message)
    message.perform_deliveries = Flipper.enabled?(:deliver_email)
  end
end
