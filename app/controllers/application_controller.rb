class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # require 'pdf-reader'
  #
  # reader  = PDF::Reader.new("webroot/fichier_source_ex_2.pdf")
  #   binding.pry
  #   puts reader.objects.inspect
  #

end
