# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
Bundler.require

require 'sinatra/base'

class App < Sinatra::Base
  get '/enclosures/urls' do
    cache_control :public, max_age: 3600  # 60 mins.

    feed_urls = [
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
    ]

    enclosure_urls = []

    Feedjira::Feed.fetch_raw(feed_urls).each do |url, xml|
      parser = Feedjira::Parser::ITunesRSS
      feed = Feedjira::Feed.parse_with(parser, xml)

      feed.entries.each do |entry|
        if entry.enclosure_type =~ /audio/
          enclosure_urls << entry.enclosure_url
        end
      end
    end

    content_type :json
    return enclosure_urls.to_json
  end
end
