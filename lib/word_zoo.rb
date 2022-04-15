
require_relative "word_zoo/version"
require "active_support/concern"

module WordZoo
  extend ActiveSupport::Concern
  # this is an active record concern

  # must be included in a model whose schema includes:
  
  # t.longblob :letters
  # t.string :name

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


  def self.test_file
    if self.find_by_name('test')
      test_list = self.find_by_name('test')
    else
      test_list = self.new(name: 'test')
    end

    self.input_file('negwords.txt', test_list)
    self.wipe_test
  end

  def self.wipe_test
    if self.find_by_name('test')
      test_list = self.find_by_name('test')
    else
      test_list = self.new(name: 'test')
    end

    test_list.update(letters: nil)
  end

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

  def cached_word_list
    {}
  end

  def populate_lengths
    lengths = {}
    self.list_words.each do |word|
      lengths[word.length] = 1
    end

    self.word_lengths = lengths.to_json
    self.save!
  end

  def word_lengths_data
    return {} if self.word_lengths.nil?

    @word_lengths_data ||= begin
      JSON.parse self.word_lengths
    rescue StandardError => e
      {}      
    end
  end


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


  def tree
    @tree ||= begin
      JSON.parse(letters)
    rescue StandardError => e
      {}      
    end
  end

end
