# Cookery

Cookery is a framework for designing Domain Specific Languages for scientific applications. It is developed in Ruby programming language (requires Ruby 2.0).

## How does it work

Cookery is inspired by cooking recipes and it allows to develop scientific applications with plain English. In order to develop an application, first an environment has to be established. It consist three kinds components:

1. Action
1. Condition
1. Subject

### Action

__Action__ is a pair: __name__ and _procedure_. Name_ is a reference to created action and can be used in a place of `action` (see syntax). _Procedure_ is a block of code that takes one argument - _subject_. During the execution, _action_ receives a reference to a _subject_ specified be a user.

### Condition

__Condition__ is very similar to _action_. It has a __name__ and __procedure__. They should have longer, descriptive names and be designed in a way that can cooperate with many actions.

### Subject

__Subject__ is built from four elements: __name__, __regular expression__, __type__ and __procedure__.

- _name_ is a reference to a subject
- _regular expression_ is used to parse subject's arguments, all elements captured by a regular expression are available as arguments in a block
- _type_ (or protocol) points to an implementation of subject's backend, backend provides methods that can be used in a _procedure_ to specify protocol's parameters (e.g. _path_)
- _procedure_ - block of Ruby code where all the parameters specific to a protocol can be specified using functions provided by a protocol implementation

### Syntax

These components define named entities - keywords that can be used in a following syntax:

    Action subject (context) - condition condition ... condition.

Then, during the execution, framework passes subject with arguments specified by a user `(context)` and references to conditions.

## Example

In a following example we set up environment

### Setting up environment

First, a subject:

    subject(:file, /(.+)/, :file) do |f|
      path f
    end

Action that puts content of a file to a channel (specified by a subject)

    action(:read) do |subject|
      puts "in action"

      channel_put(:foo, subject)
    end

Condition that decompresses a string

    condition("with zip compression") do |data|
      puts "in condition"
      gz = Zlib::GzipReader.new(StringIO.new(data))
      result = gz.read
      gz.close
      result
    end

Example, empty _condition_:

    condition("with nothing") do |data|
      data
    end

Action `print_result` prints result to standard output

    action(:print_result) do
      puts "RESULT: #{channel_get(:bar)}"
    end

Action `count_words` counts word in string.

    action(:count_words) do |subject, conditions|
      channel_put(:bar, channel_get(:foo).split.length)
    end

### Application

Complete application

    Read file /tmp/test_data.gzip - with zip compression, with nothing.
    Count words.
    Print result.

