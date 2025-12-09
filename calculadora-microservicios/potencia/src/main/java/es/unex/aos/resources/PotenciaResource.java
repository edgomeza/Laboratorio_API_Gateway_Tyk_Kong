    package es.unex.aos.resources;

    import jakarta.ws.rs.GET;
    import jakarta.ws.rs.POST;
    import jakarta.ws.rs.Path;
    import jakarta.ws.rs.Produces;
    import jakarta.ws.rs.QueryParam;
    import jakarta.ws.rs.Consumes;
    import jakarta.ws.rs.core.MediaType;
    import es.unex.aos.model.Resultado;

    @Path("/potencia")
    public class PotenciaResource {

        public PotenciaResource() {
            System.out.println("*** Inicializando recurso PotenciaResource");
        }

        // GET http://localhost:8080/potencia/calculadora/potencia?base=2&exponente=10
        @GET
        @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
        public Resultado calcularPotencia(@QueryParam("base") double base, 
                                          @QueryParam("exponente") double exponente) {
            System.out.println("GET POTENCIA: " + base + "^" + exponente);
            
            double resultado = Math.pow(base, exponente);
            return new Resultado(resultado, "Potencia calculada correctamente");
        }
    }
