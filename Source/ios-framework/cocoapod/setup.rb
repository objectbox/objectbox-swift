#!/usr/bin/env ruby

#
# This script sets up an Xcode project so it runs our code generator over that project and the generated code
# gets compiled as part of the project. We run the code generator via a script in our folder, so that an update can
# change how we call the code generator without us having to update the project again.
#
# Typical CocoaPods directory structure is
#   Path/To/MyProject <-- folder containing the MyProject.xcodeproj and user's source files
#   Path/To/MyProject/Pods <-- CocoaPods downloads all dependencies in here
#   Path/To/MyProject/Pods/ObjectBox/ <-- our folder with Sourcery and this script
#
# So if given no parameters, we assume that is still the case and just drill up the hierarchy to find our project to
# which we add the build phase for running the preprocessor. For cases where a user has several projects in one folder,
# we also permit passing in the name of a project, and will pick that one.
#
# However, for non-Cocoapods users, we also permit passing a project path (and optional target name) so they can tell
# us where the project file is if their directory structure differs.
#

require "xcodeproj"

##
## Figure out app project path
##

OBJECTBOX_POD_ROOT = File.expand_path(File.dirname(__FILE__))
is_cocoapods = ("/" + __FILE__ + "/").include? "/Pods/" # Naïve heuristic for finding out if the user uses CocoaPods.

if ARGV.size > 0
  PROJECT_FILE_NAME = ARGV[0]
  if File.exists?(PROJECT_FILE_NAME)
      project_path = PROJECT_FILE_NAME
      PROJECT_ROOT = File.dirname(PROJECT_FILE_NAME)
  elsif is_cocoapods
    PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    project_path = File.join(PROJECT_ROOT, PROJECT_FILE_NAME)
  end
  if !File.exists?(project_path)
    puts "Could not find Xcode project at \"#{project_path}\""
    exit 1
  end
else
  puts "Recommended usage:   #{__FILE__} ProjectName.xcodeproj TargetName"
  puts ""
  PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
  PROJECT_BASENAME = File.basename(PROJECT_ROOT)
  puts "Trying to find project named like parent folder \"#{PROJECT_BASENAME}\"."

  project_path = File.join(PROJECT_ROOT, "#{PROJECT_BASENAME}.xcodeproj")
  if !File.exists?(project_path)
    puts "Not found. Taking first project file from the current directory ..."
    project_files = Dir.glob(File.join(PROJECT_ROOT, "*.xcodeproj"))
    if project_files.empty?
      puts "Could not find a project file in \"#{PROJECT_ROOT}\"."
      exit 1
    end
    project_files.sort_by!{ |m| m.downcase } # Make following call more deterministic, APFS returns you files in any random order.
    project_path = project_files[0] # Take first project file ¯\_(ツ)_/¯
  end
end

# Generate the correct path to write into the "run shell script" build phase:
if is_cocoapods # Use path relative to the PODS_ROOT setting for CocoaPods:
  OBJECTBOX_GEN_SCRIPT_PATH = "$PODS_ROOT/ObjectBox/generate_sources.sh"
  OBJECTBOX_REL_GEN_SCRIPT_PATH = OBJECTBOX_GEN_SCRIPT_PATH
else # Use paths relative to the project itself for non-CocoaPods:
  OBJECTBOX_GEN_SCRIPT_PATH = File.join(OBJECTBOX_POD_ROOT, "generate_sources.sh")
  proj_pathname = Pathname.new PROJECT_ROOT
  script_pathname = Pathname.new OBJECTBOX_GEN_SCRIPT_PATH
  TMP_PATH = script_pathname.relative_path_from proj_pathname
  OBJECTBOX_REL_GEN_SCRIPT_PATH = "$PROJECT_DIR/" + "#{TMP_PATH}"
end

puts "Using \"#{project_path}\""

##
## Add the generated Swift files to the project
##

project = Xcodeproj::Project.open(project_path)

