package Modelo;


public class Usuario extends Persona {

    String direccion;
    String tipoUsuario;

    public Usuario(String identificacion, String nombres, String correo, int edad, String telefono, String direccion, String tipoUsuario, String password, String imagenPerfil) {
        super(identificacion, nombres, correo, edad, telefono, password, imagenPerfil);
        this.direccion = direccion;
        this.tipoUsuario = tipoUsuario;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getTipoUsuario() {
        return tipoUsuario;
    }

    public void setTipoUsuario(String tipoUsuario) {
        this.tipoUsuario = tipoUsuario;
    }

}
