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

class String
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def brown;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end
    
  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end
    
  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end

##
## Figure out app project path
##

HELPER_FILES_ROOT = File.dirname(File.realpath(__FILE__))
REL_OBJECTBOX_POD_ROOT = HELPER_FILES_ROOT.match(/.*\/Pods\/.*?\//) # Naïve heuristic for finding out if the user uses CocoaPods.
if REL_OBJECTBOX_POD_ROOT.nil?
  OBJECTBOX_POD_ROOT = ""
  is_cocoapods = false
else
  OBJECTBOX_POD_ROOT = File.expand_path("#{REL_OBJECTBOX_POD_ROOT}")
  is_cocoapods = true
end
POD_NAME = File.basename(OBJECTBOX_POD_ROOT)

args=ARGV
SHOULD_SHOW_HELP = args.delete("--help") != nil
SHOULD_REPLACE_MODIFIED_SCRIPTS = args.delete("--replace-modified") != nil
SHOULD_SKIP_MODIFIED_SCRIPTS = args.delete("--skip-modified") != nil
SHOULD_INTERACT = (ENV["TERM"] != "") and (ENV["TERM"] != "dumb")

if SHOULD_SHOW_HELP
  print "usage: ".bold
  puts "setup.rb [<options>] [<projectPath> [<targetName>]]"
  puts ""
  puts "Add the required files and build phases to the Xcode project <projectPath> to"
  puts "run the ObjectBox code generator over each target's files."
  puts ""
  puts "You can specify a particular target to add ObjectBox to. If you omit the target"
  puts "name, all targets in the project that produce a runnable executable will be set"
  puts "up for ObjectBox."
  puts ""
  puts "Options".bold
  puts "    --replace-modified  If a target's script phase already exists and has been"
  puts "                        modified, replace it with the unmodified version of"
  puts "                        the script."
  puts "    --skip-modified     If a target already has a script phase and it has been"
  puts "                        modified, do nothing with this target."
  puts "    --help              Display this help text."
  puts ""
  exit 0
end

puts " ObjectBox Project Setup ".reverse_color
puts ""

if args.size > 0
  PROJECT_FILE_NAME = args[0]
  if File.exists?(PROJECT_FILE_NAME)
    project_path = PROJECT_FILE_NAME
    # Use realpath otherwise Xcode interprets any "." in the path and the working dir is different.
    PROJECT_ROOT = File.realpath(File.dirname(PROJECT_FILE_NAME))
  elsif is_cocoapods
    # Use realpath otherwise Xcode interprets any "." in the path and the working dir is different.
    PROJECT_ROOT = File.realpath(File.expand_path(File.join(File.dirname(__FILE__), "..", "..")))
    project_path = File.join(PROJECT_ROOT, PROJECT_FILE_NAME)
  end
  if !File.exists?(project_path)
    puts "🛑 Could not find Xcode project at \"#{project_path}\""
    puts ""
    exit 1
  end
else
  PROJECT_ROOT = File.expand_path(".")
  PROJECT_BASENAME = File.basename(PROJECT_ROOT)
  puts "🔸 Looking for project files in the current directory ..."
  project_files = Dir.glob(File.join(PROJECT_ROOT, "*.xcodeproj"))
  if project_files.empty?
    puts "🛑 Could not find a project file in \"#{PROJECT_ROOT}\"."
    puts ""
    exit 1
  end
  project_files.sort_by!{ |m| m.downcase } # Make following call more deterministic, APFS returns you files in any random order.

  if SHOULD_INTERACT and project_files.count() > 1
    default_project_file = nil
    puts "Several projects found. Which one do you want to set up?"
    item_number=1
    project_files.each do |curr_project_file|
      curr_project_basename = File.basename(curr_project_file)
      if curr_project_basename == "#{PROJECT_BASENAME}.xcodeproj" # Make most likely one bold & default
        default_project_file = curr_project_file
        curr_project_basename = curr_project_basename.bold
      end
      puts "#{item_number.to_s.rjust(4)}. #{curr_project_basename}"
      item_number += 1
    end
    print "Enter the number of the project you'd like to use:"
    if default_project_file != nil
      print " [#{File.basename(default_project_file)}]"
    end
    puts ""
    print "> "
    user_input = STDIN.gets
    
    # Allow picking project with same name as folder by hitting return:
    if user_input == "\n" and not default_project_file.nil?
      project_path = default_project_file
    else
      # If not default, try to resolve project by number:
      desired_index = Integer(user_input) rescue nil
      if desired_index == nil or desired_index > project_files.count() or desired_index < 1
        puts "🛑 Input doesn't correspond to a list entry."
        puts ""
        exit
      end
      desired_index -= 1
      project_path = project_files[desired_index]
    end
  elsif project_files.count() == 1
    puts "🔸 Found a single project."
    project_path = project_files[0]
  else
    # Non-interactive or only one project in folder? Try old behaviour:
    puts "🔸 Trying to find project named like parent folder \"#{PROJECT_BASENAME}\"."
    
    project_path = File.join(PROJECT_ROOT, "#{PROJECT_BASENAME}.xcodeproj")
    if !File.exists?(project_path)
      puts "🛑 Multiple projects found. Please specify which project you want as an argument to this script."
      exit 1
    end
  end
end

# Generate the correct path to write into the "run shell script" build phase:
if is_cocoapods # Use path relative to the PODS_ROOT setting for CocoaPods:
  OBJECTBOX_GEN_SCRIPT_PATH = "$PODS_ROOT/#{POD_NAME}/generate_sources.sh"
  OBJECTBOX_REL_GEN_SCRIPT_PATH = OBJECTBOX_GEN_SCRIPT_PATH
else # Use paths relative to the project itself for non-CocoaPods:
  OBJECTBOX_GEN_SCRIPT_PATH = File.join(HELPER_FILES_ROOT, "generate_sources.sh")
  proj_pathname = Pathname.new PROJECT_ROOT
  script_pathname = Pathname.new OBJECTBOX_GEN_SCRIPT_PATH
  TMP_PATH = script_pathname.relative_path_from proj_pathname
  OBJECTBOX_REL_GEN_SCRIPT_PATH = "$PROJECT_DIR/" + "#{TMP_PATH}"
end

puts "🔸 Using \"#{File.dirname(project_path).gray}/#{File.basename(project_path).bold}\""

##
## Add the generated Swift files to the project
##

project = Xcodeproj::Project.open(project_path)

if ARGV.size > 1
  TARGET_NAME = ARGV[1]
  app_targets = project.targets.select { |t| t.name == TARGET_NAME }
  if app_targets.size == 0
    puts "🛑 Could not find Xcode target \"#{TARGET_NAME}\" in \"#{project_path}\""
    puts ""
    exit 1
  end
else # If not given a path, just pick all targets that result in runnables (hopefully the Mac and iOS app targets):
  app_targets = project.targets.select { |t| t.launchable_target_type? }
  if app_targets.size == 0
    puts "🛑 No launchable Xcode targets found in \"#{project_path}\""
    puts "ℹ️ Please specify project and target explicitly; run with --help for help"
    puts ""
    exit 1
  end
end

SOURCERY_BUILD_PHASE_NAME = "[OBX] Update Sourcery Generated Files"
GENERATED_DIR_NAME = "generated"
GENERATED_DIR_PATH = File.join(PROJECT_ROOT, GENERATED_DIR_NAME)

# Find any existing build phase, or add one if missing:
generated_groupref = project.groups
.select { |g| g.path == GENERATED_DIR_NAME }
.first
if generated_groupref.nil?
    puts "🔹 Adding a new group for generated files at `./#{GENERATED_DIR_NAME}/`..."

    generated_groupref = project.new_group("generated", GENERATED_DIR_NAME)

    # Move group from the end to before the build Products
    products_group_index = project.main_group.children.index { |g| g.name == "Products" } || 2
    project.main_group.children.insert(products_group_index, project.main_group.children.delete(generated_groupref))
end

app_targets.each do |target|
  puts ""
  puts "Target \"#{target.name}\":".bold
  puts ""
  model_json_rel_path = "$PROJECT_DIR/model-#{target.name}.json"
  generated_file_name = "EntityInfo-#{target.name}.generated.swift"
  generated_code_path = File.join(GENERATED_DIR_PATH, generated_file_name)
  generated_code_rel_path = File.join("$PROJECT_DIR/#{GENERATED_DIR_NAME}", generated_file_name)

  # Find the entry in the project for our generated code file, or create one if none:
  generated_fileref = generated_groupref.files
    .select { |f| f.path == generated_file_name }
    .first
  if generated_fileref.nil?
    # Create placeholder files so Xcode finds the references
    puts "  🔹 Creating file \"#{generated_file_name}\" ..."
    FileUtils.mkdir_p(GENERATED_DIR_PATH)
    empty_generated_file_template = File.read(HELPER_FILES_ROOT + "/empty.generated.swift")
    File.open(generated_code_path, 'w') do |file|
      file.puts("// Build your project to run Sourcery and create current contents for this file\n\n#{empty_generated_file_template}")
    end

    puts "  🔹 Inserting generated file into group \"#{generated_groupref.name}\" ..."
    generated_fileref = generated_groupref.new_file(generated_code_path)

    puts "  🔹 Adding generated file to target."
    target.add_file_references([generated_fileref])
  end

  ##
  ## Add Sourcery script generation phase before code compilation
  ##

  # Compose the shell script we want to run at the start of this target in the project:
  obx_shell_script = "\"#{OBJECTBOX_REL_GEN_SCRIPT_PATH}\" -- --output \"#{generated_code_rel_path}\" --model-json \"#{model_json_rel_path}\""
  if !target.launchable_target_type? # probably a framework. Add a common use case reminder.
      obx_shell_script << " # add this parameter to make entities exportable: --visibility public"
  end

  # Change target only if it doesn't have the build phase already
  build_phase_index = target.build_phases.index { |p| p.respond_to?(:name) && p.name == SOURCERY_BUILD_PHASE_NAME }
  if nil == build_phase_index
    codegen_phase = target.new_shell_script_build_phase(SOURCERY_BUILD_PHASE_NAME)

    puts "  🔹 Adding code generation phase ..."
    codegen_phase.shell_script = obx_shell_script

    # Move code gen phase to the top, before compilation
    compile_phase_index = target.build_phases.index { |p| p.is_a?(Xcodeproj::Project::Object::PBXSourcesBuildPhase) } || 0
    target.build_phases.insert(compile_phase_index, target.build_phases.delete(codegen_phase))

    puts "  ✅ Done."
  else
    existing_script = target.build_phases[build_phase_index].shell_script

    # If we ever modify the shell script build phase in a later release, this comparison needs to be updated to detect
    # when existing_script is outdated. It can upgrade it to the new version instead of claiming it had been modified.
    if existing_script == obx_shell_script
      puts "  🔹 Skipping target \"#{target.name}\", build phase \"#{SOURCERY_BUILD_PHASE_NAME}\" already up to date."
    else
      puts "  🔸 Script was modified."
      puts "  🔸 Existing script: #{existing_script}"
      puts "  🔸 Expected script: #{obx_shell_script}"

      if SHOULD_REPLACE_MODIFIED_SCRIPTS
        shouldreplace = "y"
      elsif SHOULD_SKIP_MODIFIED_SCRIPTS
        shouldreplace = "n"
      else
        puts "  ⚪️ Target \"#{target.name}\" already has a build phase \"#{SOURCERY_BUILD_PHASE_NAME}\" with a diverging script."
        print "  Replace the script with the recommended script? [y/N] "
        response = STDIN.gets
        if response.nil?
            STDERR.puts("Got no input. If you are running this from a script, consider the --replace-modified option.")
            exit(1)
        end
        shouldreplace = response.downcase
      end
      if shouldreplace.start_with?("y")
        target.build_phases[build_phase_index].shell_script = obx_shell_script
        puts "  ✅ Updated script."
      else
        puts "  🔹 Skipped target \"#{target.name}\"."
      end
    end
  end
end

##
## Save Changes to the Project
##

puts ""
if project.dirty?
  project.save
  puts " ✅ Project changes saved. ".reverse_color
else
  puts " 🔸 No changes made to project. ".reverse_color
  puts " ℹ️ If your code generation was not setup properly run with --help to see options"
end
if is_cocoapods
  puts ""
  puts " 💬 Please remember to use the .xcworkspace CocoaPods created from now on instead of your project."
end
puts ""
