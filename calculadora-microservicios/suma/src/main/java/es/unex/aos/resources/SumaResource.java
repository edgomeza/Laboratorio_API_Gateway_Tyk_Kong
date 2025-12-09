    package es.unex.aos.resources;

    import jakarta.ws.rs.GET;
    import jakarta.ws.rs.POST;
    import jakarta.ws.rs.Path;
    import jakarta.ws.rs.Produces;
    import jakarta.ws.rs.QueryParam;
    import jakarta.ws.rs.Consumes;
    import jakarta.ws.rs.core.MediaType;
    import es.unex.aos.model.Resultado;

    @Path("/suma")
    public class SumaResource {

        public SumaResource() {
            System.out.println("*** Inicializando recurso SumaResource");
        }

        // GET http://localhost:8080/suma/calculadora/suma?a=10&b=5
        @GET
        @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
        public Resultado calcularSuma(@QueryParam("a") double a, 
                                    @QueryParam("b") double b) {
            System.out.println("GET SUMA: " + a + " + " + b);
            
            double resultado = a + b;
            return new Resultado(resultado, "Suma realizada correctamente");
        }
    }