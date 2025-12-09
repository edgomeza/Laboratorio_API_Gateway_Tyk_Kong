package es.unex.aos;

import java.util.HashSet;
import java.util.Set;
import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;
import es.unex.aos.resources.TangenteResource;

@ApplicationPath("calculadora")
public class TangenteApplication extends Application {

    @Override
    public Set<Class<?>> getClasses() {
        Set<Class<?>> classes = new HashSet<>();
        classes.add(TangenteResource.class);
        return classes;
    }
}
