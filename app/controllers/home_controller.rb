class HomeController < ApplicationController
  require 'csv'


  def Index
    # pdf_filename = 'public/fichier_source_ex_2.pdf'
    # # reader = PDF::Reader::Turtletext.new(pdf_filename)
    # reader = PDF::Reader.new(pdf_filename)
    # command = ['pdftotext', Shellwords.escape(pdf_filename)].join(' ')
    # `#{command}`
    #
    #
    #
    # reader = PDF::Reader::Turtletext.new("public/fichier_source_ex_2.pdf")
    #
    #
    #

    # require 'csv'
    # file = "public/my_file.csv"
    # CSV.open( file, 'w' ) do |writer|
    #   @coun.each do |c|
    #     writer << [c.name, c.country_code, c.user_id, c.subscriber_id]
    #   end
    # end
    receiver = PDF::Reader::RegisterReceiver.new
    reader = PDF::Reader.new("public/fichier_source_ex_1.pdf")

    Line.destroy_all
    reader.pages.each_with_index do |page,indexp|
      @rang=Line.count+1
      firstpage = reader.pages[indexp]
      secondpage = reader.pages[indexp+1]
      secondpage = reader.pages[0] if secondpage.nil?



      dynamiqueLines = getting_dynamique_Lines(firstpage.text,secondpage.text)
      linesWithoutRang = adding_first_column(dynamiqueLines,"page#{indexp+1}")

      linesWithoutDossard = adding_next_column(linesWithoutRang,4,"dossard")
      linesWithoutName = adding_name_column(linesWithoutDossard,"fullname")
      linesWithoutTime = adding_next_column(linesWithoutName,8,"temps")
      linesWithoutCat = adding_next_column(linesWithoutTime,3,"cat")
      linesWithoutRangCat  = adding_rang_cat_column(linesWithoutCat,"rangcat")
      linesWithoutEcart = adding_next_column(linesWithoutRangCat,8,"ecart")
      linesWithoutEcartCat = adding_next_column(linesWithoutEcart,8,"ecartcat")
      linesWithoutClub  = adding_Club_column(linesWithoutEcartCat,"club")
      linesWithoutVitesse  = adding_vitesse_column(linesWithoutClub,"vitesse")
      adding_temp_column(linesWithoutVitesse,"tempsaukm")

      # binding.pry
    end


    generate_csv()

  end
  def getting_dynamique_Lines(firstpage,secondpage)
    startLine = 0
    firstpage.lines.each_with_index do |line,indexl|
      if !firstpage.lines[indexl].eql?(secondpage.lines[indexl])
        startLine = indexl

        break;
      end

    end

    totalLine= firstpage.lines.length-2
    return newlines= firstpage.lines[startLine .. totalLine]
  end

  def adding_first_column(oldData,pageindex)
    newData= []
    oldData.each_with_index do |line,indexl|
      numbrCharToRemove = (@rang+indexl).to_s.length
       # el = Line.create(rang: indexl+1,page: pageindex)
      el = Line.create(rang: @rang+indexl,page: pageindex)

        el.save!
        puts indexl+1

        newData.push(line.split("\n").first.slice!(numbrCharToRemove, line.split("\n").first.length))
    end

    return newData
  end

  def adding_next_column(oldData,numbrCharToRemove,column)
    newData= []
    el = nil
    oldData.each_with_index do |line,indexl|
        # puts line.split("\n").first.slice!(0,numbrCharToRemove )
        if !line.blank?
          data = line.split("\n").first.slice(0,numbrCharToRemove )



          el = Line.where(rang: @rang+indexl)
          el.update("#{column}": data)
          puts data
          newData.push(line.split("\n").first.slice!(numbrCharToRemove, line.split("\n").first.length))
        end
    end

    return newData
  end

  def adding_name_column(oldData,column)
    newData= []
    el = nil
    oldData.each_with_index do |line,indexl|
      tabs = line.split /(?<=[a-zA-Z[ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ_-]])(?=[0-9])/
      name = tabs.first
      numbrCharToRemove = tabs.first.length

      el = Line.where(rang: indexl+@rang)
      el.update("#{column}": name)
      puts name
      newData.push(line.split("\n").first.slice!(numbrCharToRemove, line.split("\n").first.length))
    end

    return newData
  end

  def adding_rang_cat_column(oldData,column)
    newData= []
    oldData.each_with_index do |line,indexl|
      tabs = line.split   /(?=[0-9][0-9]:[0-9])/
      rang_cat = tabs.first
      numbrCharToRemove = tabs.first.length

      el = Line.where(rang: indexl+@rang)
      el.update("#{column}": rang_cat)
      puts rang_cat
      newData.push(line.split("\n").first.slice!(numbrCharToRemove, line.split("\n").first.length))
    end

    return newData
  end

  def adding_Club_column(oldData,column)
    newData= []
    oldData.each_with_index do |line,indexl|
      tabs = line.split   /(?=[0-9][,])/
      club = tabs.first
      numbrCharToRemove = tabs.first.length
      el = Line.where(rang: indexl+@rang)
      el.update("#{column}": club)
      puts club
      newData.push(line.split("\n").first.slice!(numbrCharToRemove, line.split("\n").first.length))
    end

    return newData
  end

  def adding_vitesse_column(oldData,column)
    newData= []
    oldData.each_with_index do |line,indexl|
      tabs = line.split   /(?=,)/
      if !tabs.second.nil?
        vitesse = tabs.first+  tabs.second.slice(0,4)
        numbrCharToRemove = vitesse.length
        el = Line.where(rang: indexl+@rang)
        el.update("#{column}": vitesse)
        puts vitesse
        newData.push(line.split("\n").first.slice!(numbrCharToRemove, line.split("\n").first.length))
      end
    end

    return newData
  end

  def adding_temp_column(oldData,column)
    oldData.each_with_index do |line,indexl|

      el = Line.where(rang: indexl+@rang)
      el.update("#{column}": line)
      puts line
    end
  end
  def generate_csv
    file = "#{Rails.root}/public/#{Time.current.to_time.to_i}.csv"

    lines = Line.all

    column_headers = ["rang", "dossard", "fullname", "temps","cat", "rangcat", "ecart", "ecartcat", "club", "vitesse", "tempsaukm"]

    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      lines.each do |l|
        writer << [l.rang, l.dossard, l.fullname, l.temps,l.cat, l.rangcat, l.ecart, l.ecartcat, l.club, l.vitesse, l.tempsaukm]
      end
    end
  end
end
