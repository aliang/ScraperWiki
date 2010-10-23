# this is for "Irish Legislation"

# how to use:
# install ruby -- see rubylang.org
# install mechanize: (type at terminal on a mac)
# gem install mechanize

require 'rubygems'
require 'mechanize'
require 'nokogiri'

# return the bill info from the fetched page
def parse_bill(page)
  title = page.search("title")
  name = title[0].content.sub(/ - Tithe an Oireachtais$/, "") if title[0]
  
  meta = page.search("//meta[@name='Abstract']")
  abstract = meta[0]['content'] if meta[0]
  
  # update the description with full description, since it could be cut off
  # doesn't work right yet, we might have to dive into the hr tags again
  # description = page.search("div.column-center-inner p").map { |p|
  #   p.content.include?(description) ? p.content : nil }.compact[0]
  
  puts name
  [name, abstract]
=begin
  # OLD METHOD
  # take all the text between the first two <hr> tags
  # for now, don't get the rest, because you'd have to parse word, pdf, etc
  # a lot of it is the debate information
  
  # between first two is name
  # between second and third is description
  node = page.search("hr")[0]
  # need to collect all the nodes until the next hr
  name_nodes = []
  while node = node.next
    break if node.name == "hr"
    name_nodes << node
  end
  
  name = nil
  name_nodes.each do |nn|
    # search for "strong" because that's the markup they use for the name
    if nn.name == "strong" && nn.content && nn.content.strip != ""
      name = nn.content
    else
      strong = nn.search("strong")
      name = strong[0].content.strip if strong[0]
    end
    break if name
  end
    
  node = page.search("hr")[1]
  # collect all nodes until end of description
  desc_nodes = []
  while node = node.next
    break if node.name == "hr"
    desc_nodes << node
  end
  # parse the description into a string of some sort?
  # we could just keep the HTML for now.
=end
end

# goes from year 1997-2010, edit this as needed
years = (1997..2010)
agent = Mechanize.new

# collect all the bills in this data structure
bill_info = []

years.each do |year|
  base_url = "http://www.oireachtas.ie/viewdoc.asp?DocID=-1&StartDate=1+January+#{year}&CatID=59"
  # are there multiple pages? if so, collect them all
  page = agent.get(base_url)
  page_links = page.search("p.bodytext a.bodytext")
  page_urls = page_links.map { |pl| pl['href'] }
  
  # on this page, get all the bill urls
  bill_urls = page.search("div.column-center-inner a").map { |a|
    (a['href'] =~ /DocID=\d+/ && a.content =~ /\[view more\]/) ? a['href'] : nil }.compact
  
  # on each of the other pages for this year, get all the bills
  page_urls.each do |url|
    page = agent.get(url)
    bill_urls = bill_urls + page.search("div.column-center-inner a").map { |a|
      (a['href'] =~ /DocID=\d+/ && a.content =~ /\[view more\]/) ? a['href'] : nil }.compact
  end
  
  # now for each bill, parse its "more info page"
  # TODO: write out directly to scraper wiki api
  bill_info = bill_info + bill_urls.map { |bill_url|
    page = agent.get(bill_url)
    info = parse_bill(page)
    info ? info : nil
  }.compact
end

# replace with scraper wiki api
fh = File.open("99_output.txt", "w")
bill_info.each do |bi|
  fh.puts(bi.join(","))
end