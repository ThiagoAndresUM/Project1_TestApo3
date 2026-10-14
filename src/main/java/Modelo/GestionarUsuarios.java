package Modelo;

import java.util.LinkedList;
import java.util.List;
import java.util.Locale;

//CLASE para gestionar el CRUD de la entidad Usuarios
public class GestionarUsuarios {

    //contenedora de USUARIOS para consulta y recorrido 
    private static final LinkedList<Usuario> usuarios = new LinkedList<>();

    /** CREATE --> Registra un usuario si la identificación no existe. */
    public boolean registrar(Usuario usuario) {
        if (usuario == null || usuario.getIdentificacion() == null) {
            return false;
        }
        if (buscarPorIdentificacion(usuario.getIdentificacion()) != null) {
            return false;
        }
        usuarios.add(usuario);
        return true;
    }

    /** Devuelve una copia de la lista para evitar modificarla desde el JSP. */
    public List<Usuario> listar() {
        return new LinkedList<>(usuarios);
    }

    /** Busca un usuario por su identificación. */
    public Usuario buscarPorIdentificacion(String identificacion) {
        if (identificacion == null) return null;
        String buscada = identificacion.trim();
        for (Usuario usuario : usuarios) {
            if (usuario.getIdentificacion() != null
                    && usuario.getIdentificacion().equalsIgnoreCase(buscada)) {
                return usuario;
            }
        }
        return null;
    }

    /** READ --> Filtra por identificación, nombre, correo o teléfono. */
    public List<Usuario> filtrar(String criterio) {
        if (criterio == null || criterio.trim().isEmpty()) return listar();
        String texto = criterio.trim().toLowerCase(Locale.ROOT);
        LinkedList<Usuario> resultado = new LinkedList<>();
        for (Usuario usuario : usuarios) {
            if (contiene(usuario.getIdentificacion(), texto)
                    || contiene(usuario.getNombres(), texto)
                    || contiene(usuario.getCorreo(), texto)
                    || contiene(usuario.getTelefono(), texto)) {
                resultado.add(usuario);
            }
        }
        return resultado;
    }

    /** UPDATE ---> Método que actualiza los datos del usuario conservando su posición en la lista. */
    public boolean actualizar(String identificacionOriginal, Usuario actualizado) {
        if (identificacionOriginal == null || actualizado == null) return false;
        for (int i = 0; i < usuarios.size(); i++) {
            Usuario actual = usuarios.get(i);
            if (actual.getIdentificacion() != null
                    && actual.getIdentificacion().equalsIgnoreCase(identificacionOriginal.trim())) {
                Usuario duplicado = buscarPorIdentificacion(actualizado.getIdentificacion());
                if (duplicado != null && duplicado != actual) return false;
                usuarios.set(i, actualizado);
                return true;
            }
        }
        return false;
    }

    /**DELETE ---> Elimina un usuario por identificación. */
    public boolean eliminar(String identificacion) {
        Usuario usuario = buscarPorIdentificacion(identificacion);
        return usuario != null && usuarios.remove(usuario);
    }

    public int totalUsuarios() {
        return usuarios.size();
    }

    private boolean contiene(String valor, String texto) {
        return valor != null && valor.toLowerCase(Locale.ROOT).contains(texto);
    }
}
