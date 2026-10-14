/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Servlets;

import Modelo.GestionarUsuarios;
import Modelo.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@WebServlet(name = "UsuariosServlet", urlPatterns = {"/UsuariosServlet"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 7 * 1024 * 1024
)
public class UsuariosServlet extends HttpServlet {

    private final GestionarUsuarios gestor = new GestionarUsuarios();
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String accion = valor(request.getParameter("accion"));

        if ("nuevo".equals(accion)) {
            request.setAttribute("modo", "nuevo");
            request.getRequestDispatcher("/registroUsuarios.jsp").forward(request, response);
            return;
        }

        if ("editar".equals(accion)) {
            String id = request.getParameter("id");
            Usuario usuario = gestor.buscarPorIdentificacion(id);
            if (usuario == null) {
                response.sendRedirect(request.getContextPath() + "/UsuariosServlet?mensaje=noEncontrado");
                return;
            }
            request.setAttribute("usuarioEditar", usuario);
            request.setAttribute("modo", "editar");
            request.getRequestDispatcher("/registroUsuarios.jsp").forward(request, response);
            return;
        }

        String criterio = valor(request.getParameter("buscar"));
        List<Usuario> lista = criterio.isEmpty() ? gestor.listar() : gestor.filtrar(criterio);
        request.setAttribute("usuarios", lista);
        request.setAttribute("criterio", criterio);
        request.setAttribute("totalUsuarios", gestor.totalUsuarios());
        request.getRequestDispatcher("/adminUsuarios.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String accion = valor(request.getParameter("accion"));

        try {
            if ("guardar".equals(accion)) {
                guardarUsuario(request, response);
            } else if ("eliminar".equals(accion)) {
                boolean eliminado = gestor.eliminar(request.getParameter("identificacion"));
                redirigir(response, request, eliminado ? "eliminado" : "noEncontrado");
            } else {
                redirigir(response, request, "accionInvalida");
            }
        } catch (IllegalArgumentException ex) {
            request.getSession().setAttribute("mensajeError", ex.getMessage());
            String idOriginal = valor(request.getParameter("identificacionOriginal"));
            if (!idOriginal.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/UsuariosServlet?accion=editar&id=" + encode(idOriginal));
            } else {
                response.sendRedirect(request.getContextPath() + "/UsuariosServlet?accion=nuevo");
            }
        }
    }

    private void guardarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String identificacionOriginal = valor(request.getParameter("identificacionOriginal"));
        String identificacion = requerido(request, "identificacion", "La identificación es obligatoria.");
        String nombres = requerido(request, "nombres", "Los nombres son obligatorios.");
        String correo = requerido(request, "correo", "El correo es obligatorio.");
        String edadTexto = requerido(request, "edad", "La edad es obligatoria.");
        String telefono = valor(request.getParameter("telefono"));
        String direccion = valor(request.getParameter("direccion"));
        String tipoUsuario = requerido(request, "tipoUsuario", "Selecciona el tipo de usuario.");
        String password = valor(request.getParameter("password"));
        String imagenAnterior = valor(request.getParameter("imagenAnterior"));

        int edad;
        try {
            edad = Integer.parseInt(edadTexto);
            if (edad < 0 || edad > 120) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("La edad debe ser un número entre 0 y 120.");
        }
        if (!correo.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            throw new IllegalArgumentException("Escribe un correo electrónico válido.");
        }

        Usuario anterior = identificacionOriginal.isEmpty() ? null
                : gestor.buscarPorIdentificacion(identificacionOriginal);
        if (!identificacionOriginal.isEmpty() && anterior == null) {
            throw new IllegalArgumentException("No se encontró el usuario que deseas editar.");
        }
        if (anterior == null && password.isEmpty()) {
            throw new IllegalArgumentException("La contraseña es obligatoria al registrar un usuario.");
        }
        if (anterior != null && password.isEmpty()) {
            password = anterior.getPassword(); // Si se deja vacío, conserva la contraseña actual.
        }

        String imagenPerfil = guardarImagen(request, imagenAnterior);
        Usuario usuario = new Usuario(identificacion, nombres, correo, edad, telefono,
                direccion, tipoUsuario, password, imagenPerfil);

        boolean correcto;
        if (identificacionOriginal.isEmpty()) {
            correcto = gestor.registrar(usuario);
        } else {
            correcto = gestor.actualizar(identificacionOriginal, usuario);
        }
        if (!correcto) {
            throw new IllegalArgumentException("No se pudo guardar. Verifica que la identificación no esté repetida.");
        }
        redirigir(response, request, identificacionOriginal.isEmpty() ? "registrado" : "actualizado");
    }

    /**
     * Guarda la imagen enviada desde el equipo dentro de /uploads.
     */
    private String guardarImagen(HttpServletRequest request, String imagenAnterior)
            throws IOException, ServletException {
        Part archivo = request.getPart("imagenPerfil");
        if (archivo == null || archivo.getSize() == 0) {
            return imagenAnterior;
        }
        if (archivo.getSize() > 5L * 1024 * 1024) {
            throw new IllegalArgumentException("La imagen no puede superar los 5 MB.");
        }

        String tipoMime = archivo.getContentType();
        if (tipoMime == null || !(tipoMime.equalsIgnoreCase("image/jpeg")
                || tipoMime.equalsIgnoreCase("image/png")
                || tipoMime.equalsIgnoreCase("image/gif")
                || tipoMime.equalsIgnoreCase("image/webp"))) {
            throw new IllegalArgumentException("Selecciona una imagen JPG, PNG, GIF o WEBP.");
        }

        String nombreOriginal = Paths.get(archivo.getSubmittedFileName() == null
                ? "imagen" : archivo.getSubmittedFileName()).getFileName().toString();
        String extension = "";
        int punto = nombreOriginal.lastIndexOf('.');
        if (punto >= 0) {
            extension = nombreOriginal.substring(punto).toLowerCase(Locale.ROOT);
        }
        if (!(extension.equals(".jpg") || extension.equals(".jpeg") || extension.equals(".png")
                || extension.equals(".gif") || extension.equals(".webp"))) {
            throw new IllegalArgumentException("La extensión de la imagen no es válida.");
        }

        String carpetaReal = getServletContext().getRealPath("/uploads");
        if (carpetaReal == null) {
            throw new IllegalArgumentException("No se pudo acceder a la carpeta uploads. Ejecuta la aplicación desde NetBeans/Tomcat.");
        }
        Path carpeta = Paths.get(carpetaReal);
        Files.createDirectories(carpeta);
        String nombreSeguro = UUID.randomUUID().toString() + extension;
        archivo.write(carpeta.resolve(nombreSeguro).toString());
        return "uploads/" + nombreSeguro;
    }

    private String requerido(HttpServletRequest request, String nombre, String mensaje) {
        String valor = valor(request.getParameter(nombre));
        if (valor.isEmpty()) {
            throw new IllegalArgumentException(mensaje);
        }
        return valor;
    }

    private String valor(String texto) {
        return texto == null ? "" : texto.trim();
    }

    private void redirigir(HttpServletResponse response, HttpServletRequest request, String mensaje)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/UsuariosServlet?mensaje=" + encode(mensaje));
    }

    private String encode(String texto) {
        try {
            return java.net.URLEncoder.encode(texto, java.nio.charset.StandardCharsets.UTF_8.name());
        } catch (java.io.UnsupportedEncodingException ex) {
            return "";
        }
    }
}
