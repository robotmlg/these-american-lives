import urllib3
import certifi
import csv
import argparse

from bs4 import BeautifulSoup
from dateutil.parser import parse
from time import sleep

BASE_URL = "https://www.thisamericanlife.org"

class Episode:
    def __init__(self, relative_url, http):
        print("Getting episode from " + relative_url)
        url = BASE_URL + relative_url
        html = http.request('GET', url)

        soup = BeautifulSoup(html.data, "html.parser")
        blob = soup.find("div", class_="top-inner")
        
        header = blob.h1.text
        first_space = header.index(" ")

        self.number = int(header[:first_space-1])
        self.name = header[first_space+1:]
        date_str = blob.find("div", class_="date").text
        self.date = parse(date_str).date()
        self.description = blob.find("div", class_="description").text.strip()
        self.image = "https:" + blob.img["src"]
        self.link = url

    def asList(self):
        return [self.number, self.name, str(self.date), self.description, self.image, self.link]

def getEpisodesForYear(year, http):
    print("Getting episodes for " + str(year))
    url = BASE_URL + '/radio-archives/' + str(year)
    html = http.request('GET', url)

    soup = BeautifulSoup(html.data, "html.parser") 
    item_list = soup.find("div", id="archive-episodes")
    episodes_soup = item_list.find_all("div", class_="episode-archive")

    episodes = []
    for episode in episodes_soup[::-1]: # flip the reverse-chronological list
        link = episode.find("a", class_="image")["href"]
        try:
            episodes.append(Episode(link, http))
        except:
            continue
        sleep(0.5)

    return episodes

def getEpisodes(start, end, csv_file):
    print("Getting TAL episodes for " + str(start) + " through " + str(end))
    end += 1
    http = urllib3.PoolManager(
        cert_reqs='CERT_REQUIRED',
        ca_certs=certifi.where())
    episodes_by_year = [getEpisodesForYear(year, http) for year in range(start, end)]
    episodes = [e for year_list in episodes_by_year for e in year_list]

    with open(csv_file, 'w') as my_csv:
        wr = csv.writer(my_csv)
        wr.writerow(['episode_id', 'title', 'airdate', 'description', 'image_url', 'episode_url'])
        wr.writerows([e.asList() for e in episodes])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = """
        Build a CSV of metadata of This American Life episodes
        """)
    parser.add_argument('start', metavar='start', type=int, default=1995,
                        help='year to begin at')
    parser.add_argument('end', metavar='end', type=int, default=2017,
                        help='year to end at')
    parser.add_argument('file', metavar='file', type=str, default='episodes.csv',
                        help='name of output file')

    args = parser.parse_args()
    getEpisodes(args.start, args.end, args.file)
