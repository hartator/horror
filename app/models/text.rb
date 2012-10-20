class Text
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  @@account_sid = 'AC8ee2825d84eceade85287e59fe00071b'
  @@auth_token = 'xx'
  @@client = Twilio::REST::Client.new(@@account_sid, @@auth_token)
  @@account = @@client.account
  
  field :processed, type: Boolean, default: false
  
  def self.sync
    @@account.sms.messages.list.each do |sms|
      sms_hash = {body: sms.body, date_created: sms.date_created, date_sent: sms.date_sent, date_updated: sms.date_updated, direction: sms.direction, from: sms.from, to: sms.to}
      unless self.where(sms_hash).first
        create sms_hash.merge processed: false
      end
    end
  end
  
  def self.clear_session
    all(processed: false).each do |sms|
      sms.status = true
      sms.save
    end
  end
  
  def self.new_session
    all(processed: false).each do |sms|
      sms_respond sms, "Welcome Player! Enter your Name :"
    end
  end
  
  def self.greet_player
    all(processed: false).each do |sms|
      sms_respond sms, "Welcome #{sms.body}!"
    end
  end
  
  def self.sms_respond sms, body
    @@account.sms.messages.create to: sms.from, from: sms.to, body: body
  end
  
end
