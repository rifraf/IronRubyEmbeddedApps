# -----------------------------------------------------------
# Kernel tweaks
# -----------------------------------------------------------
module Kernel
  # hide RequireSupport.rb from the call chain
  alias irembedded_old_caller caller
  def caller(num = 0)
    callers = irembedded_old_caller(num)
    callers.reject{|f| f =~ /^RequireSupport\.rb:/}
  end
end