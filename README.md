# WordZoo

This gem is about saving space and time.  There is a near infinite amount of words in the english language, and many word lists can reac row counts in the millions.

Using dictionary trees with letter nodes, the largest a dictionary may get is 26 to the 26th power, which is large, but manageable.  In this way words like 'cat', 'catepillar' and category may consolidate thier shared prefixes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'word_zoo'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install word_zoo

## Usage

    This creates an active record concern module that you may include in your models:
            include WordZoo

    Database creation
        The model that you include this in should have the following fields:
           t.longblob :letters
           t.longblob :word_lengths
           t.string :name


## Instance methods:

  # Input a word into a word tree
      input_word(word)
        eg:
            > example_list.input_word("lao")
                 => true
            > example_list.input_word("lao")
                 => true

      # list all words
      list_words
        eg:
            > example_list.list_words
                => ["matt", "lao"]


  # Remove a word from a tree
      def remove_word(word)
        eg:
            > example_list.remove_word("matt")
             => true
            > example_list.list_words
             => ["lao"]

  # get a hash whether or not certain lengths are in the tree
      word_lengths_data
        eg:
            > example_list.word_lengths_data
            => {"4"=>1, "3"=>1, "6"=>1}

            in this example the list_words method would return: ["matt", "matter", "lao"]: there are words of lengths 4, 3 and 6 present in the example dictionary tree.


  # see if the input word exists in this list
      is_word?(word)
          eg:
            > example_list.is_word?("matt")
             => true
            > example_list.is_word?("pee")
             => false

  # find a random word
            > example_list.find_word
             => "matt"

  # view the tree as it exists as a tree object
      eg:
          > examplelist.tree
              => {"m"=>{"is_word"=>false, "a"=>{"is_word"=>false, "t"=>{"is_word"=>false, "t"=>{"is_word"=>true}}}}, "l"=>{"is_word"=>false, "a"=>{"is_word"=>false, "o"=>{"is_word"=>true}}}}





## Development

After pulling down the source code from github, use this in any local active record app.
```ruby
gem 'word_zoo', '0.1.1', path: "../word_zoo"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/laomatt/word_zoo. This project is intended to be a safe, welcoming space for collaboration.

Please create PRs and tag the authors.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

