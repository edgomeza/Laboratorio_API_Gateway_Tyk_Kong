    package es.unex.aos.resources;

    import jakarta.ws.rs.GET;
    import jakarta.ws.rs.POST;
    import jakarta.ws.rs.Path;
    import jakarta.ws.rs.Produces;
    import jakarta.ws.rs.QueryParam;
    import jakarta.ws.rs.Consumes;
    import jakarta.ws.rs.core.MediaType;
    import es.unex.aos.model.Resultado;

    @Path("/modulo")
    public class ModuloResource {

        public ModuloResource() {
            System.out.println("*** Inicializando recurso ModuloResource");
        }

        // GET http://localhost:8080/modulo/calculadora/modulo?a=17&b=5
        @GET
        @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
        public Resultado calcularModulo(@QueryParam("a") double a, 
                                        @QueryParam("b") double b) {
            System.out.println("GET MODULO: " + a + " % " + b);
            
            if (b == 0) {
                return new Resultado(Double.NaN, "Error: No se puede calcular módulo con divisor cero");
            }
            
            double resultado = a % b;
            return new Resultado(resultado, "Módulo calculado correctamente");
        }
    }
