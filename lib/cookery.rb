require 'colored'
require 'citrus'
require 'toml'
require 'slop'
require 'active_support/core_ext/string'
$:.unshift File.join(File.dirname(__FILE__), 'cookery')
require 'helpers'
require 'dsl_elements'

class Cookery
  MODULES = []

  def initialize(grammar_file = 'cookery')
    grammar_file ||= 'cookery'
    Citrus.require grammar_file
  end

  def parse(file)
    CookeryGrammar.parse(file)
  end

  def evaluate
    MODULES.each(&:evaluate)
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
    n = Node.new(:subject)

    if capture(:subject_list)
      n.set(:name, capture(:subject_list).value)
      [capture(:subject_list).value, more].reject(&:empty?).join(' ')
    elsif capture(:subject_group)
      n.set(:name, capture(:subject_group).value)
      [capture(:subject_group).value, more].reject(&:empty?).join(' ')
    end
  end
end

Slop.parse help: true, strict: true do
  banner "Usage: cookery [options] file..."

  on :c, :config=, "Config file.", default: 'config.toml'
  on :grammar_file=, "Grammar file."
  on :print_options, "Print options and exit."

  run do |options, input_files|
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

    if options.print_options?
      config.each do |k, v|
        puts "#{k}: #{v ? v : 'NO'}"
      end
    end

    cookery = Cookery.new(config[:grammar_file])

    input_files.uniq.each do |f|
      new_file f
      c = cookery.parse File.read(f)
      sexp = c.value
      puts sexp
      cookery.evaluate
    end

    # Cookery::MODULES.each(&:print)
  end
end
