package es.unex.aos.resources;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.core.MediaType;
import es.unex.aos.model.Resultado;

@Path("/multiplica")
public class MultiplicaResource {

    public MultiplicaResource() {
        System.out.println("*** Inicializando recurso MultiplicaResource");
    }

    // GET http://localhost:8080/multiplica/calculadora/multiplica?a=10&b=5
    @GET
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Resultado calcularMultiplica(@QueryParam("a") double a, 
                                   @QueryParam("b") double b) {
        System.out.println("GET MULTIPLICA: " + a + " * " + b);
        
        double resultado = a * b;
        return new Resultado(resultado, "Multiplica realizada correctamente");
    }
}