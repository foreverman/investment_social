module 36Kr
  def self.connection
    Faraday.new(:url => "http://rong.36kr.com") do |faraday|
      faraday.request :url_encoded 
      faraday.response :logger 
      faraday.adapter :net_http_persistent
    end
  end
end
