    package es.unex.aos.resources;

    import jakarta.ws.rs.GET;
    import jakarta.ws.rs.POST;
    import jakarta.ws.rs.Path;
    import jakarta.ws.rs.Produces;
    import jakarta.ws.rs.QueryParam;
    import jakarta.ws.rs.Consumes;
    import jakarta.ws.rs.core.MediaType;
    import es.unex.aos.model.Resultado;

    @Path("/tangente")
    public class TangenteResource {

        public TangenteResource() {
            System.out.println("*** Inicializando recurso TangenteResource");
        }

        // GET http://localhost:8080/tangente/calculadora/tangente?angulo=45
        @GET
        @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
        public Resultado calcularTangente(@QueryParam("angulo") double angulo) {
            System.out.println("GET TANGENTE: tan(" + angulo + "°)");
            
            // Convertir de grados a radianes
            double radianes = Math.toRadians(angulo);
            double resultado = Math.tan(radianes);
            
            return new Resultado(resultado, "Tangente calculada correctamente");
        }
    }
