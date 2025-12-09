package es.unex.aos.resources;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.core.MediaType;
import es.unex.aos.model.Resultado;

@Path("/resta")
public class RestaResource {

    public RestaResource() {
        System.out.println("*** Inicializando recurso RestaResource");
    }

    // GET http://localhost:8080/resta/calculadora/resta?a=10&b=5
    @GET
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Resultado calcularResta(@QueryParam("a") double a, 
                                   @QueryParam("b") double b) {
        System.out.println("GET RESTA: " + a + " - " + b);
        
        double resultado = a - b;
        return new Resultado(resultado, "Resta realizada correctamente");
    }
}