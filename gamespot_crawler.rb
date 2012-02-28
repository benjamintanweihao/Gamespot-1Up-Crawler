#!/usr/bin/ruby

########################
# GameSpot.com Crawler # 
# @author Benjamin Tan #
########################

require "hpricot"
require "open-uri"

$output_file = open("gamespot_results.txt","w")
$title = ""
$genre = ""
$release = ""

BASE_URL = "http://www.gamespot.com/games.html?type=games&platform=5&mode=all&sort=views&dlx_type=all&sortdir=asc&official=all"
GAMESPOT_URL = "http://www.gamespot.com"


def return_review_value_from_parser(doc, value)
	begin
		doc.search(value).first.inner_text
	rescue NoMethodError
		-1	
	end
end

def return_big_boxart_url_from_parser(doc, value)
	begin
		GAMESPOT_URL + doc.search(value).first.attributes['href']
	rescue NoMethodError
		nil
	end
end

def get_big_boxart(boxart_url)
	begin
		doc3 = Hpricot(open(boxart_url))
		doc3.search("div[@class*=boxshot]/img").first.attributes['src']
	rescue NoMethodError
		nil
	end
end

def get_pic_and_review_score(gameurl)
	# Continue process if score is not null
		
		doc2 = Hpricot(open(gameurl))
		
		critics_score_parse_str = "li[@class*=review_score critic_score]/div/span/a"
		critics_scores = return_review_value_from_parser(doc2, critics_score_parse_str)
		users_scores_parse_str  = "li[@class*=review_score community]/div/span/a"
		users_scores  = return_review_value_from_parser(doc2, users_scores_parse_str)

		boxart_url = return_big_boxart_url_from_parser(doc2, "div[@class*=boxshot]/a")
		
		if(boxart_url)
		
			big_boxart_url = get_big_boxart(boxart_url)
		
			if(big_boxart_url)
				result = [$title, $genre, $release, critics_scores, users_scores, big_boxart_url].join("|")
				puts result
				$output_file.puts(result)
			end   <div class="Section1">
		end
end


doc = Hpricot(open(BASE_URL))

#total_num_pages = Integer(doc.search("a[@class*=playstation]").last.inner_text)
total_num_pages = Integer(doc.search("a[@class*=pc]").last.inner_text)

(260..total_num_pages).each do |page|
	puts "Processing page " + page.to_s

	url_append = "&page="+(page-1).to_s
	doc = Hpricot(open(BASE_URL+url_append))
	
	doc.search("table/tbody/tr").each do |row|
		$title   = row.search("th/a").inner_text
		$genre   = row.search("td").first.inner_text
		$release = row.search("td").last.inner_text
		score   = row.search("td[@class*=score]").inner_text
		gameurl = GAMESPOT_URL + row.search("a").first.attributes['href']

		if(score.to_s.length)
			get_pic_and_review_score(gameurl)
		end

	end	
end


