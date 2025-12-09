    package es.unex.aos.resources;

    import jakarta.ws.rs.GET;
    import jakarta.ws.rs.POST;
    import jakarta.ws.rs.Path;
    import jakarta.ws.rs.Produces;
    import jakarta.ws.rs.QueryParam;
    import jakarta.ws.rs.Consumes;
    import jakarta.ws.rs.core.MediaType;
    import es.unex.aos.model.Resultado;

    @Path("/raiz")
    public class RaizResource {

        public RaizResource() {
            System.out.println("*** Inicializando recurso RaizResource");
        }

        // GET http://localhost:8080/raiz/calculadora/raiz?n=25
        @GET
        @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
        public Resultado calcularRaiz(@QueryParam("n") double n) {
            System.out.println("GET RAIZ: √" + n);
            
            if (n < 0) {
                return new Resultado(Double.NaN, "Error: No se puede calcular raíz cuadrada de número negativo");
            }
            
            double resultado = Math.sqrt(n);
            return new Resultado(resultado, "Raíz cuadrada calculada correctamente");
        }
    }
