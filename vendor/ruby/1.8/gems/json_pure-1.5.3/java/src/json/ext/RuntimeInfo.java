/*
 * This code is copyrighted work by Daniel Luz <dev at mernen dot com>.
 *
 * Distributed under the Ruby and GPLv2 licenses; see COPYING and GPL files
 * for details.
 */
package json.ext;

import java.lang.ref.WeakReference;
import java.util.HashMap;
import java.util.Map;
import java.util.WeakHashMap;
import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyEncoding;
import org.jruby.RubyModule;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;


final class RuntimeInfo {
    // since the vast majority of cases runs just one runtime,
    // we optimize for that
    private static WeakReference<Ruby> runtime1 = new WeakReference<Ruby>(null);
    private static RuntimeInfo info1;
    // store remaining runtimes here (does not include runtime1)
    private static Map<Ruby, RuntimeInfo> runtimes;

    // these fields are filled by the service loaders
    /** JSON */
    RubyModule jsonModule;
    /** JSON::Ext::Generator::GeneratorMethods::String::Extend */
    RubyModule stringExtendModule;
    /** JSON::Ext::Generator::State */
    RubyClass generatorStateClass;
    /** JSON::SAFE_STATE_PROTOTYPE */
    GeneratorState safeStatePrototype;

    final RubyEncoding utf8;
    final RubyEncoding ascii8bit;
    // other encodings
    private final Map<String, RubyEncoding> encodings;

    private RuntimeInfo(Ruby runtime) {
        RubyClass encodingClass = runtime.getEncoding();
        if (encodingClass == null) { // 1.8 mode
            utf8 = ascii8bit = null;
            encodings = null;
        } else {
            ThreadContext context = runtime.getCurrentContext();

            utf8 = (RubyEncoding)RubyEncoding.find(context,
                    encodingClass, runtime.newString("utf-8"));
            ascii8bit = (RubyEncoding)RubyEncoding.find(context,
                    encodingClass, runtime.newString("ascii-8bit"));
            encodings = new HashMap<String, RubyEncoding>();
        }
    }

    static RuntimeInfo initRuntime(Ruby runtime) {
        synchronized (RuntimeInfo.class) {
            if (runtime1.get() == runtime) {
                return info1;
            } else if (runtime1.get() == null) {
                runtime1 = new WeakReference<Ruby>(runtime);
                info1 = new RuntimeInfo(runtime);
                return info1;
            } else {
                if (runtimes == null) {
                    runtimes = new WeakHashMap<Ruby, RuntimeInfo>(1);
                }
                RuntimeInfo cache = runtimes.get(runtime);
                if (cache == null) {
                    cache = new RuntimeInfo(runtime);
                    runtimes.put(runtime, cache);
                }
                return cache;
            }
        }
    }

    public static RuntimeInfo forRuntime(Ruby runtime) {
        synchronized (RuntimeInfo.class) {
            if (runtime1.get() == runtime) return info1;
            RuntimeInfo cache = null;
            if (runtimes != null) cache = runtimes.get(runtime);
            assert cache != null : "Runtime given has not initialized JSON::Ext";
            return cache;
        }
    }

    public boolean encodingsSupported() {
        return utf8 != null;
    }

    public RubyEncoding getEncoding(ThreadContext context, String name) {
        synchronized (encodings) {
            RubyEncoding encoding = encodings.get(name);
            if (encoding == null) {
                Ruby runtime = context.getRuntime();
                encoding = (RubyEncoding)RubyEncoding.find(context,
                        runtime.getEncoding(), runtime.newString(name));
                encodings.put(name, encoding);
            }
            return encoding;
        }
    }

    public GeneratorState getSafeStatePrototype(ThreadContext context) {
        if (safeStatePrototype == null) {
            IRubyObject value = jsonModule.getConstant("SAFE_STATE_PROTOTYPE");
            if (!(value instanceof GeneratorState)) {
                throw context.getRuntime().newTypeError(value, generatorStateClass);
            }
            safeStatePrototype = (GeneratorState)value;
        }
        return safeStatePrototype;
    }
}
