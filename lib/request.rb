require 'net/http'
require 'json'

class Request

    attr_accessor :uri, :host, :port, :method, :headers, :data

    def initialize
        yield self
        self.uri = URI(self.uri)
        self.method = :get if self.method.nil?
        @limit = 10
    end

    def fetch
        case self.method
        when :post then
            Net::HTTP.start(self.uri.host, self.uri.port, :use_ssl => self.uri.scheme == 'https') do |http|
                query = Net::HTTP::Post.new self.uri
                query.set_form_data(self.data) unless self.data.nil?
                add_headers query
                response(http.request query)
            end
        when :get then
            Net::HTTP.start(self.uri.host, self.uri.port, :use_ssl => self.uri.scheme == 'https') do |http|
                query = Net::HTTP::Get.new self.uri
                add_headers query
                response(http.request query)
            end  
        end 
    end

    private

    def add_headers(request)
        unless self.headers.nil?
            self.headers.each do |key, value| 
                request[key] = value
            end
        end
    end

    def response(result)
        raise ArgumentError, 'too many HTTP redirects' if @limit == 0
        case result
        when Net::HTTPSuccess then
            JSON.parse(result.body)
        when Net::HTTPRedirection then
            self.uri = result['location']
            warn "redirected to #{self.uri}"
            @limit -= 1
            self.fetch
        else
            { code: result.code, message: result.message }
        end
    end
end 