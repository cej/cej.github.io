require 'rubygems'
require 'rss'
require 'open-uri'
require 'json'
require 'net/http'


url = 'https://media.rss.com/concord-storytellers/feed.xml'
episodes = []

URI.open(url) do |rss|
  feed = RSS::Parser.parse(rss, false)
  feed.items.each do |item|
    puts item.link
    puts item.title
    ep_id = item.link.split("/").slice(-1)
    transcript_url = "https://www.concordstorytellers.com/srt/#{ep_id}.srt"
    local_transcript_url = "srt/#{ep_id}.srt"
    uri = URI(transcript_url)
    srt = Net::HTTP.get(uri)
    unless File.exists?(local_transcript_url)
      File.open(local_transcript_url, "wb"){|f| f.write(srt)}
    end

    obj = {
      episode_id: ep_id,
      title: item.title,
      description: item.description,
      media_url: item.enclosure.url,
      length: item.enclosure.length,
      date: item.pubDate,
      link: item.link,
      transcript_url: transcript_url
    }
    episodes << obj
  end
end

File.open("js/episodes.js", "wb"){|f| f.write  "var storytellers_episodes = #{episodes.to_json}"}
