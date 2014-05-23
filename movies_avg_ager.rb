#!/usr/bin/env ruby
#
# Jacob Vallejo (c) 2014
#
# IMDb average age checker for currently showing movies
# Just run it and it will go.
#

require 'nokogiri'
require 'net/http/persistent'
require 'date'
require 'logger'
require 'pry'

IMDB_BASE = 'http://www.imdb.com'
IMDB_NOW_SHOWING_URL = IMDB_BASE + '/showtimes/location?sort=title&ref_=shlc_sort'

HTTP = Net::HTTP::Persistent.new('movies')

LOG = Logger.new(STDERR)
LOG.level = Logger::DEBUG

def fetch(url)
  HTTP.request(URI url).body
end

# Get the movies that are currently in theater
def get_now_showing_movies()
  LOG.info("Fetching all movies that are showing from #{IMDB_NOW_SHOWING_URL}")
  doc_tree = Nokogiri::HTML(fetch(IMDB_NOW_SHOWING_URL))
  nodes = doc_tree.xpath("//div[@itemscope]//*[@itemprop='name']/a")
  nodes.collect { |mov| link_from_node(mov) }
end

# Turn a link into a proper imdb link if its not an external link
def imdb_link(lnk)
  if lnk =~ /^https?:/
    lnk
  else
    IMDB_BASE + lnk
  end
end

# Turn a 'a'-tag node into a IMDB link,
#
# {
#   link: the href of the resource
#   name: the name of the resource (title, actor name)
# }
def link_from_node(node)
  {
    link: imdb_link(node['href'].split("?")[0]).gsub("showtimes/", ""),
    name: node.text.lstrip.rstrip
  }
end

# Get the movie showing date
def get_movie_show_date(mov)
  LOG.info("Retrieving movie '#{mov[:name]}' details from #{mov[:link]}/.")
  doc_tree = Nokogiri::HTML(fetch(mov[:link] + "/"))
  show_date = doc_tree.xpath("//*[@class='infobar']//meta[@itemprop='datePublished']/@content")
  LOG.debug("Movie '#{mov[:name]}' release date: '#{show_date}'")
  DateTime.parse(show_date.to_s)
end

# Get the cast for a given movie link
def get_movie_cast(mov)
  link = mov[:link] + "/fullcredits"
  LOG.info("Retrieving movie cast for #{mov[:name]} from '#{link}'.")
  doc_tree = Nokogiri::HTML(fetch(link))
  cast = doc_tree.xpath("//table[@class='cast_list']//td[@itemprop='actor']/a")
  cast.collect { |c| link_from_node(c) }
end

# Parse a string date (1983-8-12) to an age in years
def parse_age(borndate, reldate)
  LOG.debug("Cast member birthdate: '#{borndate.to_s}'")
  LOG.debug("Cast member age relative to: '#{reldate.to_s}'")

  # Some actors don't have their age, they're up and coming actors
  if borndate.empty?
    LOG.debug("Cast member's birthdate is not available.")
    return nil
  end

  # If missing the birth month/day, just use the year they were born
  # There are a few cases where we get 1963-0-0 as the birthdate
  borndate = borndate.split('-')[0] + "-1-1" if borndate =~ /-0-0/
  begin
    birthdate = DateTime.parse(borndate.to_s)
  rescue ArgumentError
    LOG.debug("The date time format was invalid, skipping this cast member.")
    return nil
  end

  # Process death (end date) safely
  begin
    reldate = DateTime.parse(reldate.to_s)
  rescue Exception
    LOG.debug("The death date could not be parsed. Using today to calculate.")
    return nil
  end

  age = (reldate - birthdate).to_i / 365
end

# Get age of the cast member
def get_cast_member_age(cst, mov)
  LOG.info("Retreiving cast member '#{cst[:name]}' info at #{cst[:link]}")
  doc_tree = Nokogiri::HTML(fetch(cst[:link]))
  # Date in format YYYY-MM-DD
  born_date = doc_tree.xpath("//*[@id='name-born-info']//time/@datetime")
  movie_date = mov[:date]
  age = parse_age(born_date.to_s, movie_date)
  LOG.debug("#{cst[:name]} => #{age}")
  age
end

# Get all the movies and their average ages
def get_all_ages
  LOG.info("Retrieving stats...")
  movies = get_now_showing_movies
  movies.map do |mov|
    mov[:date] = get_movie_show_date(mov)
    cast = get_movie_cast(mov)
    LOG.debug("Movie has #{cast.count} member(s)")
    ages = cast.map {|c| get_cast_member_age(c, mov)}
    ages = ages.inject([]) {|t,a| t << a if a; t} # clean out nils
    LOG.debug("Ages were found for #{ages.count} out of #{cast.count} member(s).")
    if ages.count == 0
      LOG.info("Movie (#{mov[:name]}) has no cast members with known birthdates")
      mov[:avg] = "n/a"
    else
      mov[:avg] = (ages.inject {|t,a| t + a }) / ages.count
    end
    mov
  end
end

# Execute only when this isn't a required lib
if __FILE__ == $0
  puts "Here are the movies showing according to: #{IMDB_NOW_SHOWING_URL}"
  puts "Average age for movies showing:"
  movs = get_all_ages.each do |m|
    puts m[:name] + ' => ' + m[:avg].to_s
  end
  puts "\nThat it, all #{movs.count} movies showing."
end
