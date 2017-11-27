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
      @expected_content = expected_content
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

  ## matchers for openstack_database LWRP
  def create_openstack_common_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:openstack_common_database, :create, resource_name)
  end

  # database
  #
  ChefSpec.define_matcher :database

  def create_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database, :create, resource_name)
  end

  def drop_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database, :drop, resource_name)
  end

  def query_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database, :query, resource_name)
  end

  # database user
  #
  ChefSpec.define_matcher :database_user

  def create_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database_user, :create, resource_name)
  end

  def drop_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database_user, :drop, resource_name)
  end

  def grant_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database_user, :grant, resource_name)
  end

  # mysql database
  #
  ChefSpec.define_matcher :mysql_database

  def create_mysql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database, :create, resource_name)
  end

  def drop_mysql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database, :drop, resource_name)
  end

  def query_mysql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database, :query, resource_name)
  end

  # mysql database user
  #
  ChefSpec.define_matcher :mysql_database_user

  def create_mysql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database_user, :create, resource_name)
  end

  def drop_mysql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database_user, :drop, resource_name)
  end

  def grant_mysql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database_user, :grant, resource_name)
  end
end
