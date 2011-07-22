require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'

SERVER = "irc.gibsonbigiron.net"
CHANNELS = ["#datacenter"]
NICK = "rugby"

class Memo < Struct.new(:nick, :channel, :text, :time)
  def to_s
    "[#{time.asctime}] #{channel} <#{nick}> #{text}"
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = SERVER
    c.nick     = NICK
    c.channels = CHANNELS

    @memos     = {}
    @autoop    = true
  end

  helpers do
    def google(query)
      url = "http://www.google.com/search?q=#{CGI.escape(query)}"
      res = Nokogiri::HTML(open(url)).at("h3.r")

      title = res.text
      link = res.at('a')[:href]
      desc = res.at("./following::div").children.first.text
    rescue
      "No results found"
    else
      CGI.unescape_html "#{title} - #{desc} (#{link})"
    end

    def shorten(url)
      url = open("http://tinyurl.com/api-create.php?url=#{URI.escape(url)}").read
      url == "Error" ? nil : url
    rescue OpenURI::HTTPError
      nil
    end

  end

  on :join do |m|
    unless m.user.nick == bot.nick
      m.channel.op(m.user) if @autoop
    end
  end

  on :message, /^!autoop (on|off)$/ do |m, option|
    @autoop = option == "on"
    m.reply "Autoop is now #{@autoop ? "enabled" : "disabled" }"
  end

  on :message, /^!google (.+)/ do |m, query|
    m.reply google(query)
  end

  on :message do |m|
    if @memos.has_key?(m.user.nick)
      @memos[m.user.nick].each { |memo| m.user.send memo.to_s }
      @memos.delete(m.user.nick)
    end
  end

  on :message, /^!tell (.+?) (.+)/ do |m, nick, message|
    if nick == m.user.nick
      m.reply "You can't leave a memo for yourself retard."
    elsif nick == bot.nick
      m.reply "You can't leave memos for the bot retard."
    else
      memo = Memo.new(m.user.nick, m.channel, message, Time.now)
      if @memos[nick]
        @memos[nick] << memo
      else
        @memos[nick] = [memo]
      end
      m.reply "Added memo for #{nick}"
    end
  end

  on :message, /^!shorten (.+)/ do |m, url|
    urls = URI.extract(url, "http")

    unless urls.empty?
      short_urls = urls.map {|url| shorten(url) }.compact

      unless short_urls.empty?
        m.reply short_urls.join(", ")
      end
    end
  end
end

bot.start
