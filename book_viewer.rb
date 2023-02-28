require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

before do
  @contents = []
  File.open("data/toc.txt").read.split("\n").each do |chapter|
    @contents << chapter
  end
end

# home route
get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

# route for chapters
# here a redirect is used to redirect invalid chapter numbers to the home page
# the params hash is also used to access the number that is 
# passed in in place of :number.

get "/chapters/:number" do
  @number = params[:number]
  redirect "/" if !(1..(@contents.size)).cover?(@number.to_i)
  @title = "Chapter #{@number}"
  @chapter = (File.read("data/chp#{@number}.txt"))
  erb :chapter
end

# View helpers are used to edit the data by filtering, processing, etc
# Here I am using a view helper to edit the content of the chapters

helpers do
  def in_paragraphs(string)
    arr = string.split("\n\n")
    arr.map do |para, index|
      "<p>\"" + para + "\"</p>"
    end.join
  end

  def in_strong(paragraph)
    search_str = params[:query]
    paragraph.gsub(search_str, "<strong>#{search_str}</strong>")
  end
end

# the code within the not_found block executes when the user enters 
# a file path that is not valid

# the redirect sinatra method will redirect the user to the 
# file path or URL that is passed as a string to it

not_found do
  redirect "/"
end

get "/search" do
  search_str = params[:query]
  @matched_chapter_hash = {}
  @matched_chapter_paragraphs = {}
  if search_str != nil
    @contents.each_with_index do |chapter_name, index|
      cur_chapter = File.read("data/chp#{index + 1}.txt")
      @matched_chapter_hash[chapter_name] = index + 1 if cur_chapter.include?(search_str)
    end
    @matched_chapter_hash.each do |chapter, number|
      cur_chapter = File.read("data/chp#{number}.txt")
      cur_chapter.split("\n\n").each do |para|
        @matched_chapter_paragraphs[para] = number if para.include?(search_str)
      end
    end
    @matched_chapter_hash = @matched_chapter_hash.to_s if @matched_chapter_hash.empty? #changes the @matched_chapter_hash to a string object if there are no matches
    erb :search
  elsif search_str == nil
    erb :search
  end
end

# partial pseudocode for  the "/search" route

=begin
  get the search string
    - params[:query]
  check each of the chapters' contents
    - cur_num = 1
    - @matched_chapter_hash = []
    - File.read("data/chp#{@number}.txt"
    - if the search string is present in the
      file that is being read with the current number then
      - get the chapter and then add it to the @matched_chapter_hash
        - 
  check if any of the contents string match the given search string


  - from the @contents array
  - get the get the index + 1 and check if the
    string matches the content from the content there
  
  - get the query string
  - initailize an empty hash
  - if the query string is not nothing
    - using the @contents array with its values and indexes
      - use the index to set the current files content
      - if the query string matches with the current file
        then add the chapter from the @contents array to the emtpy hash
        as the key and the index + 1 as the value
=end


=begin
# partial psudocode for improving the search

Job:
  - update the search to link to specific paragraphs
    of the text that match the search phrase
    - get the search phrase
    - get the chapters that have the search phrase
    - for each of the chapters that have the search phrase, 
      - get all the paragraphs that contain the phrase

  z
=end