import codecs
import csv
import urlparse

from scrapelib import Scraper, FileCache, HTTPError

s = Scraper(requests_per_minute=60)
s.cache_storage = FileCache('walmart_cache')
s.cache_write_only = False

def read_csv():
	with open('scrapedsearch.csv', 'rb') as f:
		reader = csv.DictReader(f, fieldnames=["title", "link", "date", "description"])
		for row in reader:
			print row
			if row['link'] != 'link':
				scrape_release(row)

def scrape_release(row):
	path = urlparse.urlparse(row['link'])[2]
	components = path.split('/')
	if len(components) > 4:
		year = components[-4]
		month = components[-3]
		day = components[-2]
		slug = components[-1]

		filename = '%s-%s-%s-%s' % (year, month, day, slug)
	else:
		filename = path.replace('/', '-')

	response = s.urlopen(row['link'], retry_on_404=True)
	f = codecs.open('data/%s.txt' % filename, 'w', encoding='utf-8')
	f.write(response)

if __name__ == '__main__':
	read_csv()
