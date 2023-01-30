CURR_PATH = File.expand_path(File.dirname(__FILE__))
SOURCES_PATH = CURR_PATH
GENERATOR_PATH = File.join(CURR_PATH, "..", "..", "..", "external", "objectbox-swift-generator")
TEMPLATES_PATH = File.join(GENERATOR_PATH, "ObjectBox")
GENERATED_PATH = File.join(CURR_PATH)
SOURCERY_PATH = File.join(GENERATOR_PATH, "bin", "Sourcery.app", "Contents", "MacOS", "Sourcery")

Dir.glob(File.join(CURR_PATH, "Entities.swift")) do |path| # TODO: used to be multiple files via *, but not needed anymore?
  system %Q{"#{SOURCERY_PATH}" --verbose --disableCache --prune --sources "#{path}" --templates "#{TEMPLATES_PATH}" --output "#{GENERATED_PATH}"}
end
