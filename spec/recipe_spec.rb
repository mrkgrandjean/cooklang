require 'spec_helper'

RSpec.describe 'Recipe' do
  context '.parse' do
    let(:file) do
      Tempfile.new('simple.cook').tap do |f|
        f << ">> source: https://www.markgrandjean.com/recipes\n"
        f << ">> nutrition: eggs!\n"
        f << "\n"
        f << "-- This is a comment\n"
        f << "\n"
        f << "whisk @eggs{2} in #bowl with @milk{2%tbsp}\n"
        f << "\n"
        f << "\n"
        f << "-- this is another comment\n"
        f << "Cook in #large skillet{} for ~{2%minutes}\n"
        f << "\n"
        f.close
      end
    end

    let(:recipe) { Cooklang::Recipe.parse(file.path) }
    it 'names the recipe the file name' do
      expect(recipe.name).to eq "simple"
    end
    it 'gets the instruction steps' do
      expect(recipe.steps).to match_array ["whisk @eggs{2} in #bowl with @milk{2%tbsp}", "Cook in #large skillet{} for ~{2%minutes}"]
    end
    it 'pulls in the metadata' do
      expect(recipe.metadata).to match_array ["source: https://www.markgrandjean.com/recipes", "nutrition: eggs!"]
    end
    it 'pulls in the comments' do
      expect(recipe.comments).to match_array ["This is a comment", "this is another comment"]
    end
  end
  context "#instructions" do
    it 'removes the cookware markup' do
      recipe = Cooklang::Recipe.new steps: ["Place in #large bowl{}"]
      expect(recipe.instructions).to eq ["Place in large bowl"]
    end
    it 'removes the ingredient markup' do
      recipe = Cooklang::Recipe.new steps: ["Whisk @egg{2}"]
      expect(recipe.instructions).to eq ["Whisk egg"]
    end
    it 'removes the timer markup' do
      recipe = Cooklang::Recipe.new steps: ["Whisk for ~{2%minutes}"]
      expect(recipe.instructions).to eq ["Whisk for 2 minutes"]
    end
    it 'removes the cookware markup single word at end of line' do
      recipe = Cooklang::Recipe.new steps: ["Place in #bowl"]
      expect(recipe.instructions).to eq ["Place in bowl"]
    end
    it 'removes the cookware markup single word partway through' do
      recipe = Cooklang::Recipe.new steps: ["Place in #bowl to rise"]
      expect(recipe.instructions).to eq ["Place in bowl to rise"]
    end

    it 'removes the ingredient markup single word' do
      recipe = Cooklang::Recipe.new steps: ["Whisk @egg"]
      expect(recipe.instructions).to eq ["Whisk egg"]
    end

    it 'removes the ingredient markup single word partway through' do
      recipe = Cooklang::Recipe.new steps: ["Whisk @egg until smooth"]
      expect(recipe.instructions).to eq ["Whisk egg until smooth"]
    end

    it 'handles the case with all' do
      recipe = Cooklang::Recipe.new steps: ["Whisk @egg and @milk{2%tbsp} in #bowl until smooth using a #whisk{} about ~{2%minutes}"]
      expect(recipe.instructions).to eq ["Whisk egg and milk in bowl until smooth using a whisk about 2 minutes"]
    end
  end
end
