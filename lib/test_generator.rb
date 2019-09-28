require "erb"
require "json"
require "yaml"

class TestGenerator
  include ERB::Util
  attr_reader :project_root, :spec_path, :input_filename, :test_case

  def self.generate
    ScionTestFrameworkGenerator.generate
  end

  def test_case_name
    test_case["name"]
  end

  def class_name
    classify test_case_name
  end

  def tests
    test_case["tests"]
  end

  def render template
    ERB.new(template).result(binding)
  end

  def classify string
    string.to_s.split('_').collect!{ |w| w.capitalize }.join
  end

  def elixir_hash hash
    symbolized_keys_hash = hash.transform_keys {|k| k.to_sym}
    hash_string = symbolized_keys_hash.to_s
      .gsub(/=>/, ": ")
      .gsub(/([{\s]):/, '\1')
    "%#{hash_string}"
  end

  def generate
    folder = input_filename.dirname.basename.to_s
    language_settings.each do |(language,settings)|
      langauge_filename = settings[:filename_template] % test_case_name
      language_template = settings[:template]

      output_filename = project_root.join *%W[ generated #{language} #{folder} #{langauge_filename} ]
      puts "Generating #{output_filename.relative_path_from(project_root)}"
      output_filename.dirname.mkpath unless output_filename.dirname.exist?
      contents = render language_template
      File.write output_filename, contents
    end
  end
end

require_relative "./scion_test_framework_generator"
