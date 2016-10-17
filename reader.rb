require 'rubygems'
require 'sinatra'
require 'sinatra/logger'

require 'date'
require 'haml'
require 'feedzirra'
require 'json'


configure :development do
    enable :logging, :dump_errors, :raise_errors, :show_exceptions
end

set :port, 9001
set :haml, :format => :html5 # default Haml format is :xhtml

path = File.expand_path "../", __FILE__
set :root, path
set :logger_level, :debug

require "./models/reader"
require "./models/helpers"

before do
  ajaxHelper 
end

#after do
#  TODO figure out way to encode response body to_json on ajax requests
#  might have to use http://stackoverflow.com/questions/3423905/automatically-encode-rack-output-with-json-when-content-type-is-application-json
#  logger.debug("after")
#end

post '/subscription/add' do
  url = params['url'].strip ||= ""
  if url.length > 0
      subscription = Subscription.first_or_create(
          :url => url
      );
      return subscription.to_json
  end
  return {:error=>"Unable to create subscription for url [" + url + "]."}.to_json
end

# this should be a post
# todo: http://railscasts.com/episodes/243-beanstalkd-and-stalker
get '/subscription/update' do
  feeds = []
  Subscription.active.each do |subscription|
    feed = Feedzirra::Parser::Atom.new
    feed.feed_url = subscription.url

    sub = Subscription.by_url_cached(feed.feed_url)
    # item = Items.last(:subscription => sub)
    item = Items.first(:subscription => sub, :order => :pub_date.desc)
    unless item.nil?
      entry         = Feedzirra::Parser::AtomEntry.new
      entry.url     = item.url
      entry.title   = item.title 
      feed.entries  = [entry]
      p "sub"
      p subscription.url
      p "entry:"
      p entry.inspect
    end
    feeds.push(feed)
  end

  p "feeds: " + feeds.length.to_s
  p "updating feeds:"
  updated_feeds = Feedzirra::Feed.update(feeds)

  p "updated feeds:"
  p updated_feeds.inspect
  if 0 == updated_feeds
    return "no updates"
  end

  # p updated_feeds.length.to_s
  now = DateTime.now

  #iterate over feeds and save subscriptions
  updated_feeds.each do |feed|
    p "feed:" + feed.feed_url
    sub = Subscription.by_url_cached(feed.feed_url)
    last_updated = feed.last_modified.nil? ? now : DateTime.parse(feed.last_modified.to_s)
    sub.last_updated  = last_updated
    entries_count     = feed.new_entries.length ||= 0
    sub.article_count = sub.article_count + entries_count
    sub.unread_count  = sub.unread_count + entries_count
    sub.etag          = feed.etag
    sub.save

    # iterate feed entries and save them as Items
    if feed.new_entries
      p "number of updated entries found: " + feed.new_entries.length.to_s
      feed.new_entries.reverse!.each do |entry|
        begin
          pub_time = entry.published ||= Time.now
          pub_date = DateTime.parse(pub_time.to_s)

          description = !entry.description.nil? ? entry.description : "no description"

          unless entry.url.nil?
            item              = Items.new
            item.guid         = entry.id
            item.url          = entry.url
            item.title        = entry.title ||= "No title"
            item.description  = description
            item.pub_date     = pub_date
            item.subscription = sub
            item.save
            p "entry:" + entry.title + " url: " + entry.url + " id:" + entry.id
          end
        rescue Exception => e
          p "rescued from "
          p e.message
        end
      end
    end
  end
  return "done!"
end

get '/' do
  # localvar = "hi"; 
  @title = "Reader";
  # haml :index, :locals => { :localvar => localvar }
  @subscriptions = Subscription.all(:status => Subscription::Active, :order=>[:sort.asc])
  haml :index, :locals => {}
end

