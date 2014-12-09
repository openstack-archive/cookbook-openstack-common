# encoding: UTF-8

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
  # option1 = value2
  #
  # Example custom matcher that can be called in other
  # dependends cookbooks.
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
      @expected_content = expected_content
      self
    end

    # rubocop:disable MethodLength, CyclomaticComplexity
    def matches_content?
      def section?(line, section = '.*')
        if line =~ /^[ \t]*\[#{section}\]/
          return true
        else
          return false
        end
      end

      def get_section_content(content, section)
        match = false
        section_content = ''
        content.split("\n").each do |line|
          if section?(line, section)
            match = true
            next
          end

          section_content << "#{line}\n" if match == true && !section?(line)

          break if match == true && section?(line)
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

      if @expected_content.is_a?(Regexp)
        @actual_content =~ @expected_content
      elsif RSpec::Matchers.is_a_matcher?(@expected_content)
        @expected_content.matches?(@actual_content)
      else
        @actual_content.include?(@expected_content)
      end
    end
    # rubocop:enable MethodLength, CyclomaticComplexity
  end
end
