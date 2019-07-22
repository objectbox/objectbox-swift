#!/usr/bin/ruby

# Syntax:
#   ./generate_ObjectBoxC_header.rb external/objectbox-static/objectbox.h ObjectBoxC.h
#
# Helper script that postprocesses our objectbox.h header and decorates any
#   typedef enum {
#       ...
#   } Foo;
# with NS_ENUM()/NS_OPTIONS() macros so Swift can import them properly.
#
# Note that this relies on macOS using at least an int as the size for an enum,
# as we currently have to guess at enum sizes. It also assumes all bit field enums'
# names end with "Flags".

sourcepath = ARGV[0]
destpath = ARGV[1]

puts "note: Processing header #{sourcepath} into #{destpath}"

code = File.read(sourcepath)
destfile = File.open(destpath, "w")

typedefpos = 0

headerguard = "#define OBJECTBOX_H\n"
headerguardpos = code.index(headerguard)
headerguardpos += headerguard.length
destfile.puts code[0, headerguardpos]
code[0, headerguardpos + 1] = ""

destfile.puts %{
// Helper macros to make bit flags accessible from Swift. Also a nice shorthand for defining an enum and making sure
// its data type is typedefed to a fixed size in C++ and C, so our API remains binary stable.
#if __APPLE__ && __OBJC__
  #define OBX_ENUM(type, name) NS_ENUM(type, name)
  #define OBX_OPTIONS(type, name) NS_OPTIONS(type, name)
#elif defined(__clang__)
  #if (__cplusplus && __cplusplus >= 201103L && (__has_extension(cxx_strong_enums) || __has_feature(objc_fixed_enum))) || (!__cplusplus && __has_feature(objc_fixed_enum))
    #define OBX_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
    #if (__cplusplus)
      #define OBX_OPTIONS(_type, _name) _type _name; enum : _type
    #else
      #define OBX_OPTIONS(_type, _name) enum _name : _type _name; enum _name : _type
    #endif
  #else
    #define OBX_ENUM(_type, _name) _type _name; enum
    #define OBX_OPTIONS(_type, _name) _type _name; enum
  #endif
#else
  #define OBX_ENUM(_type, _name) _type _name; enum
  #define OBX_OPTIONS(_type, _name) _type _name; enum
#endif

}

while typedefpos != nil do
	typedefpos = code.index("typedef enum {")
	if typedefpos == nil then
		break
	end

	destfile.puts code[0, typedefpos]
	
	enumendpos = code.index("}", typedefpos)
	if enumendpos == nil then
		break
	end
	enumstartpos = code.index("{", typedefpos)
	if enumstartpos == nil then
		break
	end
	enumstartpos = code.index("\n", enumstartpos + 1)
	if enumstartpos == nil then
		break
	end
	enumstartpos += 1
	enumnameendpos = code.index(";", enumendpos + 1)
	if enumnameendpos == nil then
		break
	end

	name = code[enumendpos + 1, enumnameendpos - enumendpos - 1].strip
	if name.end_with? "Flags" then
		destfile.puts "typedef OBX_OPTIONS(unsigned int, #{name}) {"
	else
		destfile.puts "typedef OBX_ENUM(unsigned int, #{name}) {"
	end
	
	enumbody = code[enumstartpos, enumendpos - enumstartpos]
	
	destfile.puts enumbody
	
	destfile.puts "};"
	
	code[0, enumnameendpos + 1] = ""
		
end

destfile.puts code

destfile.close
