if defined?(ChefSpec)

  #
  # Test method for ini format file
  #
  # Example file content:
  #
  # [section1]
  # option1 = value1
  # option2 = value2
  # [section2]
  # option3 = value3
  #
  # Example file content with dup sections:
  #
  # [section1]
  # option1 = value1
  # option2 = value2
  # [section2]
  # option3 = value3
  # [section1]
  # option4 = value4
  #
  # Example custom matcher that can be called in other
  # cookbooks.
  #
  # render_config_file(path).with_section_content(
  #   'section1', 'option1 = value1')
  # render_config_file(path).with_section_content(
  #   'section1', /^option2 = value2$/)
  #
  def render_config_file(path)
    RenderConfigFileMatcher.new(path)
  end

  #
  # Extend the RenderFileMatcher as RenderConfigFileMatcher,
  # add a new method with_section_content for ini format file.
  #
  class RenderConfigFileMatcher < ChefSpec::Matchers::RenderFileMatcher
    def with_section_content(section, expected_content)
      @section = section
      @expected_content << expected_content
      self
    end

    def matches_content?
      def section?(line, section = '.*')
        return true if line =~ /^[ \t]*\[#{section}\]/
      end

      def get_section_content(content, section)
        within_section = false
        section_content = ''
        content.split("\n").each do |line|
          if section?(line, section)
            within_section = true
            next
          end

          start_of_new_section = section?(line)
          section_content << "#{line}\n" if within_section && !start_of_new_section
          within_section = false if start_of_new_section
        end
        section_content
      end

      return true if @expected_content.nil?

      @actual_content = ChefSpec::Renderer.new(@runner, resource).content

      unless @actual_content.nil?
        unless @section.nil?
          @actual_content = get_section_content(@actual_content, @section)
        end
      end

      return false if @actual_content.nil?

      # Knock out matches that pass. When we're done, we pass if the list is
      # empty. Otherwise, @expected_content is the list of matchers that
      # failed
      @expected_content.delete_if do |expected|
        if expected.is_a?(Regexp)
          @actual_content =~ expected
        elsif RSpec::Matchers.is_a_matcher?(expected)
          expected.matches?(@actual_content)
        elsif expected.is_a?(Proc)
          expected.call(@actual_content)
          # Weird RSpecish, but that block will return false for a negated check,
          # so we always return true. The block will raise an exception if the
          # assertion fails.
          true
        else
          @actual_content.include?(expected)
        end
      end
      @expected_content.empty?
    end
  end
end
