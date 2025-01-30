const express = require("express");
const { createServer } = require("http");
const { Server } = require("socket.io");
const NotificationService = require("./services/notificationService");
const path = require("path");

class App {
  constructor(notificationService) {
    this.app = express();
    this.server = createServer(this.app);
    this.io = new Server(this.server);
    this.notificationService = notificationService;
    // Servir archivos estáticos
    this.app.use(express.static(path.join(__dirname, "../public")));
    this.setupRoutes();
    this.setupSocket();
  }

  setupRoutes() {
    this.app.get("/notify", (req, res) => {
      const message = req.query.message || "Hello!";
      this.notificationService.notify(message);
      res.send("Notification sent!");
    });
  }

  setupSocket() {
    this.io.on("connection", (socket) => {
      console.log("User connected");
      this.notificationService.registerSocket(socket);
    });
  }

  start(port = 3000) {
    this.server.listen(port, () => {
      console.log(`Server running on port ${port}`);
    });
  }
}

// Inyección de dependencia (Principio SOLID)
const notificationService = new NotificationService();
new App(notificationService).start();
