#!/usr/bin/env ruby
# frozen_string_literal: true

# Live test script for zotero-rb gem
#
# Usage:
#   1. Copy .env.example to .env and add your credentials
#   2. Run: ruby scripts/test_live.rb

require_relative "../lib/zotero"

# Load environment variables from .env file
if File.exist?(".env")
  File.readlines(".env").each do |line|
    key, value = line.strip.split("=", 2)
    ENV[key] = value if key && value
  end
end

API_KEY = ENV.fetch("ZOTERO_API_KEY", nil)
USER_ID = ENV.fetch("ZOTERO_USER_ID", nil)

unless API_KEY && USER_ID
  puts "Error: Missing credentials!"
  puts "Please copy .env.example to .env and add your API key and user ID"
  exit 1
end

client = Zotero.new(api_key: API_KEY)
library = client.user_library(USER_ID)

puts "Testing zotero-rb gem with live API..."
puts

# Test basic functionality
begin
  puts "Fetching 5 most recent books..."
  items = library.items(itemType: "book", limit: 5, sort: "dateModified", direction: "desc")
  puts "Found #{items.length} books:"

  items.each_with_index do |item, index|
    puts "\n  #{index + 1}. #{item['data']['title'] || '[No title]'}"
    puts "     Type: #{item['data']['itemType']}"
    puts "     Key: #{item['key']}"
    puts "     Version: #{item['version']}"

    # Show creators if present
    if item["data"]["creators"] && !item["data"]["creators"].empty?
      creators = item["data"]["creators"].map { |c| "#{c['firstName']} #{c['lastName']}".strip }
      puts "     Authors: #{creators.join(', ')}"
    end

    # Show publication year if present
    puts "     Date: #{item['data']['date']}" if item["data"]["date"] && !item["data"]["date"].empty?
  end

  puts "\nFetching collections..."
  collections = library.collections
  puts "Found #{collections.length} collections"

  puts "\nTesting metadata..."
  item_types = client.item_types
  puts "Available item types: #{item_types.length}"

  puts "\nTesting API key verification..."
  key_info = client.verify_api_key
  puts "API key valid for user: #{key_info['username']}"
rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.first(3)
end
