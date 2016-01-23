class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    email_hash = {from: @email.from[:full], to: @email.to, subject: @email.subject, body: @email.body, timestamp: Time.zone.now.to_s}
    ContactMailer.forwarding_email(email_hash, @email.attachments).deliver_later
  end
end
