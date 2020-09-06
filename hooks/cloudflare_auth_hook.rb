#!/usr/bin/env ruby

require_relative '/usr/lib/request.rb' 

domains = ENV["CERTBOT_DOMAIN"].split('.')
subdomains = domains.reject { |d| d == domains.last or domains[domains.size-2] == d }.join('.')
SUBDOMAIN = subdomains.length.zero? ? "_acme-challenge" : subdomains
main_domain = "#{domains[domains.size-2]}.#{domains[domains.size-1]}"
response_get_id_zone = Request.new { |r|
    r.headers = {
        Authorization: "Bearer #{ENV["Token"]}",
        'Content-Type' => 'application/json' 
    }
    r.uri = "https://api.cloudflare.com/client/v4/zones?name=#{main_domain}"
    r.method = :get
}.fetch
p response_get_id_zone


if response_get_id_zone['success']
    response_add_subdomain = Request.new { |r|
        r.headers = {
            Authorization: "Bearer #{ENV["Token"]}",
            'Content-Type' => 'application/json' 
        }
        r.uri = "https://api.cloudflare.com/client/v4/zones/#{response_get_id_zone['result'][0]['id']}/dns_records"
        r.method = :post
        r.data = {
            type: 'TXT',
            name: SUBDOMAIN,
            content: ENV["CERTBOT_VALIDATION"],
            ttl: 120
        }
    }.fetch
    p response_add_subdomain

    if response_add_subdomain['success']
        puts "DNS settings successfully changed"
        path = "/tmp/#{ENV["CERTBOT_DOMAIN"]}"
        Dir.mkdir path unless Dir.exist? path 
        File.open("#{path}/#{SUBDOMAIN}_RECORD_ID", 'w+') { |f| f.puts response_add_subdomain['result']['id']}
        File.open("#{path}/#{SUBDOMAIN}_ZONE_ID", 'w+') { |f| f.puts response_get_id_zone['result'][0]['id']}
    
        120.times do
            puts "Checking challenge #{SUBDOMAIN}.#{main_domain}"
            result = `host -t TXT #{SUBDOMAIN}.#{main_domain}`
            result_txt = result.match /#{ENV["CERTBOT_VALIDATION"]}/
    
            if result_txt.to_a[0] == ENV["CERTBOT_VALIDATION"]
                puts "DNS settings applied"
                return
            else
                puts "Waiting for a DNS change..."
                sleep 10
            end
        end
    else
        puts "Something went wrong..."
    end
else
    puts "Something went wrong..."
end
