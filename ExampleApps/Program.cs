using System;
using IREmbeddedApp;

namespace IronRubyConsole {

    class Program {

        static int Main(string[] args) {
            int exitcode = 0;

            // First application : bottles
            Console.WriteLine("bottles.rb");
            Console.WriteLine("----------");
            try {
                EmbeddedRuby er1 = new EmbeddedRuby();
                er1.Mount("Applications");
                exitcode = er1.Run("bottles.rb");
            } catch (Exception e) {
                Console.WriteLine(e.Message);
            }
            Console.WriteLine();

            // list_args.rb
            Console.WriteLine("list_args.rb");
            Console.WriteLine("----------");
            try {
                EmbeddedRuby er1 = new EmbeddedRuby();
                er1.Mount("Applications");
                exitcode = er1.Run("list_args.rb", args);
            } catch (Exception e) {
                Console.WriteLine(e.Message);
            }
            Console.WriteLine();

            // Demo of test::unit
            Console.WriteLine("test_unit_app.rb");
            Console.WriteLine("----------------");
            try {
                EmbeddedRuby er2 = new EmbeddedRuby();
                er2.AddAssembly("IRTestResources", "Files/Core").Mount("Files/TestUnit");
                er2.Mount("Applications");
                exitcode = er2.Run("test_unit_app.rb");
            } catch (Exception e) {
                Console.WriteLine(e.Message);
            }
            Console.WriteLine();

            // Demo of test::unit and flexmock
            Console.WriteLine("test_mocking_app.rb");
            Console.WriteLine("-------------------");
            try {
                EmbeddedRuby er3 = new EmbeddedRuby();
                er3.AddAssembly("IRTestResources", "Files/Core").Mount("Files/FlexMock").Mount("Files/TestUnit");
                er3.Mount("Applications");
                exitcode = er3.Run("test_mocking_app.rb");
            } catch (Exception e) {
                Console.WriteLine(e.Message);
            }
            Console.WriteLine();

            return exitcode;
        }
    }
}

