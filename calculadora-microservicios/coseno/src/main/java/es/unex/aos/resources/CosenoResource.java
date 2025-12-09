    package es.unex.aos.resources;

    import jakarta.ws.rs.GET;
    import jakarta.ws.rs.POST;
    import jakarta.ws.rs.Path;
    import jakarta.ws.rs.Produces;
    import jakarta.ws.rs.QueryParam;
    import jakarta.ws.rs.Consumes;
    import jakarta.ws.rs.core.MediaType;
    import es.unex.aos.model.Resultado;

    @Path("/coseno")
    public class CosenoResource {

        public CosenoResource() {
            System.out.println("*** Inicializando recurso CosenoResource");
        }

        // GET http://localhost:8080/coseno/calculadora/coseno?angulo=60
        @GET
        @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
        public Resultado calcularCoseno(@QueryParam("angulo") double angulo) {
            System.out.println("GET COSENO: cos(" + angulo + "°)");
            
            // Convertir de grados a radianes
            double radianes = Math.toRadians(angulo);
            double resultado = Math.cos(radianes);
            
            return new Resultado(resultado, "Coseno calculado correctamente");
        }
    }
