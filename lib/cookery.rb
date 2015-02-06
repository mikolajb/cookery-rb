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

  # Parses the string
  #
  def parse(string)
    m = CookeryGrammar.parse(string)
    # p m.dump
    m
  end

  def process_string(string)
    puts "Processing string".black_on_green
    c = parse string
    MODULES << CookeryModule.new("<string>")
    sexp = c.value
    puts sexp
    result = evaluate("first value")
    puts "Result after evaluation is ".black_on_green +
         " #{result}"
    result
  end

  def process_files(files)
    files.inject("first value") do |state, f|
      puts "Reading file ".black_on_green +
           " #{f} ".black_on_magenta
      process_file(f)
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

  # Helper method used to handle input files contating source code of
  # Cookery langauge.

  def process_file(file)
    MODULES << CookeryModule.new(file)

    implementation = File.absolute_path(
      File.join(File.dirname(file),
                File.basename(file, File.extname(file)) + '.rb'))

    if File.exist? implementation
      require implementation
    end
  end

  # Evaluates all existing modules
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

empty_project = {}
empty_project['.rb'] = <<SOURCE
action("test", :out) do |data|
  puts "Just a test, passing data from subject"
  data
end

subject("Test", nil, "test") do
  "fake result".bytes.map { |i| (i >= 97 and i <= 122 and rand > 0.5) ? i - 32 : i }.pack("c*")
end
SOURCE

empty_project['.cookery'] = <<SOURCE
test Test.
SOURCE

opts = Slop.parse help: true do |o|
  o.banner = "Usage: cookery [options] file..."

  o.string '-c', '--config', "Config file.", default: 'config.toml'
  o.string '--grammar_file', "Grammar file."
  o.string '-e', '--eval', "Evaluate expression."
  o.string '-n', '--new', "New Cookery project." do |project_name|
    empty_project.keys.each do |ext|
      if !Dir.exists?(project_name)
        Dir.mkdir(project_name)
      end

      if File.exists?(File.join(project_name, project_name + ext))
        warn "File #{project_name + ext} exists"
      else
        File.open(File.join(project_name, project_name + ext), 'w+') do |f|
          f.write empty_project[ext]
        end
      end
    end
    exit
  end
  o.bool '--print_options', "Print options and exit."
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

if options[:print_options]
  puts "Options:"
  config.each do |k, v|
    puts " #{k}: #{v ? v : 'NO'}"
  end
  exit
end

cookery = Cookery.new(config[:grammar_file])

if options[:eval] and !input_files.empty?
    puts "Evaluating string, the following input files are ignored:"
    puts input_files.join(", ")
end

result = options[:eval] ?
           cookery.process_string(options[:eval]) :
           cookery.process_files(input_files.uniq)
puts "Final STATE: ".black_on_green + " #{result} ".black_on_magenta
