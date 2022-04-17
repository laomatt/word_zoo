
require_relative "word_zoo/version"
require "active_support/concern"

module WordZoo
  extend ActiveSupport::Concern
  # this is an active record concern

  # must be included in a model whose schema includes:

  # t.longblob :letters
  # t.longblob :word_lengths
  # t.string :name

  # list all words
  def list_words
    words = []
    init_tree = tree
    trav = lambda do |tree,word=""|
      if tree['is_word']
        words << word
      end

      tree.each do |letter,val|
        next if letter == 'is_word'
        trav.call(val,word+letter)
      end
    end

    trav.call(init_tree)
    words
  end

  # input a word
  def input_word(word)
    return if word.nil?
    init_tree = self.tree
    word_letters = word.downcase.split('')

    find_letter_in_level = lambda do |word_letters_left, lvl_tree|
      letter = word_letters_left.shift

      if letter.nil?
        lvl_tree['is_word'] = true
        return lvl_tree
      end

      if !lvl_tree[letter]
        lvl_tree[letter] = { 'is_word' => false }
      end

      lvl_tree[letter] = lvl_tree[letter].merge(find_letter_in_level.call(word_letters_left, lvl_tree[letter]))

      lvl_tree
    end

    self.letters = find_letter_in_level.call(word_letters, init_tree).to_json

    # update the lengths
    lengths = self.word_lengths_data
    lengths[word.length] = 1
    self.word_lengths = lengths.to_json

    self.save!
  end

  def remove_word(word)
    # travel the word tree to the last letter
    # make 'is_word' false on the last node
  end

  # get a hash of how many words of each length exists
  def word_lengths_data
    return {} if self.word_lengths.nil?

    @word_lengths_data ||= begin
      JSON.parse self.word_lengths
    rescue StandardError => e
      {}      
    end
  end

  # see if the input word exists in this list
  def is_word?(word)
    init_tree = tree
    word_letters = word.downcase.split('')
    find_letter_in_level = lambda do |word_letters, tree|
      letter = word_letters.shift

      if letter.nil?
        return tree['is_word']
      end

      return false if tree[letter].nil?

      next_node = tree[letter]
      find_letter_in_level.call(word_letters, next_node)
    end

    find_letter_in_level.call(word_letters, init_tree)
  end

  # find a random word
  def find_word
    word = []

    active_tree = tree

    (5..30).to_a.sample.times do 
      k = active_tree.keys.reject{ |e| e == 'is_word' }.sample
      word << k
      break if active_tree['is_word'] == true
      active_tree = active_tree[k]
    end

    word.join
  end

  # view the tree as it exists as a tree object
  def tree
    @tree ||= begin
      JSON.parse(letters)
    rescue StandardError => e
      {}      
    end
  end

end
