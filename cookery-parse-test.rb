require 'citrus'
require 'colored'

Citrus.load 'cookery'

texts = {"Test: read File." => {
           variable: "Test",
           action: "read"},
         "read with something." => {
           action: "read",
           condition: "something"},
         "read\n\t." => {action: "read"},
         "Test: read File with something." => {
           variable: "Test",
           action: "read",
           subject: "File",
           condition: "something"},
         "Test: read File1 and File2 with something." => {
           variable: "Test",
           action: "read",
           subject: "File1, File2",
           condition: "something"},
         "read File /tmp/test.txt." => {
           action: "read",
           subject: "File",
           subject_arguments: "/tmp/test.txt"},
         "Test: read File1 /tmp/test.txt and File2 with something." => {
           variable: "Test",
           action: "read",
           subject: "File1, File2",
           subject_arguments: "/tmp/test.txt",
           condition: "something"},
         "Test: read File1 /tmp/test.txt and File2 /tmp/test.txt " \
         "with something." => {
            variable: "Test",
            action: "read",
            subject: "File1, File2",
            subject_arguments: "/tmp/test.txt, /tmp/test.txt",
            condition: "something"},
         "Test: read very http://example.com slowly File file:///tmp/test.txt with something." => {
           variable: "Test",
           action: "read",
           action_arguments: "very http://example.com slowly",
           subject: "File",
           subject_arguments: "file:///tmp/test.txt",
           condition: "something"},
         "read very slowly." => {
           action: "read",
           action_arguments: "very slowly"},
         "read very slowly with something." => {
           action: "read",
           action_arguments: "very slowly",
           condition: "something",
         },
         "read very slowly with something else like this ftp://test.txt." => {
           action: "read",
           action_arguments: "very slowly",
           condition: "something",
           condition_arguments: "else like this ftp://test.txt"
         },
         "T[]: read File /tmp/test.txt." => {
           action: "read",
           list_variable: "T[]",
           subject: "File",
           subject_arguments: "/tmp/test.txt"},
         "A[]: read T[]." => {
           action: "read",
           list_variable: "A[]",
           list_variable_body: "T[]"},
        }

counter = 0
texts.each do |t, p|
  message = ""
  begin
    c = Cookery.parse t

    checked = 0
    [:variable, :list_variable].each do |elem|
      message += "#{elem}" + "_" * (31 - elem.length) +
                 (c.captures.include?(elem) ?
                    c.captures[elem].map(&:inspect).join(", ").green : "") + "\n"
      if c.captures.include?(elem)
        checked += 1 if p[elem] == c.captures[elem].join(", ")
      end
    end

    {action_group: [:action, :action_arguments],
     subject_group: [:subject, :subject_arguments, :list_variable],
     condition_group: [:condition, :condition_arguments]}.each do |elem, names|
      names.each do |name|
        message += "#{name}" + "_" * (31 - name.length) +
             (c.captures.include?(elem) ?
                c.capture(elem)[name].map(&:inspect).join(", ").green : "") + "\n"
        if c.captures.include?(elem)
          if name == :list_variable
            checked += 1 if p[:list_variable_body] == c.capture(elem)[name].join(", ")
          else
            checked += 1 if p[name] == c.capture(elem)[name].join(", ")
          end
        end
      end
    end

    if not p[:skip] and not checked == p.length
      puts t.magenta
      puts "NOT MATCHING".red
      puts "it was suppose to be #{p.inspect}".red

      puts message
      p c.captures
      puts ("-" * 80).yellow
      next
    end

    counter += 1
  rescue Citrus::ParseError => e
    puts t.magenta
    puts "PARSING FAILD".red
    puts e.detail

    puts message
    puts ("-" * 80).yellow
  end
end

puts
puts "\t#{counter} / #{texts.length} passed".send(
       counter == texts.length ? :green :
         counter == 0 ? :red : :yellow)
puts
