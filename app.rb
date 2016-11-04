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
  'http://feeds.strangersnomore.org/StrangersNoMore',
  'http://feeds.feedburner.com/thetruthapm',
  'http://feeds.prx.org/toe',
  'http://feed.radiodiaries.org/radio-diaries',
  'http://feeds.fugitivewaves.org/fugitivewaves',
  'http://feeds.theheartradio.org/TheHeartRadio',
  'http://feeds.feedburner.com/CriminalShow',
  'http://feeds.getmortified.com/MortifiedPod',
  'http://feeds.theallusionist.org/Allusionist',
  'http://feed.songexploder.net/songexploder',
  'http://feeds.thememorypalace.us/thememorypalace',
  'http://feeds.millennialpodcast.org/millennialpodcast',
  'http://feeds.thebuglepodcast.com/thebuglefeed',
  'http://feeds.thewestwingweekly.com/westwingweekly'
]

class App < Sinatra::Base
  # This is being used by radio.radiotopia.fm
  get '/api/v1/episodes.json' do
    headers 'Access-Control-Allow-Origin' => '*'
    cache_control :public, max_age: 3600  # 60 mins.

    episodes = []

    FEED_URLS.each do |url|
      rss = Faraday.new.get(url).body
      feed = Feedjira::Parser::Podcast.parse(rss)

      feed.items.each do |item|
        if item.enclosure.type =~ /audio/
          episodes << [item.enclosure.url, item.title, feed.title, item.pub_date, item.guid.guid]
        end
      end
    end

    content_type :json
    return episodes.to_json
  end

  # This is being used by the Radiotopia Radio tvOS app
  get '/api/v2/episodes.json' do
    cache_control :public, max_age: 3600  # 60 mins.

    episodes = []

    FEED_URLS.each do |url|
      rss = Faraday.new.get(url).body
      feed = Feedjira::Parser::Podcast.parse(rss)

      feed.items.each do |item|
        if item.enclosure.type =~ /audio/
          episodes << {
            show: feed.title,
            title: item.title,
            date: item.pub_date.utc,
            audioURL: item.enclosure.url,
            guid: item.guid.guid
          }
        end
      end
    end

    content_type :json
    return episodes.to_json
  end

  get '/best-of/2015' do
    headers 'Access-Control-Allow-Origin' => '*'
    cache_control :public, max_age: 3600  # 60 mins.

    enclosure_urls = [
      ["http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/99percentinvisible/cdn.99percentinvisible.org/wp-content/uploads/173-Awareness.mp3","Awareness","99% Invisible","2015-12-10 00:00:00 UTC"],
      ["http://www.podtrac.com/pts/redirect.mp3/traffic.libsyn.com/songexploder/SongExploder28.mp3","The Long Winters","Song Exploder","2015-12-10 00:00:00 UTC"],
      ["http://feedproxy.google.com/~r/CriminalShow/~5/G36cvOunLxY/Episode_27__No_Place_Like_Home.mp3","No Place Like Home","Criminal","2015-12-10 00:00:00 UTC"],
      ["http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/allusionist/cdn.allusionist.prx.org/wp-content/uploads/Allusionist-25-Toki-Pona.mp3","Toki Pona","The Allusionist","2015-12-10 00:00:00 UTC"],
      ["http://www.podtrac.com/pts/redirect.mp3/traffic.libsyn.com/thetruthapm/Can_You_Help_Me_Find_My_Mom.mp3","Can You Help Me Find My Mom?","The Truth","2015-12-10 00:00:00 UTC"],
      ["http://feeds.prx.org/~r/TOE/~5/dco62LpgGE8/toe57rentdircut.mp3","New York After Rent (Director's Cut)","Benjamen Walker's Theory of Everything","2015-12-10 00:00:00 UTC"],
      ["http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/fugitivewaves/cdn.fugitivewaves.prx.org/wp-content/uploads/FW-28-Wall-Street-Mix-08192015.mp3","Wall Street: San Quentin's Stock Market Wizard","Fugitive Waves","2015-12-10 00:00:00 UTC"],
      ["http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/radiodiaries/cdn.radiodiaries.prx.org/wp-content/uploads/Retirement-home-podcast.mp3","The Last Place","Radio Diaries","2015-12-10 00:00:00 UTC"],
      ["http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/strangersnomore/cdn.strangers.prx.org/wp-content/uploads/Strangers58_Unconditional_edit.mp3","Unconditional","Strangers","2015-12-10 00:00:00 UTC"],
      ["http://feed.loveandradio.org/~r/loveplusradio/~5/MDjf0bJO7oo/Love-Radio-The-Living-Room.mp3","The Living Room","Love + Radio","2015-12-10 00:00:00 UTC"],
      ["http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/theheart/cdn.heart.prx.org/wp-content/uploads/S1E5-The-Hurricane.mp3","The Hurricane","The Heart","2015-12-10 00:00:00 UTC"],
      ["http://www.podtrac.com/pts/redirect.mp3/media.blubrry.com/mortified/cdn.mortified.prx.org/wp-content/uploads/14_Jenny_Is_My_Boyfriend_Gay.mp3","Jenny: Is My Boyfriend Gay?","The Mortified Podcast","2015-12-10 00:00:00 UTC"],
      ["http://feeds.thememorypalace.us/~r/TheMemoryPalace/~5/gto4BOhPpNw/thememorypalace.mp3","Notes on an Imaginary Plaque...","the memory palace","2015-12-10 00:00:00 UTC"],
    ]

    content_type :json
    return enclosure_urls.to_json
  end

  get '/recent' do
    cache_control :public, max_age: 3600  # 60 mins.

    items = []

    FEED_URLS.each do |url|
      rss = Faraday.new.get(url).body
      feed = Feedjira::Parser::Podcast.parse(rss)

      feed.items.each do |item|
        if item.enclosure.type =~ /audio/
          items << [item.title, feed.title, item.pub_date]
        end
      end
    end

    content_type :text
    return items.sort_by{|item| item[2] }.reverse.map{|item| item.join(', ') }.join("\n")
  end
end
