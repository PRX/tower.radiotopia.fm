const http = require("http");
const https = require("https");
const { parseXml } = require("@rgrove/parse-xml");

const FEED_URLS = [
  // Adultish
  "https://adultish.yr.media/",
  // Appearances
  "http://feeds.theheart.org/appearancespodcast",
  // Articles of Interest
  "https://feed.articlesofinterest.club/",
  // Benjamen Walker's Theory of Everything
  "http://feeds.prx.org/toe",
  // Canción Exploder
  "https://feeds.megaphone.fm/cancion-exploder",
  // Ear Hustle
  "http://feeds.earhustlesq.com/earhustlesq",
  // Everything is Alive
  "http://feeds.everythingisalive.com/everythingisalive",
  // The Heart
  "http://feeds.theheartradio.org/TheHeartRadio",
  // Home Cooking
  "https://feeds.feedburner.com/homecookingshow",
  // ITSBPS
  "https://feed.itsbps.condos/",
  // Judas and the Black Messiah
  "https://feeds.feedburner.com/JudasAndTheBlackMessiahPodcast",
  // Kitchen Sisters
  "https://feeds.fugitivewaves.org/fugitivewaves",
  // Memory Palace
  "http://feeds.thememorypalace.us/thememorypalace",
  // Millennial
  "http://feeds.millennialpodcast.org/millennialpodcast",
  // Mortified
  "http://feeds.getmortified.com/MortifiedPod",
  // Mumbai Crime
  "https://mumbaicrime.feeds.goldhawkproductions.com/",
  // Oprahdemics
  "https://podcast.oprahdemics.com/",
  // Over the Road
  "https://feed.overtheroad.fm/",
  // Partners
  "https://feed.partners.show/",
  // Passenger List
  "https://feed.passengerlist.org/",
  // Radio Diaries
  "http://feed.radiodiaries.org/radio-diaries",
  // Showcase
  "http://feeds.radiotopia.fm/radiotopia-showcase",
  // Song Exploder
  "https://feed.songexploder.net/SongExploder",
  // This Day
  "https://thisday.feed.electionhistory.show/",
  // The Stoop
  "https://feed.thestoop.org/",
  // The Truth
  "http://feeds.thetruthpodcast.com/thetruthapm",
  // West Wing Weekly
  "http://feeds.thewestwingweekly.com/westwingweekly",
];

function dateFmt(pubDate) {
  const isoString = new Date(pubDate).toISOString();
  const isoParts = isoString.split("T");
  const timeParts = isoParts[1].split(".");
  return `${isoParts[0]} ${timeParts[0]} UTC`;
}

function getFeed(uri) {
  return new Promise((resolve, reject) => {
    const q = new URL(uri);

    const options = {
      host: q.host,
      port: q.port,
      path: `${q.pathname || ""}${q.search || ""}`,
      headers: {
        "User-Agent":
          "PRX-Towerbot/1.0 (+https://github.com/PRX/tower.radiotopia.fm)",
      },
    };

    const client = uri.toLowerCase().startsWith("https") ? https : http;
    const req = client.request(options, (res) => {
      res.setEncoding("utf8");

      let body = "";
      res.on("data", (chunk) => {
        body += chunk;
      });
      res.on("end", () => resolve(parseXml(body)));
    });

    req.on("error", (error) => reject(error));

    req.write("");
    req.end();
  });
}

exports.handler = async () => {
  const feeds = await Promise.all(FEED_URLS.map((u) => getFeed(u)));

  const episodes = [];

  // Each feed is the result of parsing the RSS file with parse-xml
  // https://github.com/rgrove/parse-xml
  feeds.forEach((feed) => {
    feed.children.forEach((w) => {
      // Each value of w is a siblish of the top-level RSS element; we only
      // care about the RSS element
      if (w.type === "element" && w.name === "rss") {
        w.children.forEach((x) => {
          // Each value of x is some sibling of the channel element; we only
          // care about the channel element
          if (x.type === "element" && x.name === "channel") {
            let show;
            x.children.forEach((y) => {
              // Each value of y is a child of the channel element, like
              // <title> or <item>
              if (y.type === "element" && y.name === "title") {
                show = y.children[0].text;
              }

              if (y.type === "element" && y.name === "item") {
                const episode = { show };
                let encType;

                y.children.forEach((z) => {
                  // Each value of Z is a child of an <item>, like <pubDate>
                  // or <enclosure>
                  if (z.type === "element" && z.name === "title") {
                    episode.title = z.children[0].text;
                  }
                  if (z.type === "element" && z.name === "guid") {
                    episode.guid = z.children[0].text;
                  }
                  if (z.type === "element" && z.name === "pubDate") {
                    episode.date = dateFmt(z.children[0].text);
                  }
                  if (z.type === "element" && z.name === "enclosure") {
                    episode.audioURL = z.attributes.url;
                  }
                  if (z.type === "element" && z.name === "enclosure") {
                    encType = z.attributes.type;
                  }
                });

                // Only include episodes that have all the necessary data
                if (
                  episode.title &&
                  episode.guid &&
                  episode.date &&
                  episode.audioURL
                ) {
                  // Only include episodes that look like audio files
                  if (/audio/.test(encType)) {
                    episodes.push(episode);
                  }
                }
              }
            });
          }
        });
      }
    });
  });

  const response = {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Headers":
        "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
      "Access-Control-Allow-Methods": "GET,OPTIONS",
      "Access-Control-Allow-Origin": "https://radio.radiotopia.fm",
    },
    body: JSON.stringify(episodes),
  };
  return response;
};
