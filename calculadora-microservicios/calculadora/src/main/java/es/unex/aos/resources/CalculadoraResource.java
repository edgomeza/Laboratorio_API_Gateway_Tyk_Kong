package es.unex.aos.resources;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.WebTarget;
import es.unex.aos.model.Resultado;
import com.google.gson.Gson;

@Path("/calc")
public class CalculadoraResource {

    // V1 - Operaciones Básicas
    private static final String SUMA_URL = System.getenv().getOrDefault("SUMA_URL", "http://localhost:8081/suma/calculadora/suma");
    private static final String RESTA_URL = System.getenv().getOrDefault("RESTA_URL", "http://localhost:8082/resta/calculadora/resta");
    private static final String MULTIPLICA_URL = System.getenv().getOrDefault("MULTIPLICA_URL", "http://localhost:8083/multiplica/calculadora/multiplica");
    private static final String DIVIDE_URL = System.getenv().getOrDefault("DIVIDE_URL", "http://localhost:8084/divide/calculadora/divide");

    // V2 - Operaciones Científicas
    private static final String RAIZ_URL = System.getenv().getOrDefault("RAIZ_URL", "http://localhost:8086/raiz/calculadora/raiz");
    private static final String POTENCIA_URL = System.getenv().getOrDefault("POTENCIA_URL", "http://localhost:8087/potencia/calculadora/potencia");
    private static final String MODULO_URL = System.getenv().getOrDefault("MODULO_URL", "http://localhost:8088/modulo/calculadora/modulo");
    private static final String LOGARITMO_URL = System.getenv().getOrDefault("LOGARITMO_URL", "http://localhost:8089/logaritmo/calculadora/logaritmo");
    private static final String SENO_URL = System.getenv().getOrDefault("SENO_URL", "http://localhost:8090/seno/calculadora/seno");
    private static final String COSENO_URL = System.getenv().getOrDefault("COSENO_URL", "http://localhost:8091/coseno/calculadora/coseno");
    private static final String TANGENTE_URL = System.getenv().getOrDefault("TANGENTE_URL", "http://localhost:8092/tangente/calculadora/tangente");

    public CalculadoraResource() {
        System.out.println("*** Inicializando Calculadora ***");
        System.out.println("=== V1 - Operaciones Básicas ===");
        System.out.println("SUMA_URL: " + SUMA_URL);
        System.out.println("RESTA_URL: " + RESTA_URL);
        System.out.println("MULTIPLICA_URL: " + MULTIPLICA_URL);
        System.out.println("DIVIDE_URL: " + DIVIDE_URL);
        System.out.println("=== V2 - Operaciones Científicas ===");
        System.out.println("RAIZ_URL: " + RAIZ_URL);
        System.out.println("POTENCIA_URL: " + POTENCIA_URL);
        System.out.println("MODULO_URL: " + MODULO_URL);
        System.out.println("LOGARITMO_URL: " + LOGARITMO_URL);
        System.out.println("SENO_URL: " + SENO_URL);
        System.out.println("COSENO_URL: " + COSENO_URL);
        System.out.println("TANGENTE_URL: " + TANGENTE_URL);
    }

