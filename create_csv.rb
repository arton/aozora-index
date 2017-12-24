# coding: utf-8
require 'nokogiri'
require 'open-uri'

charset = 'euc-jp'

def read(uri)
  open(uri) do |f|
    content = f.read
    if content =~ /charset=([^"]+)/
      charset = $1
    else
      charset ||= f.charset
    end
    return Nokogiri::HTML.parse(content, nil, charset)
  end
end

def get_authors()
  authors = {}
  ['a', 'ka', 'sa', 'ta', 'na', 'ha', 'ma', 'ya', 'ra', 'wa'].each do |i|
    aui = read("http://www.aozora.gr.jp/index_pages/person_#{i}.html")
    aui.xpath('//ol//li//a').each do |ap|
      authors[ap.children[0].to_s.encode('utf-8')] = ap['href']
    end
  end
  authors
end

def get_titles(index)
  titles = {}
  index.xpath('//tr//td//a').each do |tp|
    if tp['href'] =~ /sakuhin_\w+\d+\.html/
      index2 = read("http://www.aozora.gr.jp/index_pages/#{tp['href']}")
      index2.xpath('//tr//td//a').each do |tp2|
        if tp2['href'] =~ /cards\/\d+\/card/
          title = tp2.children[0].to_s.encode('utf-8')
          author = tp2.parent.next.next.next.next.children.to_s.encode('utf-8')
          if titles.include?(title)
            titles[title] += [author, tp2['href']]
          else
            titles[title] = [author, tp2['href']]
          end
        end
      end
    end
  end
  titles
end

def get_fail(ans, authors)
  ret = []
  while ret.size < 2
    o = authors.keys[rand(authors.size)]
    if o != ans && !ret.include?(o)
      ret << o
    end
  end
  ret
end

index = read('http://www.aozora.gr.jp/index_pages/index_top.html')

authors = get_authors()
titles = get_titles(index)
titles.each do |k, v|
  fails = get_fail(v[0], authors)
  puts "#{k}\t#{v[0]}\t#{fails[0]}\t#{fails[1]}"
end