if ARGV.size > 1
  TARGET_NAME = ARGV[1]
  app_targets = project.targets.select { |t| t.name == TARGET_NAME }
  if app_targets.size == 0
    puts "Could not find Xcode target \"#{TARGET_NAME}\" in \"#{project_path}\""
    exit 1
  end
else # If not given a path, just pick all targets that result in runnables (hopefully the Mac and iOS app targets):
  app_targets = project.targets.select { |t| t.launchable_target_type? }
end

SOURCERY_BUILD_PHASE_NAME = "[OBX] Update Sourcery Generated Files"
GENERATED_DIR_NAME = "generated"
GENERATED_DIR_PATH = File.join(PROJECT_ROOT, GENERATED_DIR_NAME)

# Find any existing build phase, or add one if missing:
generated_groupref = project.groups
.select { |g| g.path == GENERATED_DIR_NAME }
.first
if generated_groupref.nil?
    puts "Adding a new group for generated files at `./#{GENERATED_DIR_NAME}/`..."
    
    generated_groupref = project.new_group("generated", GENERATED_DIR_NAME)
    
    # Move group from the end to before the build Products
    products_group_index = project.main_group.children.index { |g| g.name == "Products" } || 2
    project.main_group.children.insert(products_group_index, project.main_group.children.delete(generated_groupref))
end

app_targets.each do |target|
  model_json_rel_path = "$PROJECT_DIR/model-#{target.name}.json"
  generated_file_name = "EntityInfo-#{target.name}.generated.swift"
  generated_code_path = File.join(GENERATED_DIR_PATH, generated_file_name)
  generated_code_rel_path = File.join("$PROJECT_DIR/#{GENERATED_DIR_NAME}", generated_file_name)

  # Find the entry in the project for our generated code file, or create one if none:
  generated_fileref = generated_groupref.files
    .select { |f| f.path == generated_file_name }
    .first
  if generated_fileref.nil?
    puts "Adding code generator output files to target \"#{target.name}\" ..."

    # Create placeholder files so Xcode finds the references
    puts "  Creating file \"#{generated_file_name}\" ..."
    FileUtils.mkdir_p(GENERATED_DIR_PATH)
    File.open(generated_code_path, 'w') do |file|
      file.puts("// Build your project to run Sourcery and create contents for this file\n")
    end

    puts "  Inserting generated file into group \"#{generated_groupref.name}\" ..."
    generated_fileref = generated_groupref.new_file(generated_code_path)

    puts "  Adding generated file to target."
    target.add_file_references([generated_fileref])
  end

  ##
  ## Add Sourcery script generation phase before code compilation
  ##

  # Change target only if it doesn't have the build phase already
  if nil == target.build_phases.index { |p| p.respond_to?(:name) && p.name == SOURCERY_BUILD_PHASE_NAME }

    codegen_phase = target.new_shell_script_build_phase(SOURCERY_BUILD_PHASE_NAME)

    puts "Adding code generation phase to target \"#{target.name}\" ..."

    obx_shell_script = "\"#{OBJECTBOX_REL_GEN_SCRIPT_PATH}\" -- --output \"#{generated_code_rel_path}\" --model-json \"#{model_json_rel_path}\""
    if !target.launchable_target_type? # probably a framework. Add a common use case reminder.
        obx_shell_script << " # add this parameter to make entities exportable: --visibility public"
    end
    codegen_phase.shell_script = obx_shell_script

    # Move code gen phase to the top, before compilation
    compile_phase_index = target.build_phases.index { |p| p.is_a?(Xcodeproj::Project::Object::PBXSourcesBuildPhase) } || 0
    target.build_phases.insert(compile_phase_index, target.build_phases.delete(codegen_phase))
  else
    puts "Skipping target \"#{target.name}\", build phase \"#{SOURCERY_BUILD_PHASE_NAME}\" already exists. Delete it first to re-generate."
  end
end

##
## Save Changes to the Project
##

if project.dirty?
  puts "\nSaving project changes ..."
  project.save
end
