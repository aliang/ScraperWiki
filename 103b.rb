# austrian schools
# http://www.schule.at/index.php?url=schuleNew&startseite=&start=1&anzahl=1&typ=VS

require 'rubygems'
require 'mechanize'
require 'nokogiri'

start = 1
number_of_schools = 3349
agent = Mechanize.new

until start > number_of_schools * 2 # they won't add that many at once right?
  search_url = "http://www.schule.at/index.php?url=schuleNew&startseite=&start=#{start}&anzahl=1&typ=VS"
  search_page = agent.get(search_url)
  
  links = search_page.search("div.schoolName a")
  break if links.size == 0 # this is the real condition to break
  links.each do |link|
    result = {}
    page = agent.get("http://www.schule.at" + link['href'])
    result['Name'] = link.content.strip
    page.search("td.tdLeft").each do |left|
      key = left.content.strip.downcase
      value = left.next_element.content.strip
      if key =~ /E\-?Mail/i
        # it's in javascript
        value =~ /var ema1l = "(.*?)"/
        user = $1
        value =~ /var ema1lHost = "(.*?)"/
        domain = $1
        result[key] = "#{user}@#{domain}"
      else
        result[key] = value
      end
    end
    result.each_pair do |k,v|
      puts "#{k}|||#{v}"
    end
    puts "---"
  end
  
  start = start + 15
end