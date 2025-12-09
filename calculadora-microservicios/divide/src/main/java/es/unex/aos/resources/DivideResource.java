package es.unex.aos.resources;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import es.unex.aos.model.Resultado;

@Path("/divide")
public class DivideResource {

    public DivideResource() {
        System.out.println("*** Inicializando recurso DivideResource");
    }

    // GET http://localhost:8080/divide/calculadora/divide?a=10&b=5
    @GET
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Response calcularDivide(@QueryParam("a") double a,
                                @QueryParam("b") double b) {
        long timestamp = System.currentTimeMillis();
        String timestampStr = new java.text.SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date(timestamp));

        System.out.println("================================================================");
        System.out.println("[" + timestampStr + "] ⚡ INTENTO DE DIVISIÓN RECIBIDO");
        System.out.println("[" + timestampStr + "] Parámetros: a=" + a + ", b=" + b);

        if (b == 0) {
            System.out.println("[" + timestampStr + "] ❌ ERROR: División por cero detectada");
            System.out.println("[" + timestampStr + "] 🔄 Kong debería reintentar esta petición (max 3 intentos)");
            System.out.println("[" + timestampStr + "] 📤 Devolviendo HTTP 500 Internal Server Error");
            System.out.println("================================================================");

            Resultado error = new Resultado(-1, "Error: División por cero. No permitido.", "ERROR");
            // Devolver HTTP 500 para que Kong reintente automáticamente
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                          .entity(error)
                          .build();
        }

        double resultado = a / b;
        System.out.println("[" + timestampStr + "] ✅ División exitosa: " + a + " / " + b + " = " + resultado);
        System.out.println("[" + timestampStr + "] 📤 Devolviendo HTTP 200 OK");
        System.out.println("================================================================");

        Resultado respuesta = new Resultado(resultado, "División realizada correctamente", "OK");
        return Response.ok(respuesta).build();
    }
}