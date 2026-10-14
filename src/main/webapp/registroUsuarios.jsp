<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- 
    Document   : registroProductos
    Created on : 30/09/2026, 7:36:19 a. m.
    Author     : AndrésCastillo
--%>
<%@page import="Modelo.Usuario"%>
<%@page import="java.util.*"%>
<%@include file="lib/header.jsp" %>
<%!
    private String escaparRegistro(String texto) {
        if (texto == null) {
            return "";
        }
        return texto.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
%>
<%
    Usuario usuarioEditar = (Usuario) request.getAttribute("usuarioEditar");
    boolean editando = usuarioEditar != null;
    String contexto = request.getContextPath();
    String mensajeError = (String) session.getAttribute("mensajeError");
    if (mensajeError != null) {
        session.removeAttribute("mensajeError");
    }
    String identificacion = editando ? usuarioEditar.getIdentificacion() : "";
    String nombres = editando ? usuarioEditar.getNombres() : "";
    String correo = editando ? usuarioEditar.getCorreo() : "";
    String telefono = editando ? usuarioEditar.getTelefono() : "";
    String direccion = editando ? usuarioEditar.getDireccion() : "";
    String tipoUsuario = editando ? usuarioEditar.getTipoUsuario() : "";
    String imagen = editando ? usuarioEditar.getImagenPerfil() : "";
    int edad = editando ? usuarioEditar.getEdad() : 18;
%>

<div class="container py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
        <div>
            <p class="text-primary fw-semibold mb-1">GESTIÓN DE USUARIOS</p>
            <h1 class="h3 mb-1"><%= editando ? "Editar usuario" : "Registrar usuario"%></h1>
            <p class="text-secondary mb-0"><%= editando ? "Actualiza los datos del usuario." : "Completa el formulario para crear un nuevo usuario."%></p>
        </div>
        <a class="btn btn-outline-secondary" href="<%= contexto%>/UsuariosServlet"><i class="bi bi-arrow-left me-1"></i> Volver al listado</a>
    </div>

    <% if (mensajeError != null && !mensajeError.isEmpty()) {%>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <%= escaparRegistro(mensajeError)%>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
    </div>
    <% }%>

    <div class="card border-0 shadow-sm">
        <div class="card-body p-4">
            <form action="<%= contexto%>/UsuariosServlet" method="post" enctype="multipart/form-data" id="formUsuario">
                <input type="hidden" name="accion" value="guardar">
                <input type="hidden" name="identificacionOriginal" value="<%= escaparRegistro(identificacion)%>">
                <input type="hidden" name="imagenAnterior" value="<%= escaparRegistro(imagen)%>">

                <div class="row g-4">
                    <div class="col-12 col-lg-8">
                        <h2 class="h6 border-bottom pb-2 mb-3">Información personal</h2>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="identificacion" class="form-label">Identificación *</label>
                                <input class="form-control" id="identificacion" name="identificacion" maxlength="30" required value="<%= escaparRegistro(identificacion)%>">
                            </div>
                            <div class="col-md-6">
                                <label for="nombres" class="form-label">Nombres completos *</label>
                                <input class="form-control" id="nombres" name="nombres" maxlength="120" required value="<%= escaparRegistro(nombres)%>">
                            </div>
                            <div class="col-md-6">
                                <label for="correo" class="form-label">Correo electrónico *</label>
                                <input class="form-control" type="email" id="correo" name="correo" maxlength="150" required value="<%= escaparRegistro(correo)%>">
                            </div>
                            <div class="col-md-6">
                                <label for="edad" class="form-label">Edad *</label>
                                <input class="form-control" type="number" id="edad" name="edad" min="0" max="120" required value="<%= edad%>">
                            </div>
                            <div class="col-md-6">
                                <label for="telefono" class="form-label">Teléfono</label>
                                <input class="form-control" id="telefono" name="telefono" maxlength="30" value="<%= escaparRegistro(telefono)%>">
                            </div>
                            <div class="col-md-6">
                                <label for="tipoUsuario" class="form-label">Tipo de usuario *</label>
                                <select class="form-select" id="tipoUsuario" name="tipoUsuario" required>
                                    <option value="">Selecciona una opción</option>
                                    <option value="Administrador" <%= "Administrador".equals(tipoUsuario) ? "selected" : ""%>>Administrador</option>
                                    <option value="Docente" <%= "Docente".equals(tipoUsuario) ? "selected" : ""%>>Docente</option>
                                    <option value="Estudiante" <%= "Estudiante".equals(tipoUsuario) ? "selected" : ""%>>Estudiante</option>
                                    <option value="Invitado" <%= "Invitado".equals(tipoUsuario) ? "selected" : ""%>>Invitado</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label for="direccion" class="form-label">Dirección</label>
                                <textarea class="form-control" id="direccion" name="direccion" rows="2" maxlength="250"><%= escaparRegistro(direccion)%></textarea>
                            </div>
                            <div class="col-12">
                                <label for="password" class="form-label">Contraseña <%= editando ? "(dejar vacía para conservar la actual)" : "*"%></label>
                                <div class="input-group">
                                    <input class="form-control" type="password" id="password" name="password" <%= editando ? "" : "required"%> minlength="6" autocomplete="new-password" placeholder="<%= editando ? "Sin cambios si queda vacía" : "Mínimo 6 caracteres"%>">
                                    <button class="btn btn-outline-secondary" type="button" id="verPassword" aria-label="Mostrar u ocultar contraseña"><i class="bi bi-eye"></i></button>
                                </div>
                                <div class="form-text">Para este ejemplo en memoria, la contraseña se conserva como atributo del modelo. No uses este enfoque en producción sin hash seguro.</div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-lg-4">
                        <h2 class="h6 border-bottom pb-2 mb-3">Imagen de perfil</h2>
                        <div class="text-center p-3 bg-body-tertiary rounded-3">
                            <img id="vistaPrevia" class="rounded-circle border bg-white mb-3" alt="Vista previa de la imagen" style="width:160px;height:160px;object-fit:cover;"
                                 src="<%= imagen == null || imagen.isEmpty() ? "https://placehold.co/160x160?text=Perfil" : contexto + "/" + escaparRegistro(imagen)%>">
                            <label for="imagenPerfil" class="form-label d-block fw-semibold">Seleccionar imagen desde el equipo</label>
                            <input class="form-control" type="file" id="imagenPerfil" name="imagenPerfil" accept="image/png,image/jpeg,image/gif,image/webp">
                            <div class="form-text text-start">Formatos: JPG, PNG, GIF o WEBP. Máximo 5 MB. Si editas y no seleccionas otra imagen, se conserva la anterior.</div>
                        </div>
                    </div>
                </div>

                <div class="d-flex flex-wrap justify-content-end gap-2 mt-4 pt-3 border-top">
                    <a href="<%= contexto%>/UsuariosServlet" class="btn btn-light border">Cancelar</a>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-check-circle me-1"></i><%= editando ? "Guardar cambios" : "Registrar usuario"%></button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (() => {
        const archivo = document.getElementById('imagenPerfil');
        const vista = document.getElementById('vistaPrevia');
        const password = document.getElementById('password');
        const boton = document.getElementById('verPassword');

        archivo.addEventListener('change', () => {
            const file = archivo.files && archivo.files[0];
            if (!file)
                return;
            if (!file.type.startsWith('image/')) {
                alert('Selecciona un archivo de imagen válido.');
                archivo.value = '';
                return;
            }
            if (file.size > 5 * 1024 * 1024) {
                alert('La imagen no puede superar los 5 MB.');
                archivo.value = '';
                return;
            }
            vista.src = URL.createObjectURL(file);
        });

        boton.addEventListener('click', () => {
            const visible = password.type === 'text';
            password.type = visible ? 'password' : 'text';
            boton.innerHTML = visible ? '<i class="bi bi-eye"></i>' : '<i class="bi bi-eye-slash"></i>';
        });
    })();
</script>

<%@ include file="lib/footer.jsp" %>