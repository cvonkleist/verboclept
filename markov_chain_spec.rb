require 'markov_chain'

def be_same_as(expected)
  simple_matcher("#{expected.inspect} (any order)") { |got| got.sort == expected.sort }
end

describe method(:be_same_as) do
  it "should work" do
    [1, 2, 3].should be_same_as([3, 2, 1])
    [1, 2, 3].should_not be_same_as([3, 3, 4])
  end
end

describe MarkovChain do
  before do
    @chain = MarkovChain.new(2, false)
  end

  it "should analyze text" do
    @chain.analyze "foo bar foo bat foo"
    @chain.words.should be_same_as(%w(bar bat foo))
  end

  it "should rant" do
    @chain.analyze "foo bar foo bat foo bar foo baz foo hur dur"
    rant = @chain.rant(50)
    rant.should_not be_nil
    rant.should be_kind_of(String)
    rant.should_not be_empty
    rant.should match(/((foo|bar|bat|baz|hur|dur) ?){50}/)
  end

  it "should pick a starting word" do
    @chain.analyze "foo bar foo bat foo baz"
    @chain.starting_word.should_not be_nil
  end
end

# randomness/unrandomness
describe MarkovChain do
  before do
    @big_corpus = "now is the time for all good men to come to the aid of their quick red fox sure sure sure"
  end

  it "should understand different orders of analysis" do
    @two = MarkovChain.new(2, true)
    @three = MarkovChain.new(3, true)
    [@two, @three].each { |chain| chain.analyze "foo bar bat baz hur dur foo" }
  end

  it "should be random only when asked" do
    @normal = MarkovChain.new(2, false)
    @random = MarkovChain.new(2, true)
    [@normal, @random].each { |chain| chain.analyze(@big_corpus) }

    @normal.rant(50).should == @normal.rant(50)
    @random.rant(50).should_not == @normal.rant(50)
  end

  it "should pick a random starting word when asked" do
    @chain = MarkovChain.new(2, true)
    @chain.analyze @big_corpus
    first = (0..50).collect { @chain.starting_word }
    second = (0..50).collect { @chain.starting_word }
    first.should_not == second
  end

  it "should pick randomly" do
    @chain = MarkovChain.new(3, true)
    @chain.analyze @big_corpus + ' sure sure sure'
    @chain.randomish [%w(time for all), %w(sure sure sure)]
    @chain.randomish [%w(time for all)]
  end
end

# hurr durrrr
describe MarkovChain do
  it "should produce output that sounds human-ish when given human input" do
    #pending
    @chain = MarkovChain.new(5, true)
    @chain.analyze(File.read('demo.txt'))
    puts @chain.rant(200)
    print "does this look like human output?"
    gets.should match(/^y/)
  end
end
