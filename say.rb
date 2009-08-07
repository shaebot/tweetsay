require 'rubygems'
require 'twitter'

unless ARGV.length == 2
  puts "i need a username and password: say.rb <username> <password>"
  exit
end
httpauth = Twitter::HTTPAuth.new(ARGV[0], ARGV[1])
base = Twitter::Base.new(httpauth)

def fix_stuff(str)
  pronunciation_middlewarez = {
    'robey'         => 'rowbee',
    'http://'       => ' ',
    /^\@([\w\d_]+)/ => 'at \1,'
  }
  pronunciation_middlewarez.each_pair do |k,v|
    str.gsub!(k, v)
  end
  str
end

def sayit(string, pivot=nil)
  voices = %w[alex bruce fred kathy ralph vicki]
  sayer = IO.popen("say -v #{pivot ? voices[pivot.hash % voices.length] : 'victoria'}", 'w')
  sayer.write(fix_stuff(string))
  sayer.close
end

last_id = base.friends_timeline.first.id
while true
  begin
    base.friends_timeline(:since_id => last_id).reverse.each { |tweet|
      sayit("#{tweet.user.screen_name} tweeted")
      sleep 0.5
      puts tweet.text
      sayit(tweet.text, tweet.user.screen_name)
      sleep 1
      last_id = tweet.id
    }
  rescue => e
    puts "caught a #{e.class}"
    puts e.backtrace.join("\n")
  ensure
    sleep 5
  end
end