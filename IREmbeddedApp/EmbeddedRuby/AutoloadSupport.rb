class SERFS::Serfs

  #---------------------
  # Autoload support
  #---------------------
  def autoloadable
    @autoloadable ||= {}
  end
  
  def autoloaded
    @autoloaded ||= {}
  end		

end

# -----------------------------------------------------------
# Replace Module#autoload with one that uses the new require
# Thanks http://github.com/defunkt/fakefs
# -----------------------------------------------------------
class Module

  alias irembedded_old_const_missing const_missing
  def const_missing(name)
    puts "MISSING #{name}" if SerfsInstance.debug
    SerfsInstance.autoloaded[self] ||= {}
    file = autoload?(name)
    if file and !SerfsInstance.autoloaded[self][name]
      SerfsInstance.autoloaded[self][name] = true
      puts "AUTO.......... #{name}" if SerfsInstance.debug
      require file
      return const_get(name) if const_defined?(name)
    end
    irembedded_old_const_missing(name)
  end
	
  def autoload( name, file_name )
    SerfsInstance.autoloadable[self] ||= {}
    SerfsInstance.autoloadable[self][name] = file_name
  end
	
  def autoload? const
    hsh = SerfsInstance.autoloadable[self]
    return hsh[const] if hsh
  end	
  
end
