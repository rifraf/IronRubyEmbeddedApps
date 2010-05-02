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
[assembly: AssemblyCopyright("Copyright David Lake © 2010")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]

// Setting ComVisible to false makes the types in this assembly not visible 
// to COM components.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: Guid("e94d3130-fea2-47da-962b-6ee0965a42d4")]

[assembly: AssemblyVersion("0.1.0.11536")]
[assembly: AssemblyFileVersion("0.1.0.11536")]
[assembly: AssemblyInformationalVersionAttribute("0.1.0.11536")]
[assembly: SecurityPermission(SecurityAction.RequestMinimum, Execution = true)]
