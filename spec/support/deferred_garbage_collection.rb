
# https://makandracards.com/makandra/950-speed-up-rspec-by-deferring-garbage-collection
class DeferredGarbageCollection

  DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 10.0).to_f #used to be 10.0

  @@last_gc_run = Time.now

  def self.start
    GC.disable if DEFERRED_GC_THRESHOLD > 0
  end

  def self.reconsider
    if DEFERRED_GC_THRESHOLD > 0 && Time.now - @@last_gc_run >= DEFERRED_GC_THRESHOLD
      GC.enable
      GC.start
      GC.disable
      @@last_gc_run = Time.now
    end
  end

end
