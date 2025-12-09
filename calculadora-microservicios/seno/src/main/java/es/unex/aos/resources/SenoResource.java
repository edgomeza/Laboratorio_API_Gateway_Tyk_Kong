    package es.unex.aos.resources;

    import jakarta.ws.rs.GET;
    import jakarta.ws.rs.POST;
    import jakarta.ws.rs.Path;
    import jakarta.ws.rs.Produces;
    import jakarta.ws.rs.QueryParam;
    import jakarta.ws.rs.Consumes;
    import jakarta.ws.rs.core.MediaType;
    import es.unex.aos.model.Resultado;

    @Path("/seno")
    public class SenoResource {

        public SenoResource() {
            System.out.println("*** Inicializando recurso SenoResource");
        }

        // GET http://localhost:8080/seno/calculadora/seno?angulo=30
        @GET
        @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
        public Resultado calcularSeno(@QueryParam("angulo") double angulo) {
            System.out.println("GET SENO: sin(" + angulo + "°)");
            
            // Convertir de grados a radianes
            double radianes = Math.toRadians(angulo);
            double resultado = Math.sin(radianes);
            
            return new Resultado(resultado, "Seno calculado correctamente");
        }
    }
