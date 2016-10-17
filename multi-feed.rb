require 'feedzirra'

# entry.title is required or else you will get a trailing entry that is one_entry

# create feed one with last entry
one = Feedzirra::Parser::Atom.new
one.feed_url = "http://localhost/rss-samples/hn.xml"
one_entry = Feedzirra::Parser::AtomEntry.new
one_entry.url = "http://news.ycombinator.com/item?id=2132568"
one_entry.title = "Ask PG: Please revert the change to break up discussions in to multiple pages?"
one.entries = [one_entry]

# create feed two with last entry
two = Feedzirra::Parser::Atom.new
two.feed_url = "http://localhost/rss-samples/0.91.xml"
two_entry = Feedzirra::Parser::AtomEntry.new
two_entry.url = "http://writetheweb.com/read.php?item=22"
two_entry.title = "Personal web server integrates file sharing and messaging"
two.entries = [two_entry]

three = Feedzirra::Parser::Atom.new
three.feed_url = "http://localhost/rss-samples/qc.xml"
three_entry = Feedzirra::Parser::AtomEntry.new
three_entry.url = "http://questionablecontent.net/view.php?comic=1844"
three_entry.title = "Beware The Student Wizards"
three.entries = [three_entry]

feeds = [one, two, three]
updated_feeds = Feedzirra::Feed.update(feeds)

p "updated feeds:"
p updated_feeds.length
updated_feeds.each do |feed|
  p "feed:" + feed.url
  # p feed.inspect
  p "last modified: "
  p feed.last_modified.to_s
  p "etag: "
  p feed.etag
  feed.entries.reverse!.each do |entry|
    title = entry.title ||= "no title"
    url = entry.url ||= "no url"
    if title == "no title" 
      p "entry missing title:"
      p entry.inspect
    else
      p "entry:" + title + "url: " + url
    end
    # p entry.inspect
  end
end

# use this method for initial fetching
# feeds = Feedzirra::Feed.fetch_and_parse(feed_urls)


