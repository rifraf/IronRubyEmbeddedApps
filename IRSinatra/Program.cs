using System;
using IREmbeddedApp;
using SERFS;

namespace IronRubyConsole {

    class Program {

        static int Main(string[] args) {
            int exitcode = 0;

            try {
                EmbeddedRuby er = new EmbeddedRuby();
                AssemblyInfo resources = er.AddAssembly("IREmbeddedLibraries");
                resources.Mount("Files/ironruby");
                resources.Mount("Files/rack-1.1.0/lib");
                resources.Mount("Files/sinatra-1.0/lib");
                resources.Mount("Files/site_ruby/1.8");
                resources.Mount("Files/1.8");

                er.Mount("Applications");
                exitcode = er.Run("sinatra_app.rb", args);
            } catch (Exception e) {
                Console.WriteLine(e.Message);
            }
            Console.WriteLine();

            return exitcode;
        }
    }
}

