#!/usr/bin/env ruby

require_relative '../lib/request.rb'

response_get_subdomain = Request.new { |r|
    r.headers = {
        PddToken: ENV["PddToken"]
    }
    r.uri = "https://pddimp.yandex.ru/api2/admin/dns/list?domain=racing.xsportgame.ru"
    r.method = :get
}.fetch

if response_get_subdomain['success'] == 'ok'
    puts response_get_subdomain
else
    puts "Something went wrong..."
    puts response_get_subdomain
end