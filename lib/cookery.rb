require 'colored'
require 'citrus'
require 'toml'
require 'slop'

module Activity
  def value
    "s(:activity, " +
      [
        (capture(:var) ? capture(:var).value : nil),
        (capture(:action_group) ? capture(:action_group).value : nil),
        (capture(:subject_group) ? capture(:subject_group).value : nil),
        (capture(:condition_group) ? capture(:condition_group).value : nil)
      ].reject(&:nil?).join(", ") +
      ")"
  end
end

module Subject
  def value
    if capture(:subject)
      "s(:subject, " + capture(:subject).value +
        (capture(:subject_arguments) ?
           (", s(:subject_arguments, " + capture(:subject_arguments).value + ")") : "") +
        ")" +
        (capture(:subject_group) ? ", " + capture(:subject_group).value : "")
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

    Citrus.require config[:grammar_file] || 'cookery'

    input_files.uniq.each do |f|
      c = Cookery.parse File.read(f)
      p c.value
    end
  end
end
