using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Permissions;

// General Information about an assembly is controlled through the following 
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.
[assembly: AssemblyTitle("IREmbeddedApp")]
[assembly: AssemblyDescription("Class to support embedding IronRuby scripts within an Application or Assembly. http://github.com/rifraf/IronRubyEmbeddedApps")]
#if DEBUG
[assembly: AssemblyConfiguration("Debug")]
#elif BETA
[assembly: AssemblyConfiguration("Beta")]
#else
[assembly: AssemblyConfiguration("")]
#endif
[assembly: AssemblyCompany("djlSoft")]
[assembly: AssemblyProduct("IREmbeddedApp")]
[assembly: AssemblyCopyright("Copyright David Lake © 2010")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]

// Setting ComVisible to false makes the types in this assembly not visible 
// to COM components.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: Guid("04947356-1695-4c1c-89a6-b8095f16907f")]

[assembly: AssemblyVersion("0.1.0.$WCREV$")]
[assembly: AssemblyFileVersion("0.1.0.$WCREV$")]
[assembly: AssemblyInformationalVersionAttribute("0.1.0.$WCREV$")]
[assembly: SecurityPermission(SecurityAction.RequestMinimum, Execution = true)]
