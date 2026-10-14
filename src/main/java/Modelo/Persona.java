package Modelo;

/**
 *
 * @author Asus 1
 */
public class Persona {

    String identificacion;
    String nombres;
    String correo;
    int edad;
    String telefono;
    String password;
    String imagenPerfil;

    public Persona(String identificacion, String nombres, String correo, int edad, String telefono, String contraseña, String imagenPerfil) {
        this.identificacion = identificacion;
        this.nombres = nombres;
        this.correo = correo;
        this.edad = edad;
        this.telefono = telefono;
        this.password = password;
        this.imagenPerfil = imagenPerfil;
    }

    public String getIdentificacion() {
        return identificacion;
    }

    public void setIdentificacion(String identificacion) {
        this.identificacion = identificacion;
    }

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String nombres) {
        this.nombres = nombres;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public int getEdad() {
        return edad;
    }

    public void setEdad(int edad) {
        this.edad = edad;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getImagenPerfil() {
        return imagenPerfil;
    }

    public void setImagenPerfil(String imagenPerfil) {
        this.imagenPerfil = imagenPerfil;
    }

}
