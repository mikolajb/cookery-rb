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