    // GET: http://localhost:8080/calculadora/calc/suma?a=10&b=5
    @GET
    @Path("/suma")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado sumar(@QueryParam("a") double a,
                          @QueryParam("b") double b) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(SUMA_URL)
                                      .queryParam("a", a)
                                      .queryParam("b", b);
            
            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);
            
            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en suma: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio SUMA: " + e.getMessage(), "ERROR");
        }
    }

    // GET: http://localhost:8080/calculadora/calc/resta?a=10&b=5
    @GET
    @Path("/resta")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado restar(@QueryParam("a") double a,
                           @QueryParam("b") double b) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(RESTA_URL)
                                      .queryParam("a", a)
                                      .queryParam("b", b);
            
            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);
            
            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en resta: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio RESTA: " + e.getMessage(), "ERROR");
        }
    }

    // GET: http://localhost:8080/calculadora/calc/multiplica?a=10&b=5
    @GET
    @Path("/multiplica")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado multiplicar(@QueryParam("a") double a,
                                @QueryParam("b") double b) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(MULTIPLICA_URL)
                                      .queryParam("a", a)
                                      .queryParam("b", b);
            
            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);
            
            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en multiplica: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio MULTIPLICA: " + e.getMessage(), "ERROR");
        }
    }

    // GET: http://localhost:8080/calculadora/calc/divide?a=10&b=5
    @GET
    @Path("/divide")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado dividir(@QueryParam("a") double a,
                            @QueryParam("b") double b) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(DIVIDE_URL)
                                      .queryParam("a", a)
                                      .queryParam("b", b);

            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);

            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en divide: " + e.getMessage());
            return new Resultado(-1, "Error al llamar servicio DIVIDE: " + e.getMessage(), "ERROR");
        }
    }

    // V2 - Operaciones Científicas

    // GET: http://localhost:8080/calculadora/calc/raiz?n=25
    @GET
    @Path("/raiz")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado raizCuadrada(@QueryParam("n") double n) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(RAIZ_URL)
                                      .queryParam("n", n);

            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);

            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en raiz: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio RAIZ: " + e.getMessage(), "ERROR");
        }
    }

    // GET: http://localhost:8080/calculadora/calc/potencia?base=2&exponente=3
    @GET
    @Path("/potencia")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado potencia(@QueryParam("base") double base,
                             @QueryParam("exponente") double exponente) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(POTENCIA_URL)
                                      .queryParam("base", base)
                                      .queryParam("exponente", exponente);

            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);

            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en potencia: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio POTENCIA: " + e.getMessage(), "ERROR");
        }
    }

    // GET: http://localhost:8080/calculadora/calc/modulo?a=10&b=3
    @GET
    @Path("/modulo")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado modulo(@QueryParam("a") double a,
                           @QueryParam("b") double b) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(MODULO_URL)
                                      .queryParam("a", a)
                                      .queryParam("b", b);

            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);

            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en modulo: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio MODULO: " + e.getMessage(), "ERROR");
        }
    }

    // GET: http://localhost:8080/calculadora/calc/logaritmo?n=10
    @GET
    @Path("/logaritmo")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado logaritmo(@QueryParam("n") double n) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(LOGARITMO_URL)
                                      .queryParam("n", n);

            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);

            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en logaritmo: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio LOGARITMO: " + e.getMessage(), "ERROR");
        }
    }

    // GET: http://localhost:8080/calculadora/calc/seno?angulo=30
    @GET
    @Path("/seno")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado seno(@QueryParam("angulo") double angulo) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(SENO_URL)
                                      .queryParam("angulo", angulo);

            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);

            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en seno: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio SENO: " + e.getMessage(), "ERROR");
        }
    }

    // GET: http://localhost:8080/calculadora/calc/coseno?angulo=60
    @GET
    @Path("/coseno")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado coseno(@QueryParam("angulo") double angulo) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(COSENO_URL)
                                      .queryParam("angulo", angulo);

            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);

            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en coseno: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio COSENO: " + e.getMessage(), "ERROR");
        }
    }

    // GET: http://localhost:8080/calculadora/calc/tangente?angulo=45
    @GET
    @Path("/tangente")
    @Produces(MediaType.APPLICATION_JSON)
    public Resultado tangente(@QueryParam("angulo") double angulo) {
        try {
            Client cliente = ClientBuilder.newClient();
            WebTarget target = cliente.target(TANGENTE_URL)
                                      .queryParam("angulo", angulo);

            String respuesta = target.request(MediaType.APPLICATION_JSON).get(String.class);

            Gson gson = new Gson();
            return gson.fromJson(respuesta, Resultado.class);
        } catch (Exception e) {
            System.err.println("Error en tangente: " + e.getMessage());
            return new Resultado(0, "Error al llamar servicio TANGENTE: " + e.getMessage(), "ERROR");
        }
    }
}