require 'sinatra'
require "net/http"
require 'uri'
require 'byebug'


DAYS = {1 => 'pon', 2 => 'wt', 3 => 'sr', 4 => 'czw', 5 => 'pi'}

before do
  content_type :html, 'charset' => 'utf-8'
end

get '/' do
  response.headers['Access-Control-Allow-Origin'] = '*'

  day = params[:text].empty? ? Time.now.wday : params[:text].to_i
  get_lunch(day)
end

def get_lunch(day)
  menu = MegadexMenu.new
  menu.for_date(DAYS[day])
end


class MegadexMenu
  MEAL_TYPES = {
    "spec" => "danie specjalne",
    "wege" => "danie wegetariańskie"
  }

  MEGADEX_URL = URI('http://www.galeriasmaku.com.pl/zoliborz/admin/get.php')
  DAYS_PREFIXES = %w{pon wt sr czw pi}

  def retrieve_data
    res = Net::HTTP.get(MEGADEX_URL).force_encoding("UTF-8")
      hash = prepare_hash(res)
    end

  def prepare_hash(h)
    Hash[h.split('&').map{ |s| s.split('=')}]
  end

  def for_date(day=nil)
    menu[day].map {|type, meal| "#{type}: #{meal}" }.join("\n")
  end

  def menu
    @info ||= retrieve_data
    @week ||= @info.delete("tydzien")
    days = @info.group_by { |k, _| k.split("_").first }.map do |day, daily_menu|
      next unless DAYS_PREFIXES.include?(day)
      day_menu = daily_menu.map do |key, meal|
        meal_type = key.split("_")[1..-1].join(" ")
        meal_type = MEAL_TYPES[meal_type] || meal_type
        [meal_type, meal]
      end
      [day, day_menu]
    end
    Hash[days.compact]
  end

end
