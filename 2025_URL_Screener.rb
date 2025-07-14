#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'openssl'
require 'resolv'
require 'nokogiri'
require 'json'

# --- Hilfsfunktionen ---

# Holt Geolocation-Daten von einer externen API
def get_geolocation(ip_address)
  geo_uri = URI.parse("http://ip-api.com/json/#{ip_address}")
  geo_response = Net::HTTP.get_response(geo_uri)
  return JSON.parse(geo_response.body)
rescue
  return { "status" => "fail" }
end

# --- Hauptlogik ---

if ARGV.empty?
  puts "Verwendung: #{$0} <URL1> [URL2] ..."
  exit
end

ARGV.each do |url_string|
  begin
    uri = URI.parse(url_string)
    
    # --- Performance & Netzwerk-Vorbereitung ---
    start_time = Time.now
    ip_address = Resolv.getaddress(uri.host)
    
    # --- HTTP Anfrage ---
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    
    # --- Post-Analyse ---
    duration = ((Time.now - start_time) * 1000).round(2)
    html_doc = Nokogiri::HTML(response.body)
    geo_data = get_geolocation(ip_address)

    # --- STRUKTURIERTE AUSGABE ---
    puts "╔══ ANFRAGE AN: #{url_string} ══════"
    
    # Sektion: Übersicht & Performance
    puts "║"
    puts "╠══ ÜBERSICHT & PERFORMANCE ═══════"
    puts "║  ├─ Protokoll:   HTTP/#{response.http_version}"
    puts "║  ├─ Status:      #{response.code} #{response.message}"
    puts "║  └─ Antwortzeit: #{duration} ms"
    
    # Sektion: Headers
    cookie_headers = response.get_fields('set-cookie') || []
    other_headers = response.each_header.to_a.reject { |k, _| k.downcase == 'set-cookie' }
    if !other_headers.empty? || !cookie_headers.empty?
      puts "║"
      puts "╠══ HEADERS ═══════════════════════"
      max_key_length = other_headers.map { |k, _| k.length }.max || 0
      other_headers.each do |key, value|
        padded_key = key.capitalize.ljust(max_key_length)
        puts "║  ├─ #{padded_key} : #{value}"
      end
      if !cookie_headers.empty?
        padded_key = 'Set-cookie'.capitalize.ljust(max_key_length)
        puts "║  └─ #{padded_key} :"
        cookie_headers.each_with_index do |cookie_string, index|
          cookie_parts = cookie_string.split(';').map(&:strip)
          main_cookie = cookie_parts.shift
          cookie_prefix = (index == cookie_headers.size - 1) ? "     └─🍪" : "     ├─🍪"
          puts "║#{cookie_prefix} #{main_cookie}"
          attributes = cookie_parts.select { |p| p.include?('=') }
          flags = cookie_parts.reject { |p| p.include?('=') }
          attributes.each { |attr| puts "║       ├─ #{attr}" }
          puts "║       └─ Flags: #{flags.join(', ')}" if !flags.empty?
        end
      end
    end

    # Sektion: Inhalts-Analyse (Nokogiri)
    puts "║"
    puts "╠══ 📄 INHALTS-ANALYSE (Scraping) ══"
    puts "║  ├─ HTML-Titel:    #{html_doc.at_css('title')&.text&.strip || 'N/A'}"
    puts "║  ├─ Meta-Descr.:   #{html_doc.at_css('meta[name="description"]')&.[]('content')&.strip || 'N/A'}"
    puts "║  ├─ H1-Überschrift: #{html_doc.at_css('h1')&.text&.strip || 'N/A'}"
    puts "║  ├─ Links (total): #{html_doc.css('a').count}"
    puts "║  └─ Bilder (total):  #{html_doc.css('img').count}"

    # Sektion: Netzwerk & Standort
    puts "║"
    puts "╠══ 🌍 NETZWERK & STANDORT ═════════"
    puts "║  ├─ IP-Adresse:   #{ip_address}"
    if geo_data['status'] == 'success'
      puts "║  ├─ Standort:     #{geo_data['city']}, #{geo_data['regionName']}, #{geo_data['country']}"
      puts "║  ├─ Zeitzone:     #{geo_data['timezone']}"
      puts "║  └─ Provider/ISP: #{geo_data['isp']} (#{geo_data['org']})"
    else
      puts "║  └─ Standort-Info: Konnte nicht ermittelt werden."
    end
    
    puts "╚═══════════════════════════════════"

  rescue => e
    puts "╔══ FEHLER BEI: #{url_string} ══"
    puts "║  ❌ #{e.class}: #{e.message}"
    puts "╚════════════════════════════════"
  end
  puts "\n"
end