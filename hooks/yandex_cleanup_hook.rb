#!/usr/bin/env ruby

require_relative '/usr/lib/request.rb'

SUBDOMAIN = ENV["SUBDOMAIN"].nil? ? "_acme-challenge" : ENV["SUBDOMAIN"]
path = "/tmp/#{ENV["CERTBOT_DOMAIN"]}"
record_id = File.read("#{path}/#{SUBDOMAIN}_RECORD_ID")

response_del_subdomain = Request.new { |r|
    r.headers = {
        PddToken: ENV["PddToken"]
    }
    r.uri = "https://pddimp.yandex.ru/api2/admin/dns/del"
    r.method = :post
    r.data = {
        domain: "#{ENV["CERTBOT_DOMAIN"]}",
        record_id: record_id,
    }
}.fetch

if response_del_subdomain['success'] == 'ok'
    puts "Domain successfully removed" 
else
    puts "Something went wrong..."
    puts response_del_subdomain
end