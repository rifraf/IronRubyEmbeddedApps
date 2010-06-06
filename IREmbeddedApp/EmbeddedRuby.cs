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
        private ScriptRuntime _runtime;
        private ScriptEngine _engine;
        private RubyContext _context;

        public EmbeddedRuby() {
            _serfs = new Serfs(null);
            _serfs.IgnoreMissingAssemblies = true;
            AddAssembly("IREmbeddedApp");
            Reset();
        }

        public void Reset() {
            _runtime = Ruby.CreateRuntime();
            _engine = _runtime.GetEngine("rb");
            _context = (RubyContext)HostingHelpers.GetLanguageContext(_engine);
        }

        public IStreamDecoder Decoder {
            set { _serfs.Decoder = value; }
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

        public void SetConstant(string name, object obj) {
            _context.ObjectClass.SetConstant(name, obj);    
        }

        public int Run(string app) {
            return Run(app, null);
        }

        public int Run(string app, string[] args) {
            SetConstant("SerfsInstance", _serfs);

            Assembly exe = Assembly.GetEntryAssembly();
            string serfs_assy = exe.FullName;

            try {
                serfs_assy = Assembly.Load("Serfs").FullName;
            }
            catch (System.IO.FileNotFoundException) {
                // Allowed : it means whe have been ILMerged
            }

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
            // Create boot up script
            string boot = String.Format(@"$0='/{0}'
SerfsDll = '{3}'
{1}{2}
require 'EmbeddedRuby/LoadSupport'
require 'EmbeddedRuby/AutoloadSupport'
require 'EmbeddedRuby/IOSupport'
require 'EmbeddedRuby/FileSupport'
require 'EmbeddedRuby/Misc'
require 'EmbeddedRuby/AppBoot' if File.exist?('EmbeddedRuby/AppBoot.rb')
load $0.dup if $0
"
                , app, argv, _serfs.Read("EmbeddedRuby/RequireSupport.rb"), serfs_assy);

            ScriptSource source = _engine.CreateScriptSourceFromString(boot, "RequireSupport.rb", SourceCodeKind.File);
            int ex = source.ExecuteProgram();
            _context.Shutdown();
            return ex;
        }
    }
}
