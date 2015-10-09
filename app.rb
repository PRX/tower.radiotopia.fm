# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
Bundler.require

require 'sinatra/base'
require 'sinatra/cross_origin'

configure do
  enable :cross_origin
end

FEED_URLS = [
  'http://feeds.99percentinvisible.org/99percentinvisible',
  'http://feed.loveandradio.org/loveplusradio',
  'http://feeds.kcrw.com/kcrw/sg',
  'http://feeds.feedburner.com/thetruthapm',
  'http://feeds.prx.org/toe',
  'http://www.npr.org/rss/podcast.php?id=510288',
  'http://feeds.fugitivewaves.org/fugitivewaves',
  'http://feeds.theheartradio.org/TheHeartRadio',
  'http://feeds.feedburner.com/CriminalShow',
  'http://feeds.getmortified.com/MortifiedPod',
  'http://feeds.theallusionist.org/Allusionist',
  'http://feed.songexploder.net/songexploder',
  'http://feeds.feedburner.com/thememorypalace',
]

class App < Sinatra::Base
  get '/enclosures/list' do
    headers 'Access-Control-Allow-Origin' => '*'
    cache_control :public, max_age: 3600  # 60 mins.

    enclosure_urls = []

    Feedjira::Feed.fetch_raw(FEED_URLS).each do |url, xml|
      parser = Feedjira::Parser::ITunesRSS
      feed = Feedjira::Feed.parse_with(parser, xml)

      feed.entries.each do |entry|
        if entry.enclosure_type =~ /audio/
          enclosure_urls << [entry.enclosure_url, entry.title, feed.title, entry.published]
        end
      end
    end

    content_type :json
    return enclosure_urls.to_json
  end

  get '/recent' do
    cache_control :public, max_age: 3600  # 60 mins.

    items = []

    Feedjira::Feed.fetch_raw(FEED_URLS).each do |url, xml|
      parser = Feedjira::Parser::ITunesRSS
      feed = Feedjira::Feed.parse_with(parser, xml)

      feed.entries.each do |entry|
        if entry.enclosure_type =~ /audio/
          items << [entry.title, feed.title, entry.published]
        end
      end
    end

    content_type :text
    return items.sort_by{|item| item[2] }.reverse.map{|item| item.join(', ') }.join("\n")
  end
end
