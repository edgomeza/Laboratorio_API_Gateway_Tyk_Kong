    package es.unex.aos.resources;

    import jakarta.ws.rs.GET;
    import jakarta.ws.rs.POST;
    import jakarta.ws.rs.Path;
    import jakarta.ws.rs.Produces;
    import jakarta.ws.rs.QueryParam;
    import jakarta.ws.rs.Consumes;
    import jakarta.ws.rs.core.MediaType;
    import es.unex.aos.model.Resultado;

    @Path("/logaritmo")
    public class LogaritmoResource {

        public LogaritmoResource() {
            System.out.println("*** Inicializando recurso LogaritmoResource");
        }

        // GET http://localhost:8080/logaritmo/calculadora/logaritmo?n=100
        @GET
        @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
        public Resultado calcularLogaritmo(@QueryParam("n") double n) {
            System.out.println("GET LOGARITMO: ln(" + n + ")");
            
            if (n <= 0) {
                return new Resultado(Double.NaN, "Error: El logaritmo solo está definido para números positivos");
            }
            
            double resultado = Math.log(n);
            return new Resultado(resultado, "Logaritmo natural calculado correctamente");
        }
    }
