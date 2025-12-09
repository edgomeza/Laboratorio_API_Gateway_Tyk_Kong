package es.unex.aos;

import java.util.HashSet;
import java.util.Set;
import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;
import es.unex.aos.resources.SenoResource;

@ApplicationPath("calculadora")
public class SenoApplication extends Application {

    @Override
    public Set<Class<?>> getClasses() {
        Set<Class<?>> classes = new HashSet<>();
        classes.add(SenoResource.class);
        return classes;
    }
}
