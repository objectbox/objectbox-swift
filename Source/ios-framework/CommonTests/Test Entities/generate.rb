CURR_PATH = File.expand_path(File.dirname(__FILE__))
SOURCES_PATH = CURR_PATH
TEMPLATES_PATH = File.join(CURR_PATH, "..", "..", "..", "EntityInfoTest", "templates")
GENERATED_PATH = File.join(CURR_PATH)
SOURCERY_PATH = File.join(CURR_PATH, "..", "..", "..", "external", "Sourcery", ".build", "release", "sourcery")

Dir.glob(File.join(CURR_PATH, "*Entities.swift")) do |path|
  system %Q{"#{SOURCERY_PATH}" --verbose --disableCache --prune --sources "#{path}" --templates "#{TEMPLATES_PATH}" --output "#{GENERATED_PATH}"}
end
