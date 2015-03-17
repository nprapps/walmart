from glob import glob
import os
import re

from lxml.html import fromstring
import unicodecsv


def get_file():
    for path in glob('data/*.txt'):
        with open(path, 'r') as f:
            html = fromstring(f.read())
            parse_html(html, path)

def parse_html(html, path):
    data = {}

    filename = path.split('/')[1]
    components = filename.split('-')
    year = components[0]

    try:
        body = html.findall('body')[0]

        # Get the title
        divider = body.find_class('divider')[0]
        h1 = divider.findall('h1')[0]
        # Skip titles about new designs
        if 'Unveils New Design' in h1.text_content():
            return
        data['title'] = h1.text_content()
        print h1.text_content()

        # Get all of the lists
        fulltext = html.find_class('rte')[0]
        uls = fulltext.findall('ul')
        if not uls:
            # Sometimes, there's a weird <value> tag inside of rte
            value_tag = fulltext.find_class('Text')[0]
            uls = value_tag.findall('ul')
            txt = value_tag.text_content()
        else:
            txt = fulltext.text_content()

    # if this stuff failed, this html does not match.
    # skip the file
    except:
        print '%s failed' % path
        return

    for ul in uls:
        # Get all the items in the list
        items = ul.findall('li')

        for item in items:
            # Search for various predictable beginnings
            if item.text_content().startswith('Location:'):
                data['location'] = item.text_content()

            if 'located at' in item.text_content() and not 'Formerly' in item.text_content():
                data['location'] = item.text_content()

            if item.text_content().startswith('Grand opening:'):
                data['opening'] = item.text_content()

            if item.text_content().startswith('Store opens at'):
                data['opening'] = item.text_content()


    # If we still haven't found anything, revert to regex
    if not data.get('location'):
        r = re.search(r'(located\s)?(at)(\s)(\d+\s)(\S+\s){4}', txt)
        if r:
            print r.group()
            data['location'] = r.group()

    if not data.get('opening'):
        r = re.search(r'([Oo]pe\w+)(\s\w+)?(\s)([M,T,W,F,S]\w+)(,\s)(\w+)(\W+\d+)', txt)

        if r:
            print r.group()
            data['opening'] = r.group()

    writer = unicodecsv.writer(open('cleaned_data.csv', 'a'))
    writer.writerow([data.get('title'), data.get('location'), data.get('opening'), year])

if __name__ == '__main__':
    os.remove('cleaned_data.csv')
    get_file()