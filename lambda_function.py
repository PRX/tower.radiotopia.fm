# The endpoint for this service should be
# /api/v2/episodes.json
#
# It return an array of objects
# eg [{}, {}, {}]
# Each object is of the format
# {'show': show title, 'title': episode title,
#   'date': pub date (YYYY-MM-DD HH:MM:SS),
#   'audioURL': audio URL, 'guid': GUID}

import urllib2
import socket
import rfc822
from datetime import datetime
from xml.etree import cElementTree as ET

FEED_URLS = [
    # 99pi
    'http://feeds.99percentinvisible.org/99percentinvisible',
    # Allusionist
    'http://feeds.theallusionist.org/Allusionist',
    # Criminal
    'http://feeds.thisiscriminal.com/CriminalShow',
    # Ear Hustle
    'http://feeds.earhustlesq.com/earhustlesq',
    # Everything is Alive
    'http://feeds.everythingisalive.com/everythingisalive',
    # The Heart
    'http://feeds.theheartradio.org/TheHeartRadio',
    # Kitchen Sisters
    'http://feeds.fugitivewaves.org/fugitivewaves',
    # Memory Palace
    'http://feeds.thememorypalace.us/thememorypalace',
    # Millennial
    'http://feeds.millennialpodcast.org/millennialpodcast',
    # Mortified
    'http://feeds.getmortified.com/MortifiedPod',
    # Radio Diaries
    'http://feed.radiodiaries.org/radio-diaries',
    # Showcase
    'http://feeds.radiotopia.fm/radiotopia-showcase',
    # Song Exploder
    'http://feed.songexploder.net/SongExploder',
    # This is Love
    'http://feeds.thisiscriminal.com/thisislovepodcast',
    # Theory of Everything
    'http://feeds.prx.org/toe',
    # The Truth
    'http://feeds.thetruthpodcast.com/thetruthapm',
    # West Wing Weekly
    'http://feeds.thewestwingweekly.com/westwingweekly',
    # Trump Con Law
    'http://feeds.trumpconlaw.com/TrumpConLaw',
    # ZigZag
    'http://feeds.stableg.com/zigzagpodcast'
]


def lambda_handler(event, context):
    episodes = []

    for url in FEED_URLS:
        try:
            rss = ET.fromstring(urllib2.urlopen(url, timeout=2).read())
        except urllib2.HTTPError:
            print "Error opening %s." % url
        except socket.timeout:
            print "Error socket.timeout %s." % url
        except urllib2.URLError:
            print "Error URLError opening %s." % url
        else:
            channel = rss.find('channel')
            showtitle = channel.find('title').text

            for item in channel.findall('item'):
                enc = item.find('enclosure')
                encurl = enc.attrib['url']
                enctype = enc.attrib['type']

                if enctype.find('audio') != -1:
                    title = item.find('title').text

                    datetext = item.find('pubDate').text
                    datetuple = rfc822.parsedate_tz(datetext)
                    datets = rfc822.mktime_tz(datetuple)
                    pubdate = datetime.fromtimestamp(datets)
                    pubdatestr = pubdate.strftime('%Y-%m-%d %H:%M:%S UTC')

                    guid = item.find('guid').text

                    episode = {
                        'show': showtitle,
                        'title': title,
                        'date': pubdatestr,
                        'audioURL': encurl,
                        'guid': guid
                    }
                    episodes.append(episode)

    return episodes
