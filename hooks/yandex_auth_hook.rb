#!/usr/bin/env ruby

require_relative '/usr/lib/request.rb' 

SUBDOMAIN = ENV["SUBDOMAIN"].nil? ? "_acme-challenge" : ENV["SUBDOMAIN"]

response_add_subdomain = Request.new { |r|
    r.headers = {
        PddToken: ENV["Token"]
    }
    r.uri = "https://pddimp.yandex.ru/api2/admin/dns/add"
    r.method = :post
    r.data = {
        domain: ENV["CERTBOT_DOMAIN"],
        type: 'TXT',
        subdomain: "#{SUBDOMAIN}",
        ttl: 90,
        content: ENV["CERTBOT_VALIDATION"]
    }
}.fetch

if response_add_subdomain['success'] == 'ok'
    puts "DNS settings successfully changed"
    path = "/tmp/#{ENV["CERTBOT_DOMAIN"]}"
    Dir.mkdir path unless Dir.exist? path 
    File.open("#{path}/#{SUBDOMAIN}_RECORD_ID", 'w+') { |f| f.puts response_add_subdomain['record']['record_id']}

    120.times do
        result = `host -t TXT #{SUBDOMAIN}.#{ENV["CERTBOT_DOMAIN"]}`
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
