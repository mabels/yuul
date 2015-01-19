package com.adviser.yuul.web

import org.eclipse.jetty.server.Server
import org.eclipse.jetty.servlet.ServletContextHandler

class Main  {
 
    public static def void main(String[] args) throws Exception {
        val server = new Server(8080)
        val servletContextHandler = new ServletContextHandler(server, "/", true, false)
        servletContextHandler.addServlet(YuulWebServlet, "/")
        server.start()
        server.join()
    }
}
