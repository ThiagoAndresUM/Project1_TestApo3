<%@include file="lib/header.jsp" %>
    <div>
        <img src="./images/java-banner.png" alt="Banner de proyecto"> 
    </div>
    <h1> *** Mi página web en JSP ***</h1>
    <h3> Prueba de clonación en PC1</h3>
    <br>
    <h3> Cuerpo de página index </h3>
    <%
        int edad = 15;
        out.print(edad);
    %>
    <div class="container">
        <form action="registro.jsp" method="GET">
            <button  type="submit" class="btn btn-primary" >Registrar Usuario</button>
        </form>
    </div>
<%@include file="lib/footer.jsp" %>
