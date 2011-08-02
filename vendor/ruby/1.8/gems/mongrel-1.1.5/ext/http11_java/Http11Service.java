import java.io.IOException;
        
import org.jruby.Ruby;
import org.jruby.runtime.load.BasicLibraryService;

import org.jruby.mongrel.Http11;

public class Http11Service implements BasicLibraryService { 
    public boolean basicLoad(final Ruby runtime) throws IOException {
        Http11.createHttp11(runtime);
        return true;
    }
}
