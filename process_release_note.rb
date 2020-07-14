class Commit
  def initialize(type, ticket_number, title)
      @type = type
      @ticket_number = ticket_number
      @title = title
  end

  def type
    @type
  end

  def ticket_number
    @ticket_number
  end

  def title
    @title
  end

end

commits = Array.new
File.foreach('git_log.txt').with_index do |line, line_num|
   output = line.split(": ")
   if output.count == 3
     commit = Commit.new(output[0], output[1], output[2])
     commits.push(commit)
   else
     commit = Commit.new("Undefined", "XXX-000", line)
     commits.push(commit)
   end
end

groups = commits.group_by { |obj| obj.ticket_number[/[A-Za-z]{2,}/].upcase }

lines = []

groups.each do |key, commits|
  # type_groups = commits.group_by { |obj| obj.type }
  type_groups = commits.group_by { |obj|
    obj.type == 'feat' ? 'Features' : obj.type == 'fix' ? 'Fixes' : 'Others' }
  sorted_types = type_groups.sort_by { |k, v| k }

  lines.push("#{key}")
  lines.push("=====")

  sorted_types.each do |key, commits|
    lines.push("#{key}:")
    lines.push("-------")
    commits.each do |commit|
      lines.push("#{commit.ticket_number} | #{commit.title}")
    end
    lines.push(" ")
  end
  lines.push(" ")
end

note_name = "release_notes.txt"

File.open("#{note_name}", "w") { |f|
  lines.each { |x| 
    f.write "#{x}\n"
    puts x
  }
}
