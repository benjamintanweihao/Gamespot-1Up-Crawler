################################################################
# 1UP Web Scrapper                                             #
#                                                              #
# Coded by Benjamin Tan                                        #
#                                                              #
# This class provides a set of methods to scrap reviews from   # 
# 1UP.com. The parser would be used inconjuction with a        # 
# crawler.                                                     #
# ##############################################################

require "hpricot"
require "open-uri"

base_url   = "http://www.1up.com"
review_url = "/do/reviews?ct=REVIEW&view=list&"
doc = Hpricot(open(base_url+review_url)) 

game_review_links = {}
page_info_links = []

links = doc.search("//a[@href]")

links.each do |l|
	
	link = l.to_s

	# Determine the number of pages
	if link.include?("/do/reviews?ct=REVIEW&view=list&&pageNum")
		page_info_links << l.inner_text.to_i 
	end

	# Add links of review pages
	if /(do\/reviewPage\?cId=\w+&p=\w+)/ =~ link
		game_review_links[l.inner_text] = base_url + l.attributes['href']
		puts l.inner_text
	end
end

total_num_pages = page_info_links.max
puts "Total num of pages: #{total_num_pages}."

(2..total_num_pages).each do |p|

	# Be polite with 1UP's servers
	sleep(rand(10))
	
	doc = Hpricot(open(base_url+review_url+"pageNum="+p.to_s))
	links = doc.search("//a[@href]")

	links.each do |l|
	
		link = l.to_s
		# Add links of review pages
		if /(do\/reviewPage\?cId=\w+&p=\w+)/ =~ link
			game_review_links[l.inner_text] = base_url + l.attributes['href']
			puts l.inner_text
			
		end

	end
end

game_review_links.each do |game,link|
	puts "#{game} : #{link}"
end
