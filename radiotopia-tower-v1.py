import urllib2
import rfc822
from datetime import datetime
from xml.etree import cElementTree as ET

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

def lambda_handler(event, context):
    episodes = []

    for url in FEED_URLS:
        rss = ET.fromstring(urllib2.urlopen(url).read())
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

                episode = [encurl, title, showtitle, pubdatestr, guid]
                episodes.append(episode)

    return episodes
