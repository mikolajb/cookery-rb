require 'colored'
require 'citrus'
require 'toml'
require 'slop'
require 'active_support/core_ext/string'
$:.unshift File.join(File.dirname(__FILE__), 'cookery')
require 'helpers'
require 'operation'
require 'dsl_elements'
require 'action'
require 'subject'
require 'condition'

class Cookery
  MODULES = []
  OPERATIONS = {}

  def initialize(grammar_file = 'cookery')
    grammar_file ||= 'cookery'
    Citrus.require grammar_file
  end

  def parse(file)
    CookeryGrammar.parse(file)
  end

  def process_files(files)
    files.inject("first value") do |state, f|
      puts "Reading file ".black_on_green +
           " #{f} ".black_on_magenta
      new_file f
      c = parse File.read(f)
      sexp = c.value
      puts sexp
      state = evaluate(state)
      puts "Result after file ".black_on_green +
           " #{f} ".black_on_magenta +
           " is ".black_on_green +
           " #{state} ".black_on_magenta
      state
    end
  end

  def evaluate(result)
    MODULES.inject(result) { |memo, m| m.evaluate(memo) }
  end
end

module ActivityStatement
  def value
    a = Activity.new
    add_node(a)
    closure = ->(i) { capture(:var) ? "(define #{capture(:var).value} #{i})": i}

    closure.call "(" +
                 [(capture(:action_group) ?
                     capture(:action_group).value : nil),
                  (capture(:subject_or_variable) ?
                     capture(:subject_or_variable).value : nil),
                  (capture(:condition_group) ?
                     capture(:condition_group).value : nil)
                 ].reject(&:nil?).join(" ") +
                 ")"
  end
end

module SubjectOrVariable
  def value
    more = captures[:subject_or_variable][1..-1].map(&:value)

    if capture(:subject_list)
      [capture(:subject_list).value, more].reject(&:empty?).join(' ')
    elsif capture(:subject_group)
      [capture(:subject_group).value, more].reject(&:empty?).join(' ')
    end
  end
end

opts = Slop.parse help: true, strict: true do |o|
  o.banner = "Usage: cookery [options] file..."

  o.string '-c', '--config', "Config file.", default: 'config.toml'
  o.string '--grammar_file', "Grammar file."
  o.on '--print_options', "Print options and exit."
  o.on '-h', '--help' do
    puts o
    exit
  end
end

options = opts.to_hash
input_files = opts.arguments

config = {}
if File.exists? options[:config]
  config = TOML.load_file(options[:config])
  # symbolize keys
  config.keys.each do |key|
    config[(key.to_sym rescue key) || key] = config.delete(key)
  end
  # replace options from config with options from command line
  config.
    merge!(options.to_h) { |key, v1, v2| v2 ? v2 : v1 }.
    reject! { |key, value| value.nil? }
end

if options.include? "print_options"
  config.each do |k, v|
    puts "#{k}: #{v ? v : 'NO'}"
  end
end

cookery = Cookery.new(config[:grammar_file])
result = cookery.process_files(input_files.uniq)
puts "Final STATE: ".black_on_green + " #{result} ".black_on_magenta
