module Cooklang
  class Recipe
    attr_accessor :metadata, :comments, :name, :steps #, :cookware, :ingredients, :nutrition, :source,
    def initialize(metadata: [], comments: [], name: "", steps: [])
      @metadata = metadata
      @comments = comments
      @name = name
      @steps = steps
    end

    def instructions
      @steps.map do |step|
        puts step
        new_step = step.gsub(/#([^#@{]*){[^{}]*}/i, '\1')
        puts new_step
        new_step.gsub!(/#(\S*)\b/i, '\1')
        puts new_step
        new_step.gsub!(/@([^#@{]*){[^{}]*}/i, '\1')
        puts new_step
        new_step.gsub!(/@(\S*)\b/i, '\1')
        puts new_step
        new_step.gsub!(/~{([^{}%]*)%([^{}]*)}/i, '\1 \2')
        puts new_step
        new_step
      end
    end

    def self.parse(file)
      name = file.split("/").last.split(".").first
      recipe = Recipe.new name: name
      lines = File.open(file, "r").readlines
      lines.each do |line|
        line = line.strip
        next if line == ""
        if line.start_with?(">>")
          recipe.metadata << line.gsub(/>>/, '').strip
        elsif line.start_with?("--")
          recipe.comments << line.gsub(/--/, '').strip
        else
          recipe.steps << line
        end
      end
      recipe
    end
  end
end
