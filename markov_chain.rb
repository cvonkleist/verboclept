require 'enumerator'

class MarkovChain
  # say [count] words
  def rant(count, starting_word = nil)
    starting_word = self.starting_word
    potential_next_tuples = @frequency.keys.select { |tuples| tuples.first == starting_word }

    next_word = if potential_next_tuples.empty?
                  self.starting_word
                else
                  if feeling_random?
                    randomish(potential_next_tuples)[1]
                  else
                    most_likely(potential_next_tuples)[1]
                  end
                end

    return next_word if count == 1
    [next_word, rant(count - 1, next_word)].join(' ')
  end

  alias :expound        :rant
  alias :demur          :rant
  alias :wave_hands     :rant
  alias :profess        :rant
  alias :rave           :rant
  alias :sure_sure_sure :rant

  # create a new chain of specified [order] and [random]ness
  def initialize(order, random = true)
    @order, @random = order, random
    @frequency = Hash.new { |hash, k| hash[k] = 0 }
  end

  # store frequency information about specified [text]
  def analyze(text)
    words_in(text).each_cons(@order) { |slice| @frequency[slice] += 1 }
  end

  # pick a word to start the markov chain
  def starting_word
    feeling_random? ? words[rand(words.length)] : words.first
  end

  # what words does this chain know? (now with 100% more caching!)
  def words
    @words_cache ||= @frequency.keys.flatten.uniq
  end

  # pick randomly, but weighted by likelihood
  def randomish(tuples)
    total_frequency = tuples.inject(0) { |sum, tuple| sum + @frequency[tuple] }
    eeny_meeny = rand(total_frequency)
    chosen_tuple = nil
    tuples.inject(0) do |range_start, tuple|
      range_end = range_start + @frequency[tuple]
      chosen_tuple = tuple if (range_start..range_end).include?(eeny_meeny)
      range_start = range_end + 1
    end
    chosen_tuple
  end

  private
  def words_in(text)
    text.split
  end

  def feeling_random?
    @random
  end

  def most_likely(tuples)
    tuples.inject(tuples.first) do |best_so_far, tuple| 
      @frequency[tuple] > @frequency[best_so_far] ? tuple : best_so_far
    end
  end
end
