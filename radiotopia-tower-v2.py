# The endpoint for this service should be
# /api/v2/episodes.json
#
# It return an array of objects
# eg [{}, {}, {}]
# Each object is of the format
# {'show': show title, 'title': episode title,
#   'date': pub date (YYYY-MM-DD HH:MM:SS), 'audioURL': audio URL, 'guid': GUID}

import urllib2
import socket
import rfc822
from datetime import datetime
from xml.etree import cElementTree as ET

FEED_URLS = [
    'http://feeds.99percentinvisible.org/99percentinvisible',
    'http://feed.loveandradio.org/loveplusradio',
    'http://feeds.strangersnomore.org/StrangersNoMore',
    'http://feeds.thetruthpodcast.com/thetruthapm',
    'http://feeds.prx.org/toe',
    'http://feed.radiodiaries.org/radio-diaries',
    'http://feeds.fugitivewaves.org/fugitivewaves',
    'http://feeds.theheartradio.org/TheHeartRadio',
    'http://feeds.thisiscriminal.com/CriminalShow',
    'http://feeds.getmortified.com/MortifiedPod',
    'http://feeds.theallusionist.org/Allusionist',
    'http://feed.songexploder.net/SongExploder',
    'http://feeds.thememorypalace.us/thememorypalace',
    'http://feeds.millennialpodcast.org/millennialpodcast',
    'http://feeds.thewestwingweekly.com/westwingweekly',
    'http://feeds.thebuglepodcast.com/thebuglefeed',
    'http://feeds.trumpconlaw.com/TrumpConLaw',
    'http://feeds.earhustlesq.com/earhustlesq',
    'http://feeds.radiotopia.fm/radiotopia-showcase'
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
