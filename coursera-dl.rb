require "mechanize"
require "mechanize/http/content_disposition_parser"
require "uri"

if ARGV.size < 3
  puts "ruby coursera-dl.rb <username> <password> <course>"
  exit 1
end

username = ARGV[0]
password = ARGV[1]
course_name = ARGV[2]
preview_str = (ARGV[3]) ? "preview/" : ""

@agent = Mechanize.new
# Login to the coursera site
site = @agent.get("http://class.coursera.org/#{course_name}/auth/auth_redirector?type=login&subtype=normal&email=&visiting=&minimal=true")
login_form = site.forms.first

login_form.email = username
login_form.password = password

@agent.submit(login_form, login_form.buttons.first)

# Load the lecture site
content_site = @agent.get("https://class.coursera.org/#{course_name}/lecture/#{preview_str}index")
@agent.pluggable_parser.default = Mechanize::Download

def parse_lectures(page)
  lectures = []
  page.links.each do |link|
    unless (link.uri.to_s =~ URI::regexp).nil?
      uri = link.uri.to_s
      if (uri =~ /\.mp4/) || (uri =~ /srt/) || (uri =~ /\.pdf/) || (uri =~ /\.pptx/)
        lectures << {:name => link.text, :link => uri}
      else
        link.attributes.each do |attribute|
          if attribute[0] == "data-lecture-view-link"
            lectures << {:name => link.text, :link => grab_hidden_video_url(attribute[1])}
          end
        end
      end
    end
  end
  download_lectures(lectures)
end

def grab_hidden_video_url(uri)
  puts uri.to_s
  page = @agent.get(uri)
  nodes = page.search("source")
  url = ""
  nodes.each do |node|
    node.attributes.each do |attribute|
      if attribute[0] == "src"
        link = attribute[1]
        if (link.to_s =~ /\.mp4/)
          url = link.to_s
        end
      end
    end
  end
  url
end

def download_lectures(lectures)
  lectures.each do |lecture|
    if lecture[:link]
      # Replace unwanted characters from the filename
      filename = lecture[:name].strip
      filename = filename.gsub(":","").gsub("_","").gsub("/","_")
      filename = "#{filename}.mp4"
      uri = lecture[:link]

      if File.exists?(filename)
        p "Skipping #{filename} as it already exists"
      else
        p "Downloading #{uri} to #{filename}..."
        gotten = @agent.get(uri)
        gotten.save(filename)
        p "Finished"
      end
    end
  end
end

parse_lectures(content_site)

