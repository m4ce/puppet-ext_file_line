require 'puppet/util'
require 'puppet/util/diff'

Puppet::Type.type(:ext_file_line).provide(:ruby) do
  include Puppet::Util
  include Puppet::Util::Diff

  def exists?
    regex = Regexp.new(resource[:match]) if resource[:match]

    match_count = 0
    lines.each do |line|
      str = nil
      if regex
        if line.chomp =~ regex
          match_count += 1

          if resource[:line]
            str = line.chomp.gsub(regex, resource[:line])
          else
            return true
          end

          return true if line.chomp == str
        end
      else
        return true if line.chomp == resource[:line]
      end
    end

    if regex and match_count == 0
      return true
    end

    return false
  end

  def create()
    handle_match
  end

  def destroy()
    handle_match
  end

  def handle_match()
    regex = Regexp.new(resource[:match]) if resource[:match]

    match_count = 0
    lines.each do |line|
      if regex
        if line.chomp =~ regex
          match_count += 1
        end
      else
        match_count += 1 if line.chomp == resource[:line]
      end
    end

    if match_count > 1 && resource[:multiple].to_s != 'true'
     raise Puppet::Error, "More than one line in file '#{resource[:path]}' matches pattern '#{resource[:match]}'"
    end

    File.open(resource[:path] + ".sednew", 'w') do |fh|
      lines.each do |line|
        record = line
        if regex
          if line.chomp =~ regex
            next if resource[:ensure] == :absent
            record = line.chomp.gsub(regex, resource[:line])
          end
        else
          if line.chomp == resource[:line]
            next if resource[:ensure] == :absent
          end
        end

        fh.puts(record) 
      end

      if resource[:ensure] == :present
        unless regex
          fh.puts(resource[:line]) if match_count == 0
        end
      end
    end

    if Puppet[:show_diff] && @resource[:show_diff]
      self.send(@resource[:loglevel], "\n" + diff(resource[:path], resource[:path] + ".sednew"))
    end

    File.rename(resource[:path] + ".sednew", resource[:path])
  end

  private
  def lines
    # If this type is ever used with very large files, we should
    #  write this in a different way, using a temp
    #  file; for now assuming that this type is only used on
    #  small-ish config files that can fit into memory without
    #  too much trouble.
    @lines ||= File.readlines(resource[:path])
  end
end
