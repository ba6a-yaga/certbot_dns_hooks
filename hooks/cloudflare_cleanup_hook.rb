#!/usr/bin/env ruby

require_relative '/usr/lib/request.rb'

domains = ENV["CERTBOT_DOMAIN"].split('.')
subdomains = domains.reject { |d| d == domains.last or domains[domains.size-2] == d }.join('.')
SUBDOMAIN = "#{ENV["SUBDOMAIN"].nil? ? "_acme-challenge" : ENV["SUBDOMAIN"]}.#{subdomains}"
path = "/tmp/#{ENV["CERTBOT_DOMAIN"]}"
unless Dir.exist? path 
    return
end

record_id = File.read("#{path}/#{SUBDOMAIN}_RECORD_ID").strip
zone_id = File.read("#{path}/#{SUBDOMAIN}_ZONE_ID").strip

response_del_subdomain = Request.new { |r|
    r.headers = {
        'Authorization': "Bearer #{ENV["Token"]}",
        'Content-Type': 'application/json' 
    }
    r.uri = "https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records/#{record_id}"
    r.method = :delete
}.fetch

if response_del_subdomain['success']
    puts "Domain successfully removed" 
    #TODO: добавить удаление файлов
else
    puts "Something went wrong..."
    puts response_del_subdomain
end