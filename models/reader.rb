require 'dm-core'
require 'dm-migrations'
require 'dm-serializer'

configure :development do
  # DataMapper::Logger.new(STDOUT, :debug)
end

# docs on this pig:
# http://datamapper.org/getting-started
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/reader.db")

class Subscription
  include DataMapper::Resource

  Deleted = 0
  Active = 1
  @@url_cache = Hash.new

  property :id, Serial
  property :label, Text
  property :url, Text
  property :article_count, Integer
  property :unread_count, Integer
  property :sort, Integer
  property :parent, Integer
  property :added_date, DateTime
  property :last_updated, DateTime
  property :etag, Text
  property :status, Integer, :default => Subscription::Active

  def self.active
    Subscription.all(:status => Subscription::Active, :order=>[:sort.asc])
  end

  def self.by_url_cached(url)
    unless @@url_cache.has_key?(url)
      @@url_cache[url] = Subscription.first(:url => url)
    end
    @@url_cache[url]
  end
end

class Items
  include DataMapper::Resource
  property :id, Serial
  property :url, Text
  property :title, Text
  property :description, Text
  property :pub_date, DateTime
  property :is_read, Integer, :default => 0
  property :self_read, Integer, :default => 0
  property :is_bookmarked, Integer, :default => 0
  property :guid, Text
  belongs_to :subscription
end

DataMapper.auto_upgrade!

