from lxml.html import fromstring
from scrapelib import Scraper, FileCache
import unicodecsv
import os

s = Scraper(requests_per_minute=60)
s.cache_storage = FileCache('walmart_listcache')
s.cache_write_only = False

def list_page(search_page):
	response = s.urlopen(search_page)
	doc = fromstring(response)

	nextlink = doc.find_class('next')
	href = nextlink[0].attrib['href']

	results_list = doc.get_element_by_id('results_list')
	results = results_list.findall('li')
	for release in results:
		description_div = release.find_class('description')[0]
		link = description_div.findall('a')[0]
		date = release.find_class('date')[0]
		description = release.find_class('desc')[0]

		release_href = link.attrib['href']
		date_text = date.text_content()
		description_text = description.text_content()
		title = link.text_content()

		writer.writerow([title, release_href, date_text, description_text])

	if 'disabled' not in nextlink[0].attrib['class']:
		list_page(href)

if __name__ == '__main__':
	os.remove('scrapedsearch.csv')
	writer = unicodecsv.writer(open('scrapedsearch.csv', 'a'))
	writer.writerow(['title', 'link', 'date', 'description'])
	list_page('http://news.walmart.com/news-archive/?q=open%20shoppers')

