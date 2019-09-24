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
idtypedefpos = 0

headerguard = "#define OBJECTBOX_H\n"
headerguardpos = code.index(headerguard)
headerguardpos += headerguard.length
destfile.print code[0, headerguardpos]
code[0, headerguardpos + 1] = ""

destfile.print %{
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

#if __APPLE__ && __OBJC__
  #define OBX_SWIFT_NAME(_name) NS_SWIFT_NAME(_name)
#else
  #define OBX_SWIFT_NAME(_name)
#endif
}
    
def camelCase(string)
	if string.include? "_" or string =~ /^[A-Z]+$/ then
		string2 = string.downcase
		string.scan(/_[A-Za-z]/) { |match|
			range = $~.offset(0)
			string2[range[0]..(range[1] - 1)] = "_#{match[1].upcase}"
		}
		return string2.tr("_", "")
	elsif string =~ /^[A-Z][A-Za-z0-9]+$/ then
		return "#{string[0].downcase}#{string[1..(string.length - 1)]}"
	else
		return string
	end
end


while typedefpos != nil or idtypedefpos != nil do
	typedefpos = code.index("typedef enum {")
    idtypedefpos = code.index("typedef uint64_t obx_id;")
	if typedefpos == nil && idtypedefpos == nil then
		break
	end

    if typedefpos == nil or (idtypedefpos != nil and idtypedefpos < typedefpos) then
        destfile.print code[0, idtypedefpos]

        idtypedefendpos = code.index(";", idtypedefpos)
        if idtypedefendpos == nil then
            break
        end

        destfile.print code[idtypedefpos, idtypedefendpos - idtypedefpos]
        destfile.print " OBX_SWIFT_NAME(Id);"

        code[0, idtypedefendpos + 1] = ""
    else
        destfile.print code[0, typedefpos]

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
        if name.start_with? "OBX" then
            swiftname = "#{name[3..-1]}"
        else
            swiftname = name
        end
        
        enumbody = code[enumstartpos, enumendpos - enumstartpos]
        
        # Make enum names adhere to Swift conventions:
        caseNames=Array.new
        enumbody.scan(/([A-Za-z0-9]+)_([A-Za-z0-9_]+)([ \t]*=[ \t]*[A-Za-z0-9]){0,1}/) { |match| casename=camelCase(match[1])
        caseNames.push( {"range" => $~.offset(2), "text" => casename}) }

        caseNames.reverse.each { |x| enumbody[x["range"][0]..(x["range"][1] - 1)] = x["text"] }

        # Output enum body
        destfile.puts enumbody
        
        destfile.puts "} OBX_SWIFT_NAME(#{swiftname});"
        
        code[0, enumnameendpos + 1] = ""
    end
end

destfile.print code

destfile.close
