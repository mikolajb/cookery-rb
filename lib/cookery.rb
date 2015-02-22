require 'slop'

class Cookery
  @@modules = []
  @@modules_by_ref = {}
  @@module = nil
  OPERATIONS = {}

  attr_reader :config

  def initialize(config = {})
    @config = config
    if !@config.include? :actions
      @config[:actions] = {}
    else
      @config[:actions].deep_symbolize_keys!
    end
    Citrus.require config[:grammar_file] || 'cookery'
  end

  def self.module
    @@module
  end

  def self.modules_by_ref
    @@modules_by_ref
  end

  # Parses the string
  #
  def parse(string)
    CookeryGrammar.parse(string)
  end

  def process_string(string)
    puts "Processing string".black_on_green
    c = parse string
    @@modules << CookeryModule.new("<string>", self, @config)
    @@module = @@modules.last
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

  def process_file(file, reference = nil)
    already_processed = @@modules.select { |m| m.name == File.absolute_path(file)}
    if already_processed.length == 1
      if reference
        @@modules_by_ref[reference] = already_processed.first
        return
      end
    elsif already_processed.length > 1
      warn "This module processed more than once".red
    end

    load_other_files = -> (file, extension) do
      File.absolute_path(
        File.join(File.dirname(file),
                  File.basename(file, File.extname(file)) + extension))
    end

    implementation, configuration = [[file, '.rb'],
                                     [file, '.toml']].map(&load_other_files)

    if File.exist?(configuration)
      puts "Loading configuration file: #{configuration}".black_on_green
      module_config = TOML.load_file(configuration).deep_symbolize_keys
      @config.deep_merge!(module_config)
    else
      puts "No configuration file: #{configuration}".black_on_magenta
    end

    # Module by reference is loaded during the execution of other modules
    if reference
      @@modules_by_ref[reference] =
        CookeryModule.new(File.absolute_path(file), self, @config)
      @@module = @@modules_by_ref[reference]
    else
      @@modules << CookeryModule.new(File.absolute_path(file), self, @config)
      @@module = @@modules.last
    end

    if File.exist? implementation
      puts "Loading implementation file: #{implementation}".black_on_green
      require implementation
    else
      puts "No implementation file: #{implementation}".black_on_magenta
    end

    c = parse File.read(file)
    sexp = c.value
    puts sexp
  end

  # Evaluates all existing modules
  def evaluate(result)
    @@modules.inject(result) { |memo, m| m.evaluate(memo) }
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

empty_project['.toml'] = <<SOURCE
[actions]
    [actions.test]
    just_an_example = true
SOURCE

opts = Slop.parse help: true do |o|
  o.banner = "Usage: cookery [options] file..."

  o.string '-c', '--config', "Config file.", default: 'config.toml'
  o.string '--grammar_file', "Grammar file."
  o.string '-e', '--eval', "Evaluate expression."
  o.string '-n', '--new', "New Cookery project." do |project_path|
    empty_project.keys.each do |ext|
      if !Dir.exists?(project_path)
        Dir.mkdir(project_path)
      end

      project_name = File.basename(project_path)

      if File.exists?(File.join(project_path, project_name + ext))
        warn "File #{project_name + ext} exists"
      else
        File.open(File.join(project_path, project_name + ext), 'w+') do |f|
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

require 'colored'
require 'citrus'
require 'toml'
require 'active_support/all'
$:.unshift File.join(File.dirname(__FILE__), 'cookery')
require 'helpers'
require 'operation'
require 'dsl_elements'
require 'action'
require 'subject'
require 'condition'

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
else
  warn "Configuration file not found."
end

if options[:print_options]
  puts "Options:"
  config.each do |k, v|
    puts " #{k}: #{v ? v : 'NO'}"
  end
  exit
end

cookery = Cookery.new(config)

if options[:eval] and !input_files.empty?
    puts "Evaluating string, the following input files are ignored:"
    puts input_files.join(", ")
end

result = options[:eval] ?
           cookery.process_string(options[:eval]) :
           cookery.process_files(input_files.uniq)
puts "Final STATE: ".black_on_green + " #{result} ".black_on_magenta
