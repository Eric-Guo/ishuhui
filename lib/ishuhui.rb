require "ishuhui/version"
require "thor"
require 'nokogiri'
require 'open-uri'

module Ishuhui
  class IshuhuiComic < Thor
    ISHUHUI_URL = "http://www.ishuhui.com/"

    desc "download [URI]", "下载目标URL下的漫画，到ishuhui目录下"

    def download (url)
      @page = parse_page(url)
      @title = @page.css("hgroup h1").text.to_s
      create_folder("ishuhui")
      Dir.chdir("ishuhui")
      create_folder(@title)
      imgs = @page.css("div.article-content img")
      imgs.each_with_index do |img, i|
        puts "downloading #{i + 1}/#{imgs.count}"
        download_img(img[:src])
      end
      puts "all done in the folder below:\n ./ishuhui/#{@title}"
    end

    private

    def parse_page (url)
      Nokogiri::HTML(open(url.to_s))
    end

    def download_img (img_url)
      img_file = open(img_url.to_s) { |f| f.read }
      file_name = img_url.split('/').last
      open(@title + "/#{file_name}", "wb") { |f| f.write(img_file) }
    end

    def create_folder (name)
      Dir.mkdir(name)  unless Dir.entries(Dir.pwd).include?(name)
    end

  end
end
