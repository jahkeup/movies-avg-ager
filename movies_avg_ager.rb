#!/usr/bin/env ruby
require 'nokogiri'
require 'net/http/persistent'
require 'date'
require 'logger'
require 'pry'


IMDB_BASE = 'http://www.imdb.com'
IMDB_NOW_SHOWING_URL = IMDB_BASE + '/movies-in-theaters/'
HTTP = Net::HTTP::Persistent.new('movies')
LOG = Logger.new(STDERR)
LOG.level = Logger::DEBUG

def fetch(url)
  HTTP.request(URI url).body
end

# Get the movies that are currently in theater
def get_now_showing_movies()
  LOG.info("Fetching all movies that are showing.")
  doc_tree = Nokogiri::HTML(fetch(IMDB_NOW_SHOWING_URL))
  nodes = doc_tree.xpath("//div[@itemscope]//h4[@itemprop='name']/a")
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
    link: imdb_link(node['href'].split("?")[0]),
    name: node.text.lstrip.rstrip
  }
end

# Get the cast for a given movie link
def get_movie_cast(mov)
  LOG.info("Retrieving movie cast for #{mov[:name]}")
  doc_tree = Nokogiri::HTML(fetch(mov[:link] + "fullcredits"))
  cast = doc_tree.xpath("//table[@class='cast_list']//td[@itemprop='actor']/a")
  cast.collect { |c| link_from_node(c) }
end

# Parse a string date (1983-8-12) to an age in years
def parse_age(datestr)
  LOG.debug("Cast member birthdate: '#{datestr}'")
  # Some actors don't have their age, they're up and coming actors
  if datestr.empty?
    LOG.debug("Cast member's birthdate is not available.")
    return nil
  end

  # If missing the birth month/day, just use the year they were born
  datestr = datestr.split('-')[0] + "-1-1" if datestr =~ /-0-0/

  begin
    birthdate = DateTime.parse(datestr.to_s)
  rescue ArgumentError
    LOG.debug("The date time format was invalid, skipping this cast member.")
    return nil
  end
  age = (DateTime.now - birthdate).to_i / 365
end

# Get age of the cast member
def get_cast_member_age(cst)
  LOG.info("Retreiving cast member '#{cst[:name]}' info at #{cst[:link]}")
  doc_tree = Nokogiri::HTML(fetch(cst[:link]))
  # Born date in format YYYY-MM-DD
  born_date = doc_tree.xpath("//*[@id='name-born-info']//time/@datetime")
  age = parse_age(born_date.to_s)
  LOG.debug("#{cst[:name]} => #{age}")
  age
end

def get_all_ages
  LOG.info("Retrieving stats...")
  movies = get_now_showing_movies
  movies.map do |mov|
    cast = get_movie_cast(mov)
    LOG.debug("Movie has #{cast.count} member(s)")
    ages = cast.map {|c| get_cast_member_age(c)}
    mov[:ages] = ages
    ages = ages.inject([]) {|t,a| t << a if a; t} # clean out nils
    LOG.debug("Ages were found for #{ages.count} out of #{cast.count} member(s).")
    mov[:avg] = (ages.inject {|t,a| t + a }) / ages.count
    mov
  end
end

if __FILE__ == $0
  puts("Average age for movies showing:")
  get_all_ages.each do |m|
    puts(m[:name] + ' => ' + m[:avg].to_s)
  end
end
