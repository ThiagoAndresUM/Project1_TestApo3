
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="Modelo.Usuario"%>
<%@page import="java.util.*"%>
<%@include file="lib/header.jsp" %>
<%!
    private String escaparAdmin(String texto) {
        if (texto == null) {
            return "";
        }
        return texto.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
%>
<%
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    if (usuarios == null) {
        usuarios = new LinkedList<>();
    }
    String contexto = request.getContextPath();
    String criterio = request.getAttribute("criterio") == null ? "" : String.valueOf(request.getAttribute("criterio"));
    int totalGeneral = request.getAttribute("totalUsuarios") == null ? usuarios.size() : (Integer) request.getAttribute("totalUsuarios");
    String mensaje = request.getParameter("mensaje");
    Map<String, String> mensajes = new HashMap<>();
    mensajes.put("registrado", "El usuario se registró correctamente.");
    mensajes.put("actualizado", "Los datos del usuario se actualizaron correctamente.");
    mensajes.put("eliminado", "El usuario se eliminó correctamente.");
    mensajes.put("noEncontrado", "No se encontró el usuario solicitado.");
    mensajes.put("accionInvalida", "La operación solicitada no es válida.");
    String textoMensaje = mensajes.get(mensaje);
    int administradores = 0;
    int docentes = 0;
    int estudiantes = 0;
    for (Usuario u : usuarios) {
        if ("Administrador".equalsIgnoreCase(u.getTipoUsuario())) {
            administradores++;
        }
        if ("Docente".equalsIgnoreCase(u.getTipoUsuario())) {
            docentes++;
        }
        if ("Estudiante".equalsIgnoreCase(u.getTipoUsuario())) {
            estudiantes++;
        }
    }
%>

<div class="container-fluid container-xxl py-4 px-3 px-lg-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-4">
        <div>
            <div class="text-primary fw-semibold small text-uppercase mb-1">Panel de administración</div>
            <h1 class="h2 mb-1">Gestión de usuarios</h1>
            <p class="text-secondary mb-0">Consulta, filtra, edita y elimina los usuarios registrados.</p>
        </div>
        <a class="btn btn-primary btn-lg" href="<%= contexto%>/UsuariosServlet?accion=nuevo"><i class="bi bi-person-plus me-2"></i>Nuevo usuario</a>
    </div>

    <% if (textoMensaje != null) {%>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-2"></i><%= escaparAdmin(textoMensaje)%>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
    </div>
    <% }%>

    <div class="row g-3 mb-4">
        <div class="col-6 col-xl-3"><div class="card border-0 shadow-sm h-100"><div class="card-body"><div class="d-flex justify-content-between"><span class="text-secondary small">Usuarios encontrados</span><i class="bi bi-people fs-4 text-primary"></i></div><div class="display-6 fw-semibold" id="totalVisible"><%= usuarios.size()%></div><small class="text-secondary">Total general: <%= totalGeneral%></small></div></div></div>
        <div class="col-6 col-xl-3"><div class="card border-0 shadow-sm h-100"><div class="card-body"><div class="d-flex justify-content-between"><span class="text-secondary small">Administradores</span><i class="bi bi-shield-check fs-4 text-danger"></i></div><div class="display-6 fw-semibold"><%= administradores%></div><small class="text-secondary">En los resultados actuales</small></div></div></div>
        <div class="col-6 col-xl-3"><div class="card border-0 shadow-sm h-100"><div class="card-body"><div class="d-flex justify-content-between"><span class="text-secondary small">Docentes</span><i class="bi bi-mortarboard fs-4 text-success"></i></div><div class="display-6 fw-semibold"><%= docentes%></div><small class="text-secondary">En los resultados actuales</small></div></div></div>
        <div class="col-6 col-xl-3"><div class="card border-0 shadow-sm h-100"><div class="card-body"><div class="d-flex justify-content-between"><span class="text-secondary small">Estudiantes</span><i class="bi bi-backpack fs-4 text-warning"></i></div><div class="display-6 fw-semibold"><%= estudiantes%></div><small class="text-secondary">En los resultados actuales</small></div></div></div>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white border-0 pt-4 px-3 px-lg-4">
            <div class="row g-3 align-items-end">
                <div class="col-12 col-lg-5">
                    <label for="busquedaTabla" class="form-label small fw-semibold">Buscar en la tabla</label>
                    <div class="input-group"><span class="input-group-text bg-white"><i class="bi bi-search"></i></span><input class="form-control" type="search" id="busquedaTabla" placeholder="Nombre, identificación, correo o teléfono..."><button class="btn btn-outline-secondary" id="limpiarBusqueda" type="button">Limpiar</button></div>
                </div>
                <div class="col-6 col-lg-3">
                    <label for="filtroTipo" class="form-label small fw-semibold">Tipo de usuario</label>
                    <select class="form-select" id="filtroTipo"><option value="">Todos los tipos</option><option>Administrador</option><option>Docente</option><option>Estudiante</option><option>Invitado</option></select>
                </div>
                <div class="col-6 col-lg-2">
                    <label for="filasPagina" class="form-label small fw-semibold">Filas por página</label>
                    <select class="form-select" id="filasPagina"><option value="5">5</option><option value="10" selected>10</option><option value="20">20</option><option value="50">50</option></select>
                </div>
                <div class="col-12 col-lg-2 d-grid"><button class="btn btn-outline-primary" id="exportarCsv" type="button"><i class="bi bi-download me-1"></i>Exportar CSV</button></div>
            </div>
            <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mt-3 mb-2"><span class="small text-secondary" id="textoResultados" aria-live="polite">Mostrando usuarios</span><button type="button" class="btn btn-sm btn-link text-decoration-none" id="limpiarFiltros">Restablecer filtros</button></div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0" id="tablaUsuarios">
                <thead class="table-light"><tr><th class="ps-3">Usuario</th><th>Identificación</th><th>Correo / teléfono</th><th>Edad</th><th>Tipo</th><th>Dirección</th><th class="text-end pe-3">Acciones</th></tr></thead>
                <tbody>
                    <% if (usuarios.isEmpty()) {%>
                    <tr id="filaVaciaServidor"><td colspan="7" class="text-center py-5"><i class="bi bi-person-exclamation display-6 d-block text-secondary mb-2"></i><strong>No hay usuarios para mostrar</strong><p class="text-secondary mb-3">Registra un usuario o cambia el criterio de búsqueda.</p><a class="btn btn-primary btn-sm" href="<%= contexto%>/UsuariosServlet?accion=nuevo">Registrar primer usuario</a></td></tr>
                                <% } else {
                                    for (Usuario u : usuarios) {
                                        String nombreImagen = u.getImagenPerfil();
                                        String srcImagen = (nombreImagen == null || nombreImagen.trim().isEmpty()) ? "https://placehold.co/64x64?text=U" : contexto + "/" + nombreImagen;
                                        String tipo = u.getTipoUsuario() == null ? "Sin tipo" : u.getTipoUsuario();
                                        String badge = "Administrador".equalsIgnoreCase(tipo) ? "text-bg-danger" : ("Docente".equalsIgnoreCase(tipo) ? "text-bg-success" : ("Estudiante".equalsIgnoreCase(tipo) ? "text-bg-primary" : "text-bg-secondary"));
                                %>
                    <tr class="fila-usuario" data-tipo="<%= escaparAdmin(tipo).toLowerCase(Locale.ROOT)%>">
                        <td class="ps-3"><div class="d-flex align-items-center gap-2"><img src="<%= escaparAdmin(srcImagen)%>" alt="Foto de <%= escaparAdmin(u.getNombres())%>" class="rounded-circle border" style="width:44px;height:44px;object-fit:cover" onerror="this.src='https://placehold.co/64x64?text=U'"><div><div class="fw-semibold"><%= escaparAdmin(u.getNombres())%></div><div class="small text-secondary">Perfil de usuario</div></div></div></td>
                        <td><span class="font-monospace"><%= escaparAdmin(u.getIdentificacion())%></span></td>
                        <td><div><%= escaparAdmin(u.getCorreo())%></div><div class="small text-secondary"><%= escaparAdmin(u.getTelefono())%></div></td>
                        <td><%= u.getEdad()%></td>
                        <td><span class="badge rounded-pill <%= badge%>"><%= escaparAdmin(tipo)%></span></td>
                        <td class="text-truncate" style="max-width:180px" title="<%= escaparAdmin(u.getDireccion())%>"><%= escaparAdmin(u.getDireccion())%></td>
                        <td class="text-end pe-3"><div class="btn-group btn-group-sm" role="group" aria-label="Acciones de usuario"><a class="btn btn-outline-primary" title="Editar usuario" href="<%= contexto%>/UsuariosServlet?accion=editar&id=<%= java.net.URLEncoder.encode(u.getIdentificacion(), "UTF-8")%>"><i class="bi bi-pencil-square"></i><span class="d-none d-xl-inline ms-1">Editar</span></a><button class="btn btn-outline-danger" type="button" title="Eliminar usuario" data-bs-toggle="modal" data-bs-target="#modalEliminar" data-id="<%= escaparAdmin(u.getIdentificacion())%>" data-nombre="<%= escaparAdmin(u.getNombres())%>"><i class="bi bi-trash"></i><span class="d-none d-xl-inline ms-1">Eliminar</span></button></div></td>
                    </tr>
                    <% }
                    }%>
                </tbody>
            </table>
        </div>
        <div class="card-footer bg-white border-0 d-flex flex-wrap justify-content-between align-items-center gap-2 px-3 px-lg-4 py-3"><small class="text-secondary" id="resumenPagina"></small><nav aria-label="Paginación de usuarios"><ul class="pagination pagination-sm mb-0" id="paginacion"></ul></nav></div>
    </div>
    <p class="small text-secondary mt-3 mb-0"><i class="bi bi-info-circle me-1"></i>Los datos se almacenan en una LinkedList en memoria. Se perderán al reiniciar la aplicación.</p>
</div>

<div class="modal fade" id="modalEliminar" tabindex="-1" aria-labelledby="tituloModalEliminar" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered"><div class="modal-content border-0 shadow"><div class="modal-header"><h2 class="modal-title fs-5" id="tituloModalEliminar"><i class="bi bi-exclamation-triangle text-danger me-2"></i>Confirmar eliminación</h2><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button></div><div class="modal-body">¿Seguro que deseas eliminar a <strong id="nombreEliminar"></strong>? Esta acción no se puede deshacer.</div><div class="modal-footer"><button type="button" class="btn btn-light border" data-bs-dismiss="modal">Cancelar</button><form action="<%= contexto%>/UsuariosServlet" method="post" class="m-0"><input type="hidden" name="accion" value="eliminar"><input type="hidden" name="identificacion" id="idEliminar"><button type="submit" class="btn btn-danger"><i class="bi bi-trash me-1"></i>Eliminar usuario</button></form></div></div></div>
</div>

<script>
    (() => {
        const tabla = document.getElementById('tablaUsuarios');
        const filas = Array.from(tabla.querySelectorAll('tbody tr.fila-usuario'));
        const busqueda = document.getElementById('busquedaTabla');
        const filtroTipo = document.getElementById('filtroTipo');
        const filasPagina = document.getElementById('filasPagina');
        const paginacion = document.getElementById('paginacion');
        const textoResultados = document.getElementById('textoResultados');
        const resumenPagina = document.getElementById('resumenPagina');
        const totalVisible = document.getElementById('totalVisible');
        let paginaActual = 1;
        let filtradas = filas;

        function aplicarFiltros() {
            const texto = busqueda.value.trim().toLocaleLowerCase();
            const tipo = filtroTipo.value.toLocaleLowerCase();
            filtradas = filas.filter(fila => {
                const coincideTexto = fila.innerText.toLocaleLowerCase().includes(texto);
                const coincideTipo = !tipo || fila.dataset.tipo === tipo.toLocaleLowerCase();
                return coincideTexto && coincideTipo;
            });
            paginaActual = 1;
            dibujarTabla();
        }

        function dibujarTabla() {
            const porPagina = Number(filasPagina.value) || 10;
            const paginas = Math.max(1, Math.ceil(filtradas.length / porPagina));
            if (paginaActual > paginas)
                paginaActual = paginas;
            filas.forEach(fila => fila.hidden = true);
            const inicio = (paginaActual - 1) * porPagina;
            filtradas.slice(inicio, inicio + porPagina).forEach(fila => fila.hidden = false);
            totalVisible.textContent = filtradas.length;
            textoResultados.textContent = filtradas.length ? `Se encontraron ${filtradas.length} usuario(s)` : 'No hay coincidencias para los filtros aplicados';
            resumenPagina.textContent = filtradas.length ? `Mostrando ${inicio + 1}–${Math.min(inicio + porPagina, filtradas.length)} de ${filtradas.length}` : '0 resultados';
            paginacion.innerHTML = '';
            agregarBoton('Anterior', paginaActual - 1, paginaActual === 1);
            for (let p = 1; p <= paginas; p++)
                agregarBoton(String(p), p, false, p === paginaActual);
            agregarBoton('Siguiente', paginaActual + 1, paginaActual === paginas);
            let vacia = document.getElementById('filaVaciaDinamica');
            if (!filtradas.length) {
                if (!vacia) {
                    vacia = document.createElement('tr');
                    vacia.id = 'filaVaciaDinamica';
                    vacia.innerHTML = '<td colspan="7" class="text-center py-4 text-secondary"><i class="bi bi-search me-2"></i>No se encontraron usuarios con esos criterios.</td>';
                    tabla.querySelector('tbody').appendChild(vacia);
                }
                vacia.hidden = false;
            } else if (vacia)
                vacia.hidden = true;
        }

        function agregarBoton(texto, pagina, deshabilitado, activo) {
            const li = document.createElement('li');
            li.className = 'page-item' + (deshabilitado ? ' disabled' : '') + (activo ? ' active' : '');
            const boton = document.createElement('button');
            boton.type = 'button';
            boton.className = 'page-link';
            boton.textContent = texto;
            boton.disabled = deshabilitado;
            boton.addEventListener('click', () => {
                paginaActual = pagina;
                dibujarTabla();
            });
            li.appendChild(boton);
            paginacion.appendChild(li);
        }

        busqueda.addEventListener('input', aplicarFiltros);
        filtroTipo.addEventListener('change', aplicarFiltros);
        filasPagina.addEventListener('change', () => {
            paginaActual = 1;
            dibujarTabla();
        });
        document.getElementById('limpiarBusqueda').addEventListener('click', () => {
            busqueda.value = '';
            aplicarFiltros();
            busqueda.focus();
        });
        document.getElementById('limpiarFiltros').addEventListener('click', () => {
            busqueda.value = '';
            filtroTipo.value = '';
            filasPagina.value = '10';
            aplicarFiltros();
        });

        document.getElementById('modalEliminar').addEventListener('show.bs.modal', event => {
            const boton = event.relatedTarget;
            document.getElementById('idEliminar').value = boton.getAttribute('data-id') || '';
            document.getElementById('nombreEliminar').textContent = boton.getAttribute('data-nombre') || 'este usuario';
        });

        document.getElementById('exportarCsv').addEventListener('click', () => {
            const encabezados = ['Nombre', 'Identificación', 'Correo', 'Teléfono', 'Edad', 'Tipo', 'Dirección'];
            const datos = filtradas.map(fila => {
                const celdas = fila.querySelectorAll('td');
                const contacto = celdas[2].innerText.split('\n').map(x => x.trim());
                return [celdas[0].innerText.trim(), celdas[1].innerText.trim(), contacto[0] || '', contacto[1] || '', celdas[3].innerText.trim(), celdas[4].innerText.trim(), celdas[5].innerText.trim()];
            });
            const csv = [encabezados, ...datos].map(fila => fila.map(valor => '"' + String(valor).replace(/"/g, '""') + '"').join(';')).join('\r\n');
            const blob = new Blob(['\ufeff' + csv], {type: 'text/csv;charset=utf-8;'});
            const url = URL.createObjectURL(blob);
            const enlace = document.createElement('a');
            enlace.href = url;
            enlace.download = 'usuarios.csv';
            enlace.click();
            URL.revokeObjectURL(url);
        });
        dibujarTabla();
    })();
</script>

<%@ include file="lib/footer.jsp" %>
