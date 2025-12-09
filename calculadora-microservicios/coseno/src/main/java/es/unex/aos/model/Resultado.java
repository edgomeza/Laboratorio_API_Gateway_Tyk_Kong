package es.unex.aos.model;

import jakarta.xml.bind.annotation.XmlElement;
import jakarta.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class Resultado {
    private double resultado;
    private String mensaje;
    private String estado;

    public Resultado() {
        this.resultado = 0;
        this.mensaje = "";
        this.estado = "OK";
    }

    public Resultado(double resultado, String mensaje) {
        this.resultado = resultado;
        this.mensaje = mensaje;
        this.estado = "OK";
    }

    public Resultado(double resultado, String mensaje, String estado) {
        this.resultado = resultado;
        this.mensaje = mensaje;
        this.estado = estado;
    }

    @XmlElement
    public double getResultado() {
        return resultado;
    }

    public void setResultado(double resultado) {
        this.resultado = resultado;
    }

    @XmlElement
    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    @XmlElement
    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
}