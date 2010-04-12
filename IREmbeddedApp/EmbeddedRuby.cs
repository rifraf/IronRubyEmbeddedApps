using System;
using System.Collections.Generic;
using System.Reflection;
using IronRuby;
using IronRuby.Runtime;
using Microsoft.Scripting;
using Microsoft.Scripting.Hosting;
using Microsoft.Scripting.Hosting.Providers;
using SERFS;

namespace IREmbeddedApp {
    public class EmbeddedRuby {
        private readonly Serfs _serfs;

        public EmbeddedRuby() {
            _serfs = new Serfs(null);
            _serfs.IgnoreMissingAssemblies = true;
            AddAssembly("IREmbeddedApp", "EmbeddedRuby");
        }

        public AssemblyInfo Mount(string topFolder) {
            AssemblyInfo info = _serfs.AddAssembly(Assembly.GetCallingAssembly().GetName().Name);
            info.Mount(topFolder);
            return info;
        }

        public AssemblyInfo AddAssembly(string name) {
            return _serfs.AddAssembly(name);
        }

        public AssemblyInfo AddAssembly(string name, string folder) {
            AssemblyInfo info = _serfs.AddAssembly(name);
            info.Mount(folder);
            return info;
        }

        public int Run(string app) {
            return Run(app, null);
        }

        public int Run(string app, string[] args) {
            ScriptRuntime runtime = Ruby.CreateRuntime();
            ScriptEngine engine = runtime.GetEngine("rb");
            RubyContext context = (RubyContext)HostingHelpers.GetLanguageContext(engine);
            context.ObjectClass.SetConstant("SerfsInstance", _serfs);

            // Sort out ARGV
            string argv;
            if ((args != null) && (args.Length > 0)) {
                List<string> quoted_args = new List<string>();
                foreach (string s in args) {
                    quoted_args.Add("'" + s + "'");
                }
                argv = String.Format("ARGV << {0}\r\n", String.Join(" << ", quoted_args.ToArray()));
            } else {
                argv = "";
            }
            // Prefix bootstrap with $0 and ARGV
            string boot = String.Format(
                //"$0='S:/{0}'\r\n{1}{2}",
                "$0='/{0}' {1}{2}",
                app, argv, _serfs.Read("bootstrap.rb")
                );
            ScriptSource source = engine.CreateScriptSourceFromString(boot, "bootstrap.rb", SourceCodeKind.File);
            int ex = source.ExecuteProgram();
            context.Shutdown();
            return ex;
        }
    }
}
