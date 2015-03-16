import urlparse
import csv
import os
import re
import codecs

from lxml.html import fromstring
from scrapelib import Scraper, FileCache
import unicodecsv

s = Scraper(requests_per_minute=60)
# s.cache_storage = FileCache('walmart_cache')
# s.cache_write_only = False

def read_csv():
	with open('scrapedsearch.csv', 'rb') as f:
		reader = csv.DictReader(f, fieldnames=["link", "title", "emptytitle", "pr_date", "description", "page_number"])
		for row in reader:
			print row
			if row['link'] != 'link_1':
				scrape_release(row)

def scrape_release(row):
	path = urlparse.urlparse(row['link'])[2]
	components = path.split('/')
	year = components[2]
	month = components[3]
	day = components[4]
	slug = components[5]

	response = s.urlopen(row['link'], retry_on_404=True)
	f = codecs.open('data/%s-%s-%s-%s.txt' % (year, month, day, slug),'w', encoding='utf-8')
	f.write(response)

if __name__ == '__main__':
	read_csv()
