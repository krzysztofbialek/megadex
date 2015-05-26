require 'sinatra'
require "net/http"
require 'uri'
require 'byebug'

MEGADEX_URL = URI('http://www.galeriasmaku.com.pl/zoliborz/admin/get.php')
DAYS = {1 => 'pon', 2 => 'wt', 3 => 'sr', 4 => 'czw', 5 => 'pi'}

before do
  content_type :html, 'charset' => 'utf-8'
end

get '/' do
  get_lunch
end

def get_lunch
  res = Net::HTTP.get(MEGADEX_URL)
  menu = retrieve_data(res.force_encoding("UTF-8"))
  menu.to_s
end

def retrieve_data(res)
  day = DAYS[Time.now.wday]
  hash = prepare_hash(res)
  menu_for_day = hash.select {|k,v| k =~ /^#{day}_/} 
end

def prepare_hash(h)
  Hash[h.split('&').map{ |s| s.split('=')}]
end
