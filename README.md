# tower.radiotopia.fm

[![License](https://img.shields.io/badge/license-AGPL-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.html)
[![Code Climate](https://codeclimate.com/github/PRX/tower.radiotopia.fm/badges/gpa.svg)](https://codeclimate.com/github/PRX/tower.radiotopia.fm)
[![Dependency Status](https://gemnasium.com/PRX/tower.radiotopia.fm.svg)](https://gemnasium.com/PRX/tower.radiotopia.fm)

This is a lightweight microservice that acts as a content source for [Radiotopia Radio](http://radio.radiotopia.fm). It aggregates certain data of podcast RSS feeds and transposes them into a simple JSON API.

Each podcast feed is fetched and processed to build a list of things like enclosure urls, titles, etc. The resulting list is cached (in memcache, by Dalli) for an hour.

New feeds can be added by updating the `feed_urls` array in [app.rb](https://github.com/PRX/tower.radiotopia.fm/edit/master/app.rb).
