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
  get '/best-of/2015' do
    headers 'Access-Control-Allow-Origin' => '*'
    cache_control :public, max_age: 3600  # 60 mins.

    enclosure_urls = [
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?1","Episode 26: Angie","99% Invisible","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?2","Episode 26: Angie","Song Exploder","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?3","Episode 26: Angie","Criminal","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?4","Episode 26: Angie","The Allusionist","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?5","Episode 26: Angie","The Truth","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?6","Episode 26: Angie","Benjamen Walkerâ€™s Theory of Everything","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?7","Episode 26: Angie","Fugitive Waves","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?8","Episode 26: Angie","Radio Diaries","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?9","Episode 26: Angie","Strangers","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?10","Episode 26: Angie","Love + Radio","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?11","Episode 26: Angie","The Heart","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?12","Episode 26: Angie","The Mortified Podcast","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/UBGNx5Lz8gE/Epsiode_26__Angie.mp3?13","Episode 26: Angie","the memory palace","2015-12-10 00:00:00 UTC"],
    ]

    content_type :json
    return enclosure_urls.to_json
  end

  get '/api/v2/episodes.json' do
    cache_control :public, max_age: 3600  # 60 mins.

    episodes = []

    Feedjira::Feed.fetch_raw(FEED_URLS).each do |url, xml|
      parser = Feedjira::Parser::ITunesRSS
      feed = Feedjira::Feed.parse_with(parser, xml)

      feed.entries.each do |entry|
        if entry.enclosure_type =~ /audio/
          episodes << {
            show: feed.title,
            title: entry.title,
            date: entry.published,
            audioURL: entry.enclosure_url,
            guid: entry.id
          }
        end
      end
    end

    content_type :json
    return episodes.to_json
  end

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
