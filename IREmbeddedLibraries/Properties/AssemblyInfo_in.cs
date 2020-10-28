using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Permissions;

// General Information about an assembly is controlled through the following 
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.
[assembly: AssemblyTitle("IREmbeddedLibraries")]
[assembly: AssemblyDescription("Assembly containing Ruby source files from library. http://github.com/rifraf/IronRubyEmbeddedApps")]
#if DEBUG
[assembly: AssemblyConfiguration("Debug")]
#elif BETA
[assembly: AssemblyConfiguration("Beta")]
#else
[assembly: AssemblyConfiguration("")]
#endif
[assembly: AssemblyCompany("djlSoft")]
[assembly: AssemblyProduct("IREmbeddedLibraries")]
[assembly: AssemblyCopyright("Copyright David Lake © 2010-2020")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]

// Setting ComVisible to false makes the types in this assembly not visible 
// to COM components.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: ComVisible(false)]

[assembly: AssemblyVersion("0.2.0.$WCREV$")]
[assembly: AssemblyFileVersion("0.2.0.$WCREV$")]
[assembly: AssemblyInformationalVersionAttribute("0.2.0.$WCREV$")]
